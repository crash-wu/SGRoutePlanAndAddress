/*!
 @header SGSChainRequest.h
 
 @abstract 依赖性请求
 
 @author Created by Lee on 16/8/16.
 
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
@class SGSChainRequest;

#pragma mark - SGSChainRequestDelegate

/*!
 *  @protocol SGSChainRequestDelegate
 *
 *  @abstract 链式请求代理协议
 */
@protocol SGSChainRequestDelegate <NSObject>

@optional

/*!
 *  @abstract 链式请求全部执行完毕
 *
 *  @param chainRequest 链式请求
 */
- (void)chainRequestFinished:(SGSChainRequest *)chainRequest;

/*!
 *  @abstract 某个请求处理失败的代理方法
 *
 *  @param chainRequest 链式请求
 *  @param request      HTTP请求
 */
- (void)chainRequestFailed:(SGSChainRequest *)chainRequest
         failedBaseRequest:(__kindof SGSBaseRequest *)request;

@end


#pragma mark - typedef

/*!
 *  @abstract 链式请求回调闭包
 *
 *  @param chainRequest 链式请求
 *  @param baseRequest  具体的请求
 */
typedef void (^ChainCallback)(SGSChainRequest *chainRequest, __kindof SGSBaseRequest *baseRequest);



#pragma mark - SGSChainRequest

/*!
 *  @abstract 链式请求
 *
 *  @discussion 各请求有相互依赖时，可以使用该类来实现
 *      链式请求将依次发起HTTP请求，当前一个请求有响应的时候再执行下一个
 *      当中途某个请求失败的时候，后面的请求都将不会执行，但是请求队列依然保持着
 */
@interface SGSChainRequest : NSObject

/*!
 *  @abstract 代理
 */
@property (nullable, nonatomic, weak) id<SGSChainRequestDelegate> delegate;

/*!
 *  @abstract 开始执行链式请求
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 */
- (void)start;

/*!
 *  @abstract 开始执行链式请求
 *
 *  @param manager AFURLSessionManager，如果为空等同于调用 `-start` 方法
 */
- (void)startWithManager:(nullable AFURLSessionManager *)manager;

/*!
 *  @abstract 终止链式请求
 */
- (void)stop;

/*!
 *  @abstract 添加请求
 *
 *  @discussion 添加的请求成功返回时，将会执行 `callback`，如果请求失败，将会执行链式请求的失败代理方法
 *
 *  @param request  待处理的请求
 *  @param callback 添加的请求响应成功时回调的闭包
 */
- (void)addRequest:(__kindof SGSBaseRequest *)request callback:(nullable ChainCallback)callback;

/*!
 *  @abstract 请求队列
 *
 *  @return 请求队列
 */
- (NSArray<__kindof SGSBaseRequest *> *)requestQueue;

@end

NS_ASSUME_NONNULL_END
