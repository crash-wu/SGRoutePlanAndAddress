/*!
 @header SGSBaseRequest+Convenient.h
 
 @abstract 网络请求便捷方法
 
 @author Created by Lee on 16/12/12.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SGSResponseSerializable;
@protocol SGSResponseObjectSerializable;
@protocol SGSResponseCollectionSerializable;

/*!
 *  @abstract 网络请求便捷方法
 */
@interface SGSBaseRequest (Convenient)

/*!
 *  @see GET:parameters:progress:responseFilter:forClass:success:failure:
 */
+ (instancetype)GET:(NSString *)URLString
            success:(nullable void (^)(__kindof SGSBaseRequest *request))success
            failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @see GET:parameters:progress:responseFilter:forClass:success:failure:
 */
+ (instancetype)GET:(NSString *)URLString
         parameters:(nullable NSDictionary *)parameters
            success:(nullable void (^)(__kindof SGSBaseRequest *request))success
            failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @see GET:parameters:progress:responseFilter:forClass:success:failure:
 */
+ (instancetype)GET:(NSString *)URLString
         parameters:(nullable NSDictionary *)parameters
     responseFilter:(nullable void (^)(__kindof SGSBaseRequest *originalResponse))filter
            success:(nullable void (^)(__kindof SGSBaseRequest *request))success
            failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @see GET:parameters:progress:responseFilter:forClass:success:failure:
 */
+ (instancetype)GET:(NSString *)URLString
         parameters:(nullable NSDictionary *)parameters
           forClass:(nullable Class<SGSResponseSerializable>)cls
            success:(nullable void (^)(__kindof SGSBaseRequest *request))success
            failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @abstract 发起 GET 请求
 *
 *  @param URLString  可以是相对路径也可以是绝对路径，如果是相对路径必须要在 SGSHTTPConfig 设置基础地址
 *  @param parameters 请求参数
 *  @param progress   请求进度
 *  @param filter     请求过滤
 *  @param cls        目标类型
 *  @param success    成功回调
 *  @param failure    失败回调
 *  @return SGSBaseRequest
 *
 *  @discussion filter 将在 success 和 failure 之前调用，只要 request.error 不为空，
 *      那么就会回调 failure 闭包，这里的 filter 是赋值给 requestWillStopBlock，
 *      因此发起请求后请谨慎赋值 requestWillStopBlock 属性
 */
+ (instancetype)GET:(NSString *)URLString
         parameters:(nullable NSDictionary *)parameters
           progress:(nullable void (^)(__kindof SGSBaseRequest *request, NSProgress *progress))progress
     responseFilter:(nullable void (^)(__kindof SGSBaseRequest *originalResponse))filter
           forClass:(nullable Class<SGSResponseSerializable>)cls
            success:(nullable void (^)(__kindof SGSBaseRequest *request))success
            failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @see POST:parameters:progress:responseFilter:forClass:success:failure:
 */
+ (instancetype)POST:(NSString *)URLString
          parameters:(nullable NSDictionary *)parameters
             success:(nullable void (^)(__kindof SGSBaseRequest *request))success
             failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @see POST:parameters:progress:responseFilter:forClass:success:failure:
 */
+ (instancetype)POST:(NSString *)URLString
          parameters:(nullable NSDictionary *)parameters
      responseFilter:(nullable void (^)(__kindof SGSBaseRequest *originalResponse))filter
             success:(nullable void (^)(__kindof SGSBaseRequest *request))success
             failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @see POST:parameters:progress:responseFilter:forClass:success:failure:
 */
+ (instancetype)POST:(NSString *)URLString
          parameters:(nullable NSDictionary *)parameters
            forClass:(nullable Class<SGSResponseSerializable>)cls
             success:(nullable void (^)(__kindof SGSBaseRequest *request))success
             failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @abstract 发起 POST 请求
 *
 *  @param URLString  可以是相对路径也可以是绝对路径，如果是相对路径必须要在 SGSHTTPConfig 设置基础地址
 *  @param parameters 请求参数
 *  @param progress   请求进度
 *  @param filter     请求过滤
 *  @param cls        目标类型
 *  @param success    成功回调
 *  @param failure    失败回调
 *  @return SGSBaseRequest
 *
 *  @discussion filter 将在 success 和 failure 之前调用，只要 request.error 不为空，
 *      那么就会回调 failure 闭包，这里的 filter 是赋值给 requestWillStopBlock，
 *      因此发起请求后请谨慎赋值 requestWillStopBlock 属性
 */
+ (instancetype)POST:(NSString *)URLString
          parameters:(nullable NSDictionary *)parameters
            progress:(nullable void (^)(__kindof SGSBaseRequest *request, NSProgress *progress))progress
      responseFilter:(nullable void (^)(__kindof SGSBaseRequest *originalResponse))filter
            forClass:(nullable Class<SGSResponseSerializable>)cls
             success:(nullable void (^)(__kindof SGSBaseRequest *request))success
             failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

/*!
 *  @abstract 发起请求
 *
 *  @param URLString  可以是相对路径也可以是绝对路径，如果是相对路径必须要在 SGSHTTPConfig 设置基础地址
 *  @param method     请求方法类型
 *  @param parameters 请求参数
 *  @param progress   请求进度
 *  @param filter     请求过滤
 *  @param cls        目标类型
 *  @param success    成功回调
 *  @param failure    失败回调
 *  @return SGSBaseRequest
 *
 *  @discussion filter 将在 success 和 failure 之前调用，只要 request.error 不为空，
 *      那么就会回调 failure 闭包，这里的 filter 是赋值给 requestWillStopBlock，
 *      因此发起请求后请谨慎赋值 requestWillStopBlock 属性
 */
+ (instancetype)requestWithURL:(NSString *)URLString
                    httpMethod:(SGSRequestMethod)method
                    parameters:(nullable NSDictionary *)parameters
                      progress:(nullable void (^)(__kindof SGSBaseRequest *request, NSProgress *progress))progress
                responseFilter:(nullable void (^)(__kindof SGSBaseRequest *originalResponse))filter
                      forClass:(nullable Class<SGSResponseSerializable>)cls
                       success:(nullable void (^)(__kindof SGSBaseRequest *request))success
                       failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;

@end

NS_ASSUME_NONNULL_END
