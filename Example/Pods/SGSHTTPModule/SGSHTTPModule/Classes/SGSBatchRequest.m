/*!
 @header SGSBatchRequest.m
  
 @author Created by Lee on 16/8/15.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSBatchRequest.h"
#import "SGSRequestDelegate.h"
#import "SGSBaseRequest.h"
#import <pthread.h>

#pragma mark - p_BatchRequestManager

/**
 *  批处理请求管理类
 */
@interface p_BatchRequestManager : NSObject
+ (instancetype)sharedInstance;
- (void)addBatchRequest:(SGSBatchRequest *)request;
- (void)removeBatchRequest:(SGSBatchRequest *)request;
@end


@implementation p_BatchRequestManager {
    NSMutableArray *_requestsRecord;
    pthread_mutex_t _lock;
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
        _requestsRecord = [NSMutableArray array];
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

- (void)addBatchRequest:(SGSBatchRequest *)request {
    pthread_mutex_lock(&_lock);
    [_requestsRecord addObject:request];
    pthread_mutex_unlock(&_lock);
}

- (void)removeBatchRequest:(SGSBatchRequest *)request {
    pthread_mutex_lock(&_lock);
    [_requestsRecord removeObject:request];
    pthread_mutex_unlock(&_lock);
}

@end



#pragma mark - SGSBatchRequest

@interface SGSBatchRequest () <SGSRequestDelegate>
@property (nonatomic, assign) NSUInteger finishedCount;
@property (nonatomic, assign) BOOL isRun;
@end

@implementation SGSBatchRequest

- (instancetype)initWithRequestArray:(NSArray<SGSBaseRequest *> *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = requestArray.copy;
        _finishedCount = 0;
        _stopRequestWhenOneOfBatchFails = YES;
        _isRun = NO;
    }
    return self;
}

- (void)dealloc {
    [self p_clearRequest];
}

- (void)startWithCompletionBlock:(void (^)(SGSBatchRequest * _Nonnull))finished
                         failure:(void (^)(SGSBatchRequest * _Nonnull,
                                           __kindof SGSBaseRequest * _Nonnull))failure
{
    [self setCompletionBlock:finished failure:failure];
    [self start];
}

- (void)startWithSessionManager:(AFURLSessionManager *)manager
                completionBlock:(void (^)(SGSBatchRequest * _Nonnull))finished
                        failure:(void (^)(SGSBatchRequest * _Nonnull,
                                          __kindof SGSBaseRequest * _Nonnull))failure
{
    [self setCompletionBlock:finished failure:failure];
    [self startWithSessionManager:manager];
}

- (void)setCompletionBlock:(void (^)(SGSBatchRequest * _Nonnull))finished
                   failure:(void (^)(SGSBatchRequest * _Nonnull,
                                     __kindof SGSBaseRequest * _Nonnull))failure
{
    self.completionBlock = finished;
    self.failureBlock = failure;
}

- (void)clearCompletionBlock {
    self.completionBlock = nil;
    self.failureBlock = nil;
}

- (void)start {
    [self startWithSessionManager:nil];
}

- (void)startWithSessionManager:(AFURLSessionManager *)manager {
    if (_isRun) return;
    if (_finishedCount > 0) return;
    
    if (_requestArray.count == 0) return;
    
    [[p_BatchRequestManager sharedInstance] addBatchRequest:self];
    
    for (SGSBaseRequest *request in _requestArray) {
        request.delegate = self;
        if (manager == nil) {
            [request start];
        } else {
            [request startWithSessionManager:manager];
        }
    }
    _isRun = YES;
}

- (void)stop {
    [self p_clearRequest];
    [[p_BatchRequestManager sharedInstance] removeBatchRequest:self];
    _isRun = NO;
}

#pragma mark - Private Helper
- (void)p_clearRequest {
    for (SGSBaseRequest *request in _requestArray) {
        [request stop];
    }
    [self clearCompletionBlock];
}

#pragma mark - SGSRequestDelegate

- (void)requestSuccess:(SGSBaseRequest *)request {
    _finishedCount++;
    if (_finishedCount == _requestArray.count) {
        [[p_BatchRequestManager sharedInstance] removeBatchRequest:self];
        
        if (self.completionBlock != nil) {
            self.completionBlock(self);
        }
        
        if ((self.delegate != nil) &&
            [self.delegate respondsToSelector:@selector(batchRequestFinished:)]) {
            [self.delegate batchRequestFinished:self];
        }
        
        [self clearCompletionBlock];
        _isRun = NO;
    }
}

- (void)requestFailed:(SGSBaseRequest *)request {
    if (!self.stopRequestWhenOneOfBatchFails) {
        _finishedCount++;
        return ;
    }
    
    for (SGSBaseRequest *request in _requestArray) {
        [request stop];
    }
    
    [[p_BatchRequestManager sharedInstance] removeBatchRequest:self];
    
    if (self.failureBlock != nil) {
        self.failureBlock(self, request);
    }
    
    if ((self.delegate != nil) &&
        [self.delegate respondsToSelector:@selector(batchRequestFailed:failedRequest:)]) {
        [self.delegate batchRequestFailed:self failedRequest:request];
    }
    
    [self clearCompletionBlock];
    _isRun = NO;
}
@end
