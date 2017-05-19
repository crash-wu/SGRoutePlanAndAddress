/*!
 @header AFURLSessionManager+SGS.m
 
 @author Created by Lee on 16/9/20.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "AFURLSessionManager+SGS.h"
#import <CommonCrypto/CommonCrypto.h>
#import <objc/runtime.h>
#import "SGSHTTPConfig.h"
#import "SGSBaseRequest.h"
#import "SGSRequestDelegate.h"


#pragma mark - Constants

const char *kResumeDataIOQueueLabel = "com.southgis.iMobile.HTTPModule.ResumeData.ioQueue";
static NSString *const kResumeDataFolderName = @"com.southgis.iMobile.HTTPModule.ResumeData";

static const int kRequestsRecordKey;
static const int kDownloadRecordKey;
static const int kRequestLockKey;
static const int kDownloadLockKey;

typedef void(^ProgressBlock)(NSProgress *);


#pragma mark - p_ResumeDataManager

/// 断点数据管理类，仅内部使用
@interface p_ResumeDataManager : NSObject

+(instancetype)sharedInstance;

/// 获取断点数据
- (NSData *)resumeDataWithKey:(NSString *)key;

/// 处理断点数据
- (void)handleResumeDataError:(NSError *)error saveKey:(NSString *)key;

/// 清除所有的断点数据
- (void)clearAllResumeDataWithCompletionHandler:(void (^)(BOOL))handler;
@end


@implementation p_ResumeDataManager {
    dispatch_queue_t _ioQueue;
    NSCache *_resumeDataCache;
    NSString *_resumeDataDiskPath;
}

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _ioQueue = dispatch_queue_create(kResumeDataIOQueueLabel, DISPATCH_QUEUE_SERIAL);
        
        _resumeDataCache = [[NSCache alloc] init];
        _resumeDataCache.name = kResumeDataFolderName;
        _resumeDataCache.totalCostLimit = 1 << 11;  // 2M缓存大小
        
        _resumeDataDiskPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _resumeDataDiskPath = [_resumeDataDiskPath stringByAppendingPathComponent:kResumeDataFolderName];
    }
    return self;
}

- (NSData *)resumeDataWithKey:(NSString *)key {
    if (key == nil) return nil;
    
    // 优先从缓存中获取
    __block NSData *result = [_resumeDataCache objectForKey:key];
    if (result != nil) {
        return result;
    }
    
    dispatch_sync(_ioQueue, ^{
        result = [NSData dataWithContentsOfFile:[self p_resumeDataPathWithKey:key]];
    });
    
    return result;
}

- (void)handleResumeDataError:(NSError *)error saveKey:(NSString *)key {
    NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    if (resumeData != nil) {
        [self p_storeResumeData:resumeData withKey:key];
    } else {
        [self p_removeResumeDataWithKey:key completionHandler:nil];
    }
}

// 清除所有的断点数据
- (void)clearAllResumeDataWithCompletionHandler:(void (^)(BOOL))handler {
    [_resumeDataCache removeAllObjects];
    
    dispatch_async(_ioQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // 移除目录后重新创建
        BOOL result = [fileManager removeItemAtPath:_resumeDataDiskPath error:nil];
        
        [fileManager createDirectoryAtPath:_resumeDataDiskPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        
        if (handler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(result);
            });
        }
    });
}

/// 保存断点数据
- (void)p_storeResumeData:(NSData *)data withKey:(NSString *)key {
    if (key == nil || data == nil)  return;
    
    [_resumeDataCache setObject:data forKey:key cost:data.length];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    dispatch_async(_ioQueue, ^{
        
        if (![fileManager fileExistsAtPath:_resumeDataDiskPath]) {
            
            if (![fileManager createDirectoryAtPath:_resumeDataDiskPath withIntermediateDirectories:YES attributes:nil error:NULL]) return ;
        }
        
        NSString *cachePath = [self p_resumeDataPathWithKey:key];
        
        [data writeToFile:cachePath atomically:YES];
    });
}

/// 移除缓存的断点数据
- (void)p_removeResumeDataWithKey:(NSString *)key completionHandler:(void (^)(BOOL))handler {
    if (key == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(NO);
        });
        return;
    }
    
    [_resumeDataCache removeObjectForKey:key];
    
    dispatch_async(_ioQueue, ^{
        
        NSString *cachePath = [self p_resumeDataPathWithKey:key];
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:cachePath error:NULL];
        
        if (handler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(result);
            });
        }
    });
}

/// 断点数据本地路径
- (NSString *)p_resumeDataPathWithKey:(NSString *)key {
    NSString *fileName = [self p_md5String:key];
    
    return [_resumeDataDiskPath stringByAppendingPathComponent:fileName];
}

// 计算MD5散列值
- (NSString *)p_md5String:(NSString *)str {
    if ((str == nil) || (str.length == 0)) return nil;
    
    const char *cStr = [str UTF8String];
    CC_LONG cLength = (CC_LONG)strlen(cStr);
    
    unsigned char result[CC_MD5_DIGEST_LENGTH] = {0};
    CC_MD5(cStr, cLength, result);
    
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    
    return hash.copy;
}

@end



#pragma mark - AFURLSessionManager (SGS)

@implementation AFURLSessionManager (SGS)


#pragma mark - Public

+ (AFURLSessionManager *)defaultSessionManager {
    static AFURLSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return manager;
}

// 添加请求并执行
- (void)executeRequest:(SGSBaseRequest *)request {
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLRequest *urlRequest = [request customURLRequest];
    
    if (urlRequest == nil) {
        urlRequest = [self p_mutableURLRequest:request useConstructingBody:YES];
    }
    
    if (urlRequest == nil) return;
    
    ProgressBlock uploadProgress = nil;
    ProgressBlock downloadProgress = nil;
    
    __weak typeof(&*self) weakSelf = self;
    
    BOOL isPostRequest = request.requestMethod == SGSRequestMethodPost;
    if (isPostRequest) {
        uploadProgress = ^(NSProgress *progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf p_handleProgress:progress request:request];
            });
        };
    } else {
        downloadProgress = ^(NSProgress *progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf p_handleProgress:progress request:request];
            });
        };
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:urlRequest
                          uploadProgress:uploadProgress
                        downloadProgress:downloadProgress
                       completionHandler:^(NSURLResponse * _Nonnull response,
                                           id  _Nullable responseObject,
                                           NSError * _Nullable error) {
                           [weakSelf p_handleResponse:dataTask object:responseObject error:error];
                       }];
    
    request.task = dataTask;
    [dataTask resume];
    
    [self p_cacheRequest:request withTask:dataTask];
}

// 添加下载
- (void)executeDownload:(SGSBaseRequest *)request {
    
    NSURLRequest *urlRequest = [request customURLRequest];
    
    if (urlRequest == nil) {
        urlRequest = [self p_mutableURLRequest:request useConstructingBody:NO];
        [(NSMutableURLRequest *)urlRequest setHTTPMethod:@"GET"];
    }
    
    if (urlRequest == nil) return;
    
    NSString *absoluteURLStr = urlRequest.URL.absoluteString;
    
    NSURLSessionTask *task = [self p_downloadTaskWithURLString:absoluteURLStr];
    
    if (task != nil) {
        // 防止重复下载
        SGSBaseRequest *old = [self p_requestWithTask:task];
        if (old != nil) {
            // 如果是同一个对象直接返回
            if (old == request) {
                if (request.task.state != NSURLSessionTaskStateRunning) {
                    [request.task resume];
                }
                return ;
            }
            
            [old clearBlock];
            old.delegate = nil;
            
            // 取消之前的请求
            if ([old.task isKindOfClass:[NSURLSessionDownloadTask class]]) {
                __weak typeof(&*self) weakSelf = self;
                [(NSURLSessionDownloadTask *)old.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    // 继续从上一次的断点数据开始
                    [weakSelf p_downloadWithResumeData:resumeData request:request originURL:absoluteURLStr];
                }];
                return ;
                
            } else {
                [old.task cancel];
            }
        }
    }
    
    
    if ([request ignoreResumeData]) {
        // 忽略断点数据，直接下载
        [self p_downloadWithMutRequest:urlRequest request:request originURL:absoluteURLStr];
        return ;
    }
    
    NSData *resumeData = [[p_ResumeDataManager sharedInstance] resumeDataWithKey:absoluteURLStr];
    
    if (resumeData != nil) {
        // 断点续传
        [self p_downloadWithResumeData:resumeData request:request originURL:absoluteURLStr];
    } else {
        // 重新创建下载请求
        [self p_downloadWithMutRequest:urlRequest request:request originURL:absoluteURLStr];;
    }
}

// 添加上传请求并执行
- (void)executeUpload:(SGSBaseRequest *)request fromFile:(NSURL *)fileURL {
    [self executeUpload:request fromObject:fileURL];
}

// 添加上传请求并执行
- (void)executeUpload:(SGSBaseRequest *)request fromData:(NSData *)bodyData {
    [self executeUpload:request fromObject:bodyData];
}

// 添加上传请求并执行
- (void)executeUpload:(SGSBaseRequest *)request fromObject:(id)object {
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLRequest *urlRequest = [request customURLRequest];
    if (urlRequest == nil) {
        urlRequest = [self p_mutableURLRequest:request useConstructingBody:NO];
        [(NSMutableURLRequest *)urlRequest setHTTPMethod:@"POST"];
    }
    
    if (urlRequest == nil) return;
    
    __weak typeof(&*self) weakSelf = self;
    ProgressBlock uploadProgress = ^(NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf p_handleProgress:progress request:request];
        });
    };
    
    __block NSURLSessionUploadTask *uploadTask = nil;
    
    if ([object isKindOfClass:[NSURL class]]) {
        
        uploadTask = [self uploadTaskWithRequest:urlRequest
                                        fromFile:object
                                        progress:uploadProgress
                               completionHandler:^(NSURLResponse * _Nonnull response,
                                                   id  _Nullable responseObject,
                                                   NSError * _Nullable error) {
                                   [weakSelf p_handleResponse:uploadTask object:responseObject error:error];
                               }];
        
    } else {
        uploadTask = [self uploadTaskWithRequest:urlRequest
                                        fromData:object
                                        progress:uploadProgress
                               completionHandler:^(NSURLResponse * _Nonnull response,
                                                   id  _Nullable responseObject,
                                                   NSError * _Nullable error) {
                                   [weakSelf p_handleResponse:uploadTask object:responseObject error:error];
                               }];
    }
    
    request.task = uploadTask;
    [uploadTask resume];
    
    [self p_cacheRequest:request withTask:uploadTask];
}

// 取消请求
- (void)cancelRequest:(SGSBaseRequest *)request {
    NSURLSessionTask *task = request.task;
    
    if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        [(NSURLSessionDownloadTask *)task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {}];
    } else {
        [task cancel];
    }
    
    [self p_removeRequestWithTask:task];
}

// 清除所有的断点数据
+ (void)clearAllResumeDataWithCompletionHandler:(void (^)(BOOL))handler {
    [[p_ResumeDataManager sharedInstance] clearAllResumeDataWithCompletionHandler:handler];
}

// 取消
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)invalidateSessionCancelingTasks:(BOOL)cancelPendingTasks {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (cancelPendingTasks) {
            [self.session invalidateAndCancel];
        } else {
            [self.session finishTasksAndInvalidate];
        }
        
        NSLock *requestLock = self.requestLock;
        [requestLock lock];
        [self.requestsRecord removeAllObjects];
        [requestLock unlock];
        
        NSLock *downloadLock = self.downloadLock;
        [downloadLock lock];
        [self.downloadRecord removeAllObjects];
        [downloadLock unlock];
    });
}
#pragma clang diagnostic pop

#pragma mark - Download

/// 下载
- (void)p_downloadWithMutRequest:(NSURLRequest *)urlRequest
                         request:(SGSBaseRequest *)request
                       originURL:(NSString *)originURL
{
    __block NSURLSessionTask *task = nil;
    __weak typeof(&*self) weakSelf = self;
    
    task = [self downloadTaskWithRequest:urlRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        // 主线程中回调进度
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf p_handleProgress:downloadProgress request:request];
        });
        
    } destination:request.downloadTargetPath completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSURLSessionTask *downloadTask = [weakSelf p_downloadTaskWithURLString:originURL];
        
        if (downloadTask.taskIdentifier == task.taskIdentifier) {
            [[p_ResumeDataManager sharedInstance] handleResumeDataError:error saveKey:originURL];
            [weakSelf p_removeDownloadTaskWithURLString:originURL];
        }
        
        NSData *file = [NSData dataWithContentsOfURL:filePath];
        [weakSelf p_handleResponse:task object:file error:error];
    }];
    
    request.task = task;
    [task resume];
    
    [self p_cacheDownloadTask:task withURLString:originURL];
    [self p_cacheRequest:request withTask:task];
}

// 断点续传
- (void)p_downloadWithResumeData:(NSData *)data
                         request:(SGSBaseRequest *)request
                       originURL:(NSString *)originURL
{
    __block NSURLSessionTask *task = nil;
    __weak typeof(&*self) weakSelf = self;
    
    task = [self downloadTaskWithResumeData:data progress:^(NSProgress * _Nonnull downloadProgress) {
        // 主线程中回调进度
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf p_handleProgress:downloadProgress request:request];
        });
        
    } destination:request.downloadTargetPath completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSURLSessionTask *downloadTask = [weakSelf p_downloadTaskWithURLString:originURL];
        
        if (downloadTask.taskIdentifier == task.taskIdentifier) {
            [[p_ResumeDataManager sharedInstance] handleResumeDataError:error saveKey:originURL];
            [weakSelf p_removeDownloadTaskWithURLString:originURL];
        }
        
        NSData *file = [NSData dataWithContentsOfURL:filePath];
        [weakSelf p_handleResponse:task object:file error:error];
    }];
    
    request.task = task;
    [task resume];
    
    [self p_cacheDownloadTask:task withURLString:originURL];
    [self p_cacheRequest:request withTask:task];
}


#pragma mark - Private Helper

- (NSMutableURLRequest *)p_mutableURLRequest:(SGSBaseRequest *)request
                         useConstructingBody:(BOOL)useConstructingBody
{
    NSString *httpMethod = nil;
    switch (request.requestMethod) {
        case SGSRequestMethodGet:
            httpMethod = @"GET";
            break;
        case SGSRequestMethodPost:
            httpMethod = @"POST";
            break;
        case SGSRequestMethodHead:
            httpMethod = @"HEAD";
            break;
        case SGSRequestMethodPut:
            httpMethod = @"PUT";
            break;
        case SGSRequestMethodPatch:
            httpMethod = @"PATCH";
            break;
        case SGSRequestMethodDelete:
            httpMethod = @"DELETE";
            break;
        default:
            httpMethod = @"GET";
            break;
    }
    
    AFHTTPRequestSerializer *requestSerializer = nil;
    
    // 请求序列化类型
    switch ([request requestSerializerType]) {
        case SGSRequestSerializerTypeJSON:
            requestSerializer = [AFJSONRequestSerializer serializer];
            break;
            
        case SGSRequestSerializerTypePropertyList:
            requestSerializer = [AFPropertyListRequestSerializer serializer];
            break;
            
        case SGSRequestSerializerTypeForm:
        default:
            requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    
    // 缓存策略
    requestSerializer.cachePolicy = [request cachePolicy];
    
    // 请求超时
    requestSerializer.timeoutInterval = [request requestTimeout];
    
    // 网络服务类型
    requestSerializer.networkServiceType = [request networkServiceType];
    
    // 是否允许蜂窝网络
    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];
    
    // 是否允许 cookies
    requestSerializer.HTTPShouldHandleCookies = [request HTTPShouldHandleCookies];
    
    // 是否等待上一个的响应
    requestSerializer.HTTPShouldUsePipelining = [request HTTPShouldUsePipelining];
    
    // 认证
    NSString *username = [request authorizationUsername];
    NSString *password = [request authorizationPassword];
    
    if ((username != nil) && (password != nil)) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
    }
    
    // 自定义请求头参数
    NSDictionary *headers = [request requestHeaders];
    
    if (headers != nil) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
                [requestSerializer setValue:key forHTTPHeaderField:obj];
            }
        }];
    }
    
    NSMutableURLRequest *mutRequest = nil;
    NSError *error = nil;
    
    if (useConstructingBody && (request.requestMethod == SGSRequestMethodPost) && ([request constructingBodyBlock] != nil)) {
        mutRequest = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[request originURLString] parameters:[request requestParameters] constructingBodyWithBlock:[request constructingBodyBlock] error:&error];
    } else {
        mutRequest = [requestSerializer requestWithMethod:httpMethod URLString:[request originURLString] parameters:[request requestParameters] error:&error];
    }
    
    if (error != nil) {
        request.error = error;
        __weak typeof(&*self) weakSelf = self;
        dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
            [weakSelf p_requestWillStop:request];
            [weakSelf p_requestFailure:request];
            [weakSelf p_requestDidStop:request];
            [request clearBlock];
        });
    }
    
    return mutRequest;
}

/// 处理响应结果
- (void)p_handleResponse:(NSURLSessionTask *)task object:(id)object error:(NSError *)error {
    SGSBaseRequest *request = [self p_popRequestWithTask:task];
    
    if (request != nil) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        request.response = response;
        request.responseData = object;
        request.error = error;
        
        [request requestCompleteFilter];
        
        [self p_requestWillStop:request];
        
        if (request.error != nil) {
            [self p_requestFailure:request];
        } else {
            [self p_requestSuccess:request];
        }
        
        [self p_requestDidStop:request];
        
        // 主动清空回调，打破保留环
        [request clearBlock];
    }
}

/// 处理进度
- (void)p_handleProgress:(NSProgress *)progress request:(SGSBaseRequest *)request {
    
    if (request.progressBlock != nil) {
        request.progressBlock(request, progress);
    }
    
    if ((request.delegate != nil) && [request.delegate respondsToSelector:@selector(request:progress:)]) {
        [request.delegate request:request progress:progress];
    }
}

/// 请求即将停止
- (void)p_requestWillStop:(SGSBaseRequest *)request {
    if (request.requestWillStopBlock != nil) {
        request.requestWillStopBlock(request);
    }
    
    if ((request.delegate != nil) && [request.delegate respondsToSelector:@selector(requestWillStop:)]) {
        [request.delegate requestWillStop:request];
    }
}

/// 请求失败
- (void)p_requestFailure:(SGSBaseRequest *)request {
    if (request.failureCompletionBlock != nil) {
        request.failureCompletionBlock(request);
    }
    
    if ((request.delegate != nil) && [request.delegate respondsToSelector:@selector(requestFailed:)]) {
        [request.delegate requestFailed:request];
    }
}

/// 请求成功
- (void)p_requestSuccess:(SGSBaseRequest *)request {
    if (request.successCompletionBlock != nil) {
        request.successCompletionBlock(request);
    }
    
    if ((request.delegate != nil) && [request.delegate respondsToSelector:@selector(requestSuccess:)]) {
        [request.delegate requestSuccess:request];
    }
}

/// 请求已经停止
- (void)p_requestDidStop:(SGSBaseRequest *)request {
    if (request.requestDidStopBlock != nil) {
        request.requestDidStopBlock(request);
    }
    
    if ((request.delegate != nil) && [request.delegate respondsToSelector:@selector(requestDidStop:)]) {
        [request.delegate requestDidStop:request];
    }
}

/// 弹出下载task
- (NSURLSessionTask *)p_popDownloadTaskWithURLString:(NSString *)str {
    if (str == nil) return nil;
    
    NSLock *lock = self.downloadLock;
    NSMutableDictionary *downloadRecord = self.downloadRecord;
    NSURLSessionTask *task = nil;
    
    [lock lock];
    task = downloadRecord[str];
    [downloadRecord removeObjectForKey:str];
    [lock unlock];
    
    return task;
}

/// 获取下载task
- (NSURLSessionTask *)p_downloadTaskWithURLString:(NSString *)str {
    if (str == nil) return nil;
    
    NSLock *lock = self.downloadLock;
    [lock lock];
    NSURLSessionTask *task = self.downloadRecord[str];
    [lock unlock];
    
    return task;
}

/// 缓存下载task
- (void)p_cacheDownloadTask:(NSURLSessionTask *)task withURLString:(NSString *)str {
    if (str != nil) {
        NSLock *lock = self.downloadLock;
        [lock lock];
        self.downloadRecord[str] = task;
        [lock unlock];
    }
}

/// 移除下载task
- (void)p_removeDownloadTaskWithURLString:(NSString *)str {
    if (str != nil) {
        NSLock *lock = self.downloadLock;
        [lock lock];
        [self.downloadRecord removeObjectForKey:str];
        [lock unlock];
    }
}

/// 弹出请求
- (SGSBaseRequest *)p_popRequestWithTask:(NSURLSessionTask *)task {
    if (task == nil) return nil;
    
    NSString *key = @(task.taskIdentifier).description;
    NSLock *lock = self.requestLock;
    NSMutableDictionary *requestsRecord = self.requestsRecord;
    SGSBaseRequest *request = nil;
    
    [lock lock];
    request = requestsRecord[key];
    [requestsRecord removeObjectForKey:key];
    [lock unlock];
    
    return request;
}

/// 获取请求
- (SGSBaseRequest *)p_requestWithTask:(NSURLSessionTask *)task {
    if (task == nil) return nil;
    
    NSString *key = @(task.taskIdentifier).description;
    NSLock *lock = self.requestLock;
    [lock lock];
    SGSBaseRequest *request =  self.requestsRecord[key];
    [lock unlock];
    
    return request;
}

/// 缓存请求
- (void)p_cacheRequest:(SGSBaseRequest *)request withTask:(NSURLSessionTask *)task {
    if (task != nil) {
        NSString *key = @(task.taskIdentifier).description;
        NSLock *lock = self.requestLock;
        [lock lock];
        self.requestsRecord[key] = request;
        [lock unlock];
    }
}

/// 移除请求
- (void)p_removeRequestWithTask:(NSURLSessionTask *)task {
    if (task != nil) {
        NSString *key = @(task.taskIdentifier).description;
        NSLock *lock = self.requestLock;
        [lock lock];
        [self.requestsRecord removeObjectForKey:key];
        [lock unlock];
    }
}

#pragma mark - getter

- (NSMutableDictionary *)requestsRecord {
    NSMutableDictionary *result = objc_getAssociatedObject(self, &kRequestsRecordKey);
    if (result == nil) {
        result = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kRequestsRecordKey, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (NSMutableDictionary *)downloadRecord {
    NSMutableDictionary *result = objc_getAssociatedObject(self, &kDownloadRecordKey);
    if (result == nil) {
        result = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kDownloadRecordKey, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (NSLock *)requestLock {
    NSLock *result = objc_getAssociatedObject(self, &kRequestLockKey);
    if (result == nil) {
        result = [[NSLock alloc] init];
        objc_setAssociatedObject(self, &kRequestLockKey, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (NSLock *)downloadLock {
    NSLock *result = objc_getAssociatedObject(self, &kDownloadLockKey);
    if (result == nil) {
        result = [[NSLock alloc] init];
        objc_setAssociatedObject(self, &kDownloadLockKey, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

@end
