/*!
 @header SGSBaseRequest.m
  
 @author Created by Lee on 16/8/12.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSBaseRequest.h"
#import <objc/runtime.h>
#import "SGSHTTPConfig.h"
#import "SGSRequestDelegate.h"
#import "SGSResponseSerializable.h"
#import "AFURLSessionManager+SGS.h"


static const int kManagerKey;

typedef NS_ENUM(NSInteger, kRequestType) {
    kRequestTypeRequestData =0,
    kRequestTypeDownload,
    kRequestTypeUploadFile,
    kRequestTypeUploadData,
};


@interface NSURL (SGSHTTPModule)
- (instancetype)initWithString:(NSString *)URLString relativeToURLString:(NSString *)baseURLString;
@end

@implementation NSURL (SGSHTTPModule)
- (instancetype)initWithString:(NSString *)URLString relativeToURLString:(NSString *)baseURLString {
    if (URLString.length == 0) return nil;
    
    NSURL *baseURL = nil;
    if (baseURLString.length > 0) {
        if (![baseURLString hasSuffix:@"/"]) {
            baseURLString = [baseURLString stringByAppendingString:@"/"];
        }
        baseURL = [NSURL URLWithString:baseURLString];
    }
    
    if ([URLString hasPrefix:@"/"]) {
        URLString = [URLString substringFromIndex:1];
    }
    
    return [self initWithString:URLString relativeToURL:baseURL];
}
@end


#pragma mark - SGSBaseRequest

@interface SGSBaseRequest ()
@property (nonatomic, copy,   readwrite) NSString *responseString;
@property (nonatomic, strong, readwrite) id responseJSON;
@property (nonatomic, strong, readwrite) id<SGSResponseObjectSerializable> responseObject;
@property (nonatomic, strong, readwrite) NSArray<id<SGSResponseObjectSerializable>> *responseObjectArray;
@end

@implementation SGSBaseRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString {
    return [self initWithURLString:urlString relativeToURLString:nil parameters:nil];
}

- (instancetype)initWithURLString:(NSString *)urlString parameters:(id)parameters {
    return [self initWithURLString:urlString relativeToURLString:nil parameters:parameters];
}

- (instancetype)initWithURLString:(NSString *)urlString relativeToURLString:(NSString *)baseURLString parameters:(id)parameters {
    self = [super init];
    if (self) {
        _requestURL = urlString;
        _baseURL = baseURLString;
        _requestParameters = parameters;
        [self commonInit];
    }
    return self;
}

/* 
 由于没有指定初始化方法，所以这里使用 -commontInit初始化参数，可以分别在 -init 方法和 
 -initWithURLString:relativeToURLString:parameters: 中保证相同参数的初始化
 */
- (void)commonInit {
    _requestMethod = SGSRequestMethodGet;
    _requestSerializerType = SGSRequestSerializerTypeForm;
    _cachePolicy = NSURLRequestUseProtocolCachePolicy;
    _requestTimeout = 60;
    _networkServiceType = NSURLNetworkServiceTypeDefault;
    _allowsCellularAccess = YES;
    _HTTPShouldHandleCookies = YES;
    _HTTPShouldUsePipelining = NO;
    _ignoreResumeData = NO;
}

// 开始请求
- (void)startWithCompletionSuccess:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
                           failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    [self startWithSessionManager:nil success:success failure:failure];
}

// 开始请求
- (void)startWithSessionManager:(AFURLSessionManager *)manager
                        success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
                        failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self startWithSessionManager:manager];
}

// 开始下载
- (void)downloadWithCompletionSuccess:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
                              failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    [self downloadWithSessionManager:nil success:success failure:failure];
}

// 开始下载
- (void)downloadWithSessionManager:(AFURLSessionManager *)manager
                           success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
                           failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self startDownloadWithSessionManager:manager];
}

// 上传文件
- (void)uploadWithFile:(NSURL *)fileURL
               success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
               failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    [self uploadWithSessionManager:nil fromFile:fileURL success:success failure:failure];
}

// 上传文件
- (void)uploadWithSessionManager:(AFURLSessionManager *)manager
                        fromFile:(NSURL *)fileURL
                         success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
                         failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self startUploadWithSessionManager:manager fromFile:fileURL];
}

// 上传数据
- (void)uploadWithData:(NSData *)bodyData
               success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
               failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    [self uploadWithSessionManager:nil fromData:bodyData success:success failure:failure];
}

// 上传数据
- (void)uploadWithSessionManager:(AFURLSessionManager *)manager
                        fromData:(NSData *)bodyData
                         success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
                         failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self startUploadWithSessionManager:manager fromData:bodyData];
}

// 开始请求
- (void)start {
    [self startWithSessionManager:nil];
}

// 开始请求
- (void)startWithSessionManager:(AFURLSessionManager *)manager {
    [self startWithSessionManager:manager type:kRequestTypeRequestData uploadBody:nil];
}

// 开始下载
- (void)startDownload {
    [self startDownloadWithSessionManager:nil];
}

// 开始下载
- (void)startDownloadWithSessionManager:(AFURLSessionManager *)manager {
    [self startWithSessionManager:manager type:kRequestTypeDownload uploadBody:nil];
}

// 开始上传文件
- (void)startUploadWithFile:(NSURL *)fileURL {
    [self startUploadWithSessionManager:nil fromFile:fileURL];
}

// 开始上传文件
- (void)startUploadWithSessionManager:(AFURLSessionManager *)manager fromFile:(NSURL *)fileURL {
    [self startWithSessionManager:manager type:kRequestTypeUploadFile uploadBody:fileURL];
}

// 开始上传数据
- (void)startUploadWithData:(NSData *)bodyData {
    [self startUploadWithSessionManager:nil fromData:bodyData];
}

// 开始上传数据
- (void)startUploadWithSessionManager:(AFURLSessionManager *)manager fromData:(NSData *)bodyData {
    [self startWithSessionManager:manager type:kRequestTypeUploadData uploadBody:bodyData];
}

// 开始
- (void)startWithSessionManager:(AFURLSessionManager *)manager
                           type:(kRequestType)type
                     uploadBody:(id)body
{
    if (manager == nil) {
        manager = [AFURLSessionManager defaultSessionManager];
    }
    
    if (self.requestWillStartBlock != nil) {
        self.requestWillStartBlock(self);
    }
    
    if ((self.delegate != nil) &&
        [self.delegate respondsToSelector:@selector(requestWillStart:)]) {
        [self.delegate requestWillStart:self];
    }
    
    if (self.task != nil) {
        self.task = nil;
    }
    
    switch (type) {
        case kRequestTypeRequestData:
            [manager executeRequest:self];
            break;
            
        case kRequestTypeDownload:
            [manager executeDownload:self];
            break;
            
        case kRequestTypeUploadFile:
            [manager executeUpload:self fromFile:body];
            break;
            
        case kRequestTypeUploadData:
            [manager executeUpload:self fromData:body];
            break;
    }
    
    objc_setAssociatedObject(self, &kManagerKey, manager, OBJC_ASSOCIATION_ASSIGN);
}

// 继续执行
- (void)resume {
    if (self.requestWillStartBlock != nil) {
        self.requestWillStartBlock(self);
    }
    
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(requestWillStart:)]) {
        [self.delegate requestWillStart:self];
    }
    
    if ((self.task != nil) && (self.state != NSURLSessionTaskStateRunning)) {
        [self.task resume];
    }
}


// 暂停
- (void)suspend {
    if (self.requestWillSuspendBlock != nil) {
        self.requestWillSuspendBlock(self);
    }
    
    if ((self.delegate != nil) &&
        [self.delegate respondsToSelector:@selector(requestWillSuspend:)]) {
        [self.delegate requestWillSuspend:self];
    }
    
    [self.task suspend];
    
    if (self.requestDidSuspendBlock != nil) {
        self.requestDidSuspendBlock(self);
    }
    
    if ((self.delegate != nil) &&
        [self.delegate respondsToSelector:@selector(requestDidSuspend:)]) {
        [self.delegate requestDidSuspend:self];
    }
}

// 停止
- (void)stop {
    AFURLSessionManager *manager = objc_getAssociatedObject(self, &kManagerKey);
    
    if (manager != nil) {
        if (self.requestWillStopBlock != nil) {
            self.requestWillStopBlock(self);
        }
        
        if ((self.delegate != nil) &&
            [self.delegate respondsToSelector:@selector(requestWillStop:)]) {
            [self.delegate requestWillStop:self];
        }
        
        [manager cancelRequest:self];
        
        if (self.requestDidStopBlock != nil) {
            self.requestDidStopBlock(self);
        }
        
        if ((self.delegate != nil) &&
            [self.delegate respondsToSelector:@selector(requestDidStop:)]) {
            [self.delegate requestDidStop:self];
        }
        
        [self clearBlock];
    }
}

// 设置回调闭包
- (void)setCompletionBlockWithSuccess:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
                              failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

// 清空block
- (void)clearBlock {
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
    self.requestWillStartBlock = nil;
    self.requestWillSuspendBlock = nil;
    self.requestDidSuspendBlock = nil;
    self.requestWillStopBlock = nil;
    self.requestDidStopBlock = nil;
    self.progressBlock = nil;
}

// 检查Status Code
- (BOOL)statusCodeValidator {
    if (self.response == nil) {
        return NO;
    }
    
    NSInteger statusCode = self.response.statusCode;
    
    return (statusCode >= 200 && statusCode <= 299);
}

#pragma mark - 过滤

- (void)requestCompleteFilter {
}

#pragma mark - Accessors

- (void)setTask:(NSURLSessionTask *)task {
    _task = task;
    
    if ([_task respondsToSelector:@selector(setPriority:)]) {
        switch (_requestPriority) {
            case SGSRequestPriorityDefault:
                _task.priority = 0.5;
                break;
                
            case SGSRequestPriorityLow:
                _task.priority = 0.25;
                break;
                
            case SGSRequestPriorityHigh:
                _task.priority = 0.75;
                break;
        }
    }
}

- (NSURLSessionTaskState)state {
    if (self.task == nil) {
        return NSURLSessionTaskStateSuspended;
    }
    
    return self.task.state;
}

- (NSURLRequest *)originalRequest {
    return self.task.originalRequest;
}

- (NSURLRequest *)currentRequest {
    return self.task.currentRequest;
}

- (NSString *)originURLString {
    NSString *detailURLString = self.requestURL;
    
    if ([detailURLString hasPrefix:@"http"]) {
        return detailURLString;
    }
    
    NSString *baseURLString = nil;
    
    if (self.baseURL.length > 0) {
        baseURLString = self.baseURL;
    } else {
        baseURLString = [SGSHTTPConfig sharedInstance].baseURL;
    }
    
    return [[NSURL alloc] initWithString:detailURLString relativeToURLString:baseURLString].absoluteString;
}


- (void)setResponseData:(NSData *)responseData {
    _responseData = responseData;
    
    _responseString      = nil;
    _responseJSON        = nil;
    _responseObject      = nil;
    _responseObjectArray = nil;
}

- (NSString *)responseString {
    if (_responseString == nil) {
        if (self.responseData != nil) {
            _responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        }
    }
    return _responseString;
}

- (id)responseJSON {
    if (_responseJSON == nil) {
        if (self.responseData.length != 0) {
            _responseJSON = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
        }
    }
    return _responseJSON;
}


- (id<SGSResponseObjectSerializable>)responseObject {
    if (_responseObject == nil) {
        if (self.responseJSON != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
            Class<SGSResponseObjectSerializable> cls = [self responseObjectClass];
            if ([cls respondsToSelector:@selector(objectSerializeWithResponseObject:)]) {
                _responseObject = [cls objectSerializeWithResponseObject:self.responseJSON];
            }
#pragma clang diagnostic pop
        }
    }
    return _responseObject;
}

- (NSArray<id<SGSResponseObjectSerializable>> *)responseObjectArray {
    if (_responseObjectArray == nil) {
        if (self.responseJSON != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
            Class<SGSResponseCollectionSerializable> cls = [self responseObjectArrayClass];
            if ([cls respondsToSelector:@selector(colletionSerializeWithResponseObject:)]) {
                _responseObjectArray = [cls colletionSerializeWithResponseObject:self.responseJSON];
            }
#pragma clang diagnostic pop
        }
    }
    return _responseObjectArray;
}

- (NSDictionary<NSString *, NSString *> *)requestHeaders {
    if (_requestHeaders != nil) return _requestHeaders;
    
    if (self.cachePolicy != NSURLRequestUseProtocolCachePolicy) return nil;
    
    NSURLRequest *request       = nil;
    NSCachedURLResponse *cache  = nil;
    NSDictionary *cachedHeaders = nil;
    NSMutableDictionary *header = nil;
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.originURLString]];
    cache = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
    
    if (cache != nil) {
        cachedHeaders = [(NSHTTPURLResponse *)cache.response allHeaderFields];
        header = [NSMutableDictionary dictionary];
        header[@"If-Modified-Since"] = cachedHeaders[@"Last-Modified"];
        header[@"If-None-Match"] = cachedHeaders[@"Etag"];
    }
    
    return header;
}

// 下载完毕后的保存路径
- (NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))downloadTargetPath {
    if (_downloadTargetPath != nil) return _downloadTargetPath;
    
    return ^(NSURL * location, NSURLResponse * response) {
        
        NSString      *tempDir = [SGSHTTPConfig sharedInstance].defaultDownloadsDirectory;
        NSFileManager *manager = [NSFileManager defaultManager];
        
        BOOL isDirectory      = NO;
        BOOL createDirSuccess = YES;
        
        if (![manager fileExistsAtPath:tempDir isDirectory:&isDirectory]) {
            createDirSuccess = [manager createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:NULL];
        } else {
            if (!isDirectory) {
                [manager removeItemAtPath:tempDir error:NULL];
                createDirSuccess = [manager createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:NULL];
            }
        }
        
        NSString *fileName = response.suggestedFilename;
        if (fileName == nil) fileName = @"未命名文件";
        NSURL *destination = [NSURL fileURLWithPathComponents:@[tempDir, fileName]];
        
        return (createDirSuccess ? destination : location);
    };
}

@end
