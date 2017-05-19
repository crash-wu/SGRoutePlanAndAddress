/*!
 @header SGSBatchRequest.h
 
 @abstract 批处理请求
 
 @author Created by Lee on 16/8/15.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import <Foundation/Foundation.h>

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class SGSBaseRequest;
@class SGSBatchRequest;

#pragma mark - SGSBatchRequestDelegate

/*!
 *  @protocol SGSBatchRequestDelegate
 *  
 *  @abstract 批处理请求代理协议
 */
@protocol SGSBatchRequestDelegate <NSObject>

@optional

/*!
 *  @abstract 所有请求全部处理完成
 *
 *  @discussion 根据 `stopRequestWhenOneOfBatchFails` 不同会有不同的调用情况:
 *      - YES：只有所有请求都响应成功时才会调用，当其中某个请求失败时调用 `batchRequestFailed:failedRequest:`
 *      - NO：所有请求全部处理完毕时回调，无论它们请求成功或失败
 *
 *  @param batchRequest 批处理
 */
- (void)batchRequestFinished:(SGSBatchRequest *)batchRequest;

/*!
 *  @abstract 某个请求处理失败
 *
 *  @discussion 只有 `stopRequestWhenOneOfBatchFails` 为 YES 时才会调
 *
 *  @param batchRequest 批处理
 *  @param request      失败的HTTP请求
 */
- (void)batchRequestFailed:(SGSBatchRequest *)batchRequest
         failedRequest:(__kindof SGSBaseRequest *)request;;

@end



#pragma mark - SGSBatchRequest

/*!
 *  @abstract 批处理请求
 */
@interface SGSBatchRequest : NSObject

/*!
 *  @abstract 唯一标识，可以自行设定
 */
@property (nonatomic, assign) NSInteger identifier;

/*!
 *  @abstract 请求数组，内容为需要批处理的请求
 */
@property (nonatomic, strong, readonly) NSArray<__kindof SGSBaseRequest *> *requestArray;

/*!
 *  @abstract 批处理请求代理
 */
@property (nullable, nonatomic, weak) id<SGSBatchRequestDelegate> delegate;

/*!
 *  @abstract 当批处理中有一个失败时，停止其他请求，默认为 YES
 */
@property (nonatomic, assign) BOOL stopRequestWhenOneOfBatchFails;

/*!
 *  @abstract 所有请求完毕后回调闭包
 *
 *  @discussion 根据 `stopRequestWhenOneOfBatchFails` 不同将会有不同的调用时机:
 *      - YES：所有请求都响应成功时才会调用
 *      - NO：所有请求全部处理完毕时回调，无论它们请求成功或失败
 */
@property (nullable, nonatomic, copy) void (^completionBlock)(SGSBatchRequest *batchRequest);

/*!
 *  @abstract 某个请求失败后回调的block
 *
 *  @discussion 只有 `stopRequestWhenOneOfBatchFails` 为 `YES` 并且某个请求失败后才会调用
 */
@property (nullable, nonatomic, copy) void (^failureBlock)(SGSBatchRequest *batchRequest, __kindof SGSBaseRequest *baseRequest);


/// 请使用 -initWithRequestArray: 实例化对象
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;


/*!
 *  @abstract 指定初始化方法
 *
 *  @param requestArray 待批处理的请求数组
 *
 *  @return SGSBatchRequest
 */
- (instancetype)initWithRequestArray:(NSArray<__kindof SGSBaseRequest *> *)requestArray NS_DESIGNATED_INITIALIZER;


/*!
 *  @abstract 设置回调闭包并发起批处理请求
 *
 *  @param finished 将赋值给 `completionBlock` 属性
 *  @param failure  将赋值给 `failureBlock` 属性
 */
- (void)startWithCompletionBlock:(nullable void (^)(SGSBatchRequest *batchRequest))finished
                         failure:(nullable void (^)(SGSBatchRequest *batchRequest, __kindof SGSBaseRequest *baseRequest))failure;

/*!
 *  @abstract 设置回调闭包并发起批处理请求
 *
 *  @param manager  AFURLSessionManager
 *  @param finished 将赋值给 `completionBlock` 属性
 *  @param failure  将赋值给 `failureBlock` 属性
 */
- (void)startWithSessionManager:(AFURLSessionManager *)manager
                completionBlock:(nullable void (^)(SGSBatchRequest *batchRequest))finished
                        failure:(nullable void (^)(SGSBatchRequest *batchRequest, __kindof SGSBaseRequest *baseRequest))failure;

/*!
 *  @abstract 设置回调block
 *
 *  @param finished 将赋值给 `completionBlock` 属性
 *  @param failure  将赋值给 `failureBlock` 属性
 */
- (void)setCompletionBlock:(nullable void (^)(SGSBatchRequest *batchRequest))finished
                   failure:(nullable void (^)(SGSBatchRequest *batchRequest, __kindof SGSBaseRequest *baseRequest))failure;

/*!
 *  @abstract 把block置nil来打破循环引用
 */
- (void)clearCompletionBlock;


/*!
 *  @abstract 开始执行，可通过代理方法获取完成回调
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 */
- (void)start;

/*!
 *  @abstract 开始执行，可通过代理方法获取完成回调
 *
 *  @param manager AFURLSessionManager，如果为空等同于调用 `-start` 方法
 */
- (void)startWithSessionManager:(nullable AFURLSessionManager *)manager;

/*!
 *  @abstract 停止执行，可通过代理方法获取完成回调
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
