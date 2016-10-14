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

#define kLazy(object, assignment) ((object) = (object) ?: (assignment))

static const int kManagerKey;

typedef NS_ENUM(NSInteger, kRequestType) {
    kRequestTypeRequestData =0,
    kRequestTypeDownload,
    kRequestTypeUploadFile,
    kRequestTypeUploadData,
};

AFURLSessionManager * kSharedManager() {
    static AFURLSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    
    return manager;
}


#pragma mark - SGSBaseRequest

@interface SGSBaseRequest ()
@property (nonatomic, copy,   readwrite) NSString *responseString;
@property (nonatomic, strong, readwrite) id responseJSON;
@property (nonatomic, strong, readwrite) id<SGSResponseObjectSerializable> responseObject;
@property (nonatomic, strong, readwrite) NSArray<id<SGSResponseObjectSerializable>> *responseObjectArray;
@end

@implementation SGSBaseRequest

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
        manager = kSharedManager();
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


#pragma mark - 请求参数

// 请求方法
- (SGSRequestMethod)requestMethod {
    return SGSRequestMethodGet;
}

// 请求序列化形式
- (SGSRequestSerializerType)requestSerializerType {
    return SGSRequestSerializerTypeForm;
}

// 请求基础URL
- (NSString *)baseURL {
    return nil;
}

// 请求URL
- (NSString *)requestURL {
    return @"";
}

// 请求参数
- (id)requestParameters {
    return nil;
}

// 缓存策略
- (NSURLRequestCachePolicy)cachePolicy {
    return NSURLRequestUseProtocolCachePolicy;
}

// 请求超时
- (NSTimeInterval)requestTimeout {
    return 60.0;
}

// 网络服务类型
- (NSURLRequestNetworkServiceType)networkServiceType {
    return NSURLNetworkServiceTypeDefault;
}

// 是否允许蜂窝网络传输
- (BOOL)allowsCellularAccess {
    return YES;
}

// 是否允许 cookies
- (BOOL)HTTPShouldHandleCookies {
    return YES;
}

// 是否等待之前的响应
- (BOOL)HTTPShouldUsePipelining {
    return NO;
}

// 认证用户名
- (NSString *)authorizationUsername {
    return nil;
}

// 认证密码
- (NSString *)authorizationPassword {
    return nil;
}

// 请求头
- (NSDictionary<NSString *, NSString *> *)requestHeaders {
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

// 自定义请求
- (NSURLRequest *)customURLRequest {
    return nil;
}

// 多部件表单block
- (void (^)(id<AFMultipartFormData> _Nonnull))constructingBodyBlock {
    return nil;
}

// 下载完毕后的保存路径
- (NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))downloadTargetPath {
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

// 是否忽略断点数据
- (BOOL)ignoreResumeData {
    return NO;
}

// 响应对象类型
- (Class<SGSResponseObjectSerializable>)responseObjectClass {
    return nil;
}

// 响应对象集合类型
- (Class<SGSResponseCollectionSerializable>)responseObjectArrayClass {
    return nil;
}


#pragma mark - getter & setter

- (void)setTask:(NSURLSessionTask *)task {
    _task = task;
    
    switch (_requestPriority) {
        case SGSRequestPriorityDefault:
            _task.priority = NSURLSessionTaskPriorityDefault;
            break;
            
        case SGSRequestPriorityLow:
            _task.priority = NSURLSessionTaskPriorityLow;
            break;
            
        case SGSRequestPriorityHigh:
            _task.priority = NSURLSessionTaskPriorityHigh;
            break;
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
    NSString *detailURL = self.requestURL;
    
    if ([detailURL hasPrefix:@"http"]) {
        return detailURL;
    }
    
    NSString *baseUrl;
    
    if (self.baseURL.length > 0) {
        baseUrl = self.baseURL;
    } else {
        baseUrl = [SGSHTTPConfig sharedInstance].baseURL;
    }
    
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailURL];
}


- (void)setResponseData:(NSData *)responseData {
    _responseData = responseData;
    
    _responseString      = nil;
    _responseJSON        = nil;
    _responseObject      = nil;
    _responseObjectArray = nil;
}

- (NSString *)responseString {
    return kLazy(_responseString, {
        if (self.responseData == nil) return nil;
        
        [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    });
}

- (id)responseJSON {
    return kLazy(_responseJSON, {
        if (self.responseData == nil || self.responseData.length == 0) return nil;
        
        [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
    });
}


- (id<SGSResponseObjectSerializable>)responseObject {
    return kLazy(_responseObject, {
        if (self.responseJSON == nil) return nil;
        Class<SGSResponseObjectSerializable> cls = [self responseObjectClass];
        if (cls == nil) return nil;
        
        [cls objectSerializeWithResponseObject:self.responseJSON];
    });
}

- (NSArray<id<SGSResponseObjectSerializable>> *)responseObjectArray {
    return kLazy(_responseObjectArray, {
        if (self.responseJSON == nil) return nil;
        Class<SGSResponseCollectionSerializable> cls = [self responseObjectArrayClass];
        if (cls == nil) return nil;
        
        [cls colletionSerializeWithResponseObject:self.responseJSON];
    });
}

@end
