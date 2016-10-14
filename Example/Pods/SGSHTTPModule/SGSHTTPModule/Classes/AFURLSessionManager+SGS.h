/*!
 @header AFURLSessionManager+SGS.h
 
 @abstract
 
 @author Created by Lee on 16/9/20.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@class SGSBaseRequest;

NS_ASSUME_NONNULL_BEGIN

@interface AFURLSessionManager (SGS)

/*!
 *  @abstract 执行请求任务
 *
 *  @discussion 该方法会将 `responseSerializer` 改为 `[AFHTTPResponseSerializer serializer]`
 *
 *  @param request 请求任务
 */
- (void)executeRequest:(SGSBaseRequest *)request;

/*!
 *  @abstract 执行下载任务
 *
 *  @param request 下载任务
 */
- (void)executeDownload:(SGSBaseRequest *)request;

/*!
 *  @brief 执行上传任务
 *
 *  @param request 上传任务
 *  @param fileURL 待上传的文件地址
 */
- (void)executeUpload:(SGSBaseRequest *)request fromFile:(NSURL *)fileURL;

/*!
 *  @brief 执行上传任务
 *
 *  @param request  上传任务
 *  @param bodyData 待上传的数据
 */
- (void)executeUpload:(SGSBaseRequest *)request fromData:(NSData *)bodyData;

/*!
 *  @abstract 取消请求
 *
 *  @param request 待取消的请求
 */
- (void)cancelRequest:(SGSBaseRequest *)request;

/*!
 *  @abstract 移除所有断点数据（包括缓存和磁盘）
 *
 *  @param handler 执行完毕后回调，移除成功回调 `YES` ，移除失败回调 `NO`
 */
+ (void)clearAllResumeDataWithCompletionHandler:(nullable void (^)(BOOL))handler;

@end

NS_ASSUME_NONNULL_END