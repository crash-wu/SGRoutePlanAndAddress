/*!
 @header SGSChainRequest.m
  
 @author Created by Lee on 16/8/16.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSChainRequest.h"
#import "SGSRequestDelegate.h"
#import "SGSBaseRequest.h"
#import <pthread.h>

#pragma mark - p_ChainRequestManager

/**
 *  链式请求管理类
 */
@interface p_ChainRequestManager : NSObject
+ (instancetype)sharedInstance;
- (void)addChainRequest:(SGSChainRequest *)request;
- (void)removeChainRequest:(SGSChainRequest *)request;
@end


@implementation p_ChainRequestManager {
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

- (void)addChainRequest:(SGSChainRequest *)request {
    pthread_mutex_lock(&_lock);
    [_requestsRecord addObject:request];
    pthread_mutex_unlock(&_lock);
}

- (void)removeChainRequest:(SGSChainRequest *)request {
    pthread_mutex_lock(&_lock);
    [_requestsRecord removeObject:request];
    pthread_mutex_unlock(&_lock);
}

@end


#pragma mark - SGSChainRequest

@interface SGSChainRequest () <SGSRequestDelegate>
@property (nonatomic, strong) NSMutableArray<__kindof SGSBaseRequest *> *requestArray;
@property (nonatomic, strong) NSMutableArray *requestCallbackArray;
@property (nonatomic, assign) NSUInteger nextRequestIndex;
@property (nonatomic, copy  ) ChainCallback emptyCallback;
@property (nonatomic, weak  ) AFURLSessionManager *manager;
@property (nonatomic, assign) BOOL isRun;
@end

@implementation SGSChainRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
        _requestCallbackArray = [NSMutableArray array];
        _nextRequestIndex = 0;
        _isRun = NO;
        
        // 用于填充callback数组，使其个数与request数组对齐
        _emptyCallback = ^(SGSChainRequest *chainRequest, SGSBaseRequest *baseRequest) {};
    }
    return self;
}

- (void)start {
    [self startWithManager:nil];
}

- (void)startWithManager:(AFURLSessionManager *)manager {
    if (_isRun) return;
    if (_requestArray.count == 0) return;
    
    _manager = manager;
    [self p_startNextRequest];
    [[p_ChainRequestManager sharedInstance] addChainRequest:self];
    _isRun = YES;
}

- (void)stop {
    [self p_clearRequest];
    [[p_ChainRequestManager sharedInstance] removeChainRequest:self];
    _isRun = NO;
}

- (void)addRequest:(__kindof SGSBaseRequest *)request callback:(ChainCallback)callback {
    [_requestArray addObject:request];
    
    if (callback == nil) {
        // 插入空回调，使其个数与request数组对齐
        [_requestCallbackArray addObject:_emptyCallback];
    } else {
        [_requestCallbackArray addObject:callback];
    }
}

- (NSArray<SGSBaseRequest *> *)requestQueue {
    return _requestArray.copy;
}

#pragma mark - Private Helper

// 执行下一个请求
- (BOOL)p_startNextRequest {
    if (_nextRequestIndex < _requestArray.count) {
        SGSBaseRequest *request = _requestArray[_nextRequestIndex];
        request.delegate = self;
        
        if (_manager == nil) {
            [request start];
        } else {
            [request startWithSessionManager:_manager];
        }
        
        _nextRequestIndex++;
        
        return YES;
    }
    
    return NO;
}

// 清空请求
- (void)p_clearRequest {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    if (currentRequestIndex < _requestArray.count) {
        SGSBaseRequest *request = _requestArray[_nextRequestIndex];
        [request stop];
    }
    
    [_requestArray removeAllObjects];
    [_requestCallbackArray removeAllObjects];
}

#pragma mark - SGSRequestDelegate

// 请求成功
- (void)requestSuccess:(SGSBaseRequest *)request {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    
    ChainCallback callback = _requestCallbackArray[currentRequestIndex];
    callback(self, request);
    
    if (![self p_startNextRequest]) {
        [[p_ChainRequestManager sharedInstance] removeChainRequest:self];
        
        if ((self.delegate != nil) &&
            [self.delegate respondsToSelector:@selector(chainRequestFinished:)]) {
            [self.delegate chainRequestFinished:self];
        }
        _isRun = NO;
    }
}

// 请求失败
- (void)requestFailed:(SGSBaseRequest *)request {
    _nextRequestIndex--;
    
    [[p_ChainRequestManager sharedInstance] removeChainRequest:self];
    
    if ((self.delegate != nil) &&
        [self.delegate respondsToSelector:@selector(chainRequestFailed:failedBaseRequest:)]) {
        [self.delegate chainRequestFailed:self failedBaseRequest:request];
    }
    _isRun = NO;
}

@end
