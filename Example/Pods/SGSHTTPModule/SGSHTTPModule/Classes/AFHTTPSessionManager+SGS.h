/*!
 *  @header AFHTTPSessionManager+SGS.h
 *
 *  @abstract AF原生方法扩展
 *
 *  @discussion 在 `AFHTTPSessionManager` 和 `AFURLSessionManager` 的部分方法基础上添加了请求结果过滤闭包和请求结果转模型对象类两个参数，其余不变
 *
 *   在请求不太复杂时，可以继续沿用 `AFNetworking` 的原生接口，避免每个请求都需要封装一个对象的麻烦
 *
 *  例如:
 *
 *  @code
 *      登录成功后返回用户信息:
 *          {
 *              "code": 自定义状态码
 *              "description": 错误描述信息
 *              "results": 用户信息
 *          }
 *
 *      ======================== 用户信息模型 =======================
 *      @interface AccountInfo : NSObject <SGSResponseObjectSerializable>
 *      @property (nonatomic, copy) NSString *userID;
 *      @property (nonatomic, copy) NSString *userName;
 *      @property (nonatomic, copy) NSString *loginName;
 *      @end
 *
 *      @implementation
 *      + (id<SGSResponseObjectSerializable>)objectSerializeWithResponseObject:(id)object {
 *          return [AccountInfo yy_modelWithJSON:object];
 *      }
 *      @end
 *
 *      ======================== 登录 =======================
 *      - (void)loginWithUsername:(NSString *)username password:(NSString *)password {
 *          NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", password, @"password", nil];
 *
 *          AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
 *
 *          // AFNetworking 响应头默认接收JSON的 Content-Type 为 "application/json", "text/json", "text/javascript"
 *          // 如果服务器响应头返回的不是这些格式，并且内容还是 JSON 数据的话，那么应该把这个属性设置为 nil 或者添加服务器返回的类型
 *          manager.responseSerializer.acceptableContentTypes = nil;
 *
 *          // AF的返回格式默认就是JSON，如果希望返回其他格式的可以自行设定
 *          // manager.responseSerializer = [AFJSONResponseSerializer serializer];
 *
 *          [manager GET:@"http://192.168.10.10/appServer/userLogin"
 *            parameters:params
 *              progress:nil
 *        responseFilter:[AFHTTPSessionManager defaultResponseFilter]
 *              forClass:[AccountInfo class]
 *               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
 *
 *                  // 请求成功
 *                  AccountInfo *account = (AccountInfo *)responseObject;
 *                  [self handlerAccount:account];
 *
 *          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
 *                  // 请求失败
 *          }];
 *      }
 *  @endcode
 *
 *  responseFilter: 这里的登录请求使用默认提供的过滤闭包，也可以使用自定义的格式过滤，过滤闭包中只要返回 NSError 类型对象，那么将会被判断为请求失败
 *      如果该参数传入nil则不进行过滤，直接使用 `AFNetworking` 返回的数据
 *
 *  forClass: 用于将响应数据转换为模型对象，传入的类型需要实现 `SGSResponseObjectSerializable` 或 `SGSResponseCollectionSerializable`协议
 *      当转换失败时，将判断为请求失败
 *      如果该参数传入 `nil` 则不进行转换，直接使用 `AFNetworking` 返回的数据
 *
 *  @author Created by Lee on 16/9/9.
 *
 *  @copyright 2016年 SouthGIS. All rights reserved.
 *
 */


#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#import "SGSResponseSerializable.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @abstract 便捷调用AF原生方法的扩展
 */
@interface AFHTTPSessionManager (SGS)

/*!
 *  @abstract 默认提供的响应结果过滤闭包
 *
 *  @discussion 该闭包将过滤指定格式的JSON数据，格式如下:
 *
 *      {
 *          "code": 自定义状态码，请求成功返回200，其余状态码表示失败
 *          "description": 请求失败的错误描述信息，可为空
 *          "results": 请求成功的数据结果，可为空
 *      }
 */
+ (id (^)(id _Nullable))defaultResponseJSONFilter;


/*!
 *  @abstract GET 请求
 *
 *  @param URLString        请求地址
 *  @param parameters       请求参数
 *  @param downloadProgress 下载进度
 *  @param filter           响应结果过滤
 *  @param cls              响应结果序列化类型
 *  @param success          请求成功
 *  @param failure          请求失败
 *
 *  @return NSURLSessionDataTask or nil
 */
- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                        responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                              forClass:(nullable Class<SGSResponseSerializable>)cls
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/*!
 *  @abstract POST 请求
 *
 *  @param URLString      请求地址
 *  @param parameters     请求参数
 *  @param uploadProgress 上传进度
 *  @param filter         响应结果过滤
 *  @param cls            响应结果序列化类型
 *  @param success        请求成功
 *  @param failure        请求失败
 *
 *  @return NSURLSessionDataTask or nil
 */
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                         responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                               forClass:(nullable Class<SGSResponseSerializable>)cls
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/*!
 *  @abstract POST 请求，可拼接多部件表单数据
 *
 *  @param URLString      请求地址
 *  @param parameters     请求参数
 *  @param block          拼接多部件表单数据
 *  @param uploadProgress 上传进度
 *  @param filter         响应结果过滤
 *  @param cls            响应结果序列化类型
 *  @param success        请求成功
 *  @param failure        请求失败
 *
 *  @return NSURLSessionDataTask or nil
 */
- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
              constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                         responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                               forClass:(nullable Class<SGSResponseSerializable>)cls
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/*!
 *  @abstract PUT 请求
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param filter     响应结果过滤
 *  @param cls        响应结果序列化类型
 *  @param success    请求成功
 *  @param failure    请求失败
 *
 *  @return NSURLSessionDataTask or nil
 */
- (nullable NSURLSessionDataTask *)PUT:(NSString *)URLString
                            parameters:(nullable id)parameters
                        responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                              forClass:(nullable Class<SGSResponseSerializable>)cls
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/*!
 *  @abstract PATCH 请求
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param filter     响应结果过滤
 *  @param cls        响应结果序列化类型
 *  @param success    请求成功
 *  @param failure    请求失败
 *
 *  @return NSURLSessionDataTask or nil
 */
- (nullable NSURLSessionDataTask *)PATCH:(NSString *)URLString
                              parameters:(nullable id)parameters
                          responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                                forClass:(nullable Class<SGSResponseSerializable>)cls
                                 success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                 failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/*!
 *  @abstract DELETE 请求
 *
 *  @param URLString  请求地址
 *  @param parameters 请求参数
 *  @param filter     响应结果过滤
 *  @param cls        响应结果序列化类型
 *  @param success    请求成功
 *  @param failure    请求失败
 *
 *  @return NSURLSessionDataTask or nil
 */
- (nullable NSURLSessionDataTask *)DELETE:(NSString *)URLString
                               parameters:(nullable id)parameters
                           responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                                 forClass:(nullable Class<SGSResponseSerializable>)cls
                                  success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                  failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

/*!
 *  @abstract HTTP 请求
 *
 *  @param request 请求
 *  @param filter  响应结果过滤
 *  @param cls     响应结果序列化类型
 *  @param success 请求成功
 *  @param failure 请求失败
 *
 *  @return NSURLSessionDataTask or nil
 */
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                                     forClass:(nullable Class<SGSResponseSerializable>)cls
                                      success:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject))success
                                      failure:(nullable void (^)(NSURLResponse *response, NSError *error))failure;

/*!
 *  @abstract HTTP 请求，附带进度闭包
 *
 *  @param request               请求
 *  @param uploadProgressBlock   上传进度
 *  @param downloadProgressBlock 下载进度
 *  @param filter                响应结果过滤
 *  @param cls                   响应结果序列化类型
 *  @param success               请求成功
 *  @param failure               请求失败
 *
 *  @return NSURLSessionDataTask or nil
 */
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                               responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                                     forClass:(nullable Class<SGSResponseSerializable>)cls
                                      success:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject))success
                                      failure:(nullable void (^)(NSURLResponse *response, NSError *error))failure;

/*!
 *  @abstract 上传文件
 *
 *  @param request             请求
 *  @param fileURL             文件URL
 *  @param uploadProgressBlock 上传进度
 *  @param filter              响应结果过滤
 *  @param cls                 响应结果序列化类型
 *  @param success             上传成功
 *  @param failure             上传失败
 *
 *  @return NSURLSessionUploadTask or nil
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                   responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                                         forClass:(nullable Class<SGSResponseSerializable>)cls
                                          success:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject))success
                                          failure:(nullable void (^)(NSURLResponse *response, NSError *error))failure;

/*!
 *  @abstract 上传数据
 *
 *  @param request             请求
 *  @param bodyData            待上传的数据
 *  @param uploadProgressBlock 上传进度
 *  @param filter              响应结果过滤
 *  @param cls                 响应结果序列化类型
 *  @param success             上传成功
 *  @param failure             上传失败
 *
 *  @return NSURLSessionUploadTask or nil
 */
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(nullable NSData *)bodyData
                                         progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                   responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                                         forClass:(nullable Class<SGSResponseSerializable>)cls
                                          success:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject))success
                                          failure:(nullable void (^)(NSURLResponse *response, NSError *error))failure;

/*!
 *  @abstract 上传
 *
 *  @param request             请求
 *  @param uploadProgressBlock 上传进度
 *  @param filter              响应结果过滤
 *  @param cls                 响应结果序列化类型
 *  @param success             上传成功
 *  @param failure             上传失败
 *
 *  @return NSURLSessionUploadTask or nil
 */
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgressBlock
                                           responseFilter:(nullable id (^)(id _Nullable originalResponseObject))filter
                                                 forClass:(nullable Class<SGSResponseSerializable>)cls
                                                  success:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject))success
                                                  failure:(nullable void (^)(NSURLResponse *response, NSError *error))failure;
@end



NS_ASSUME_NONNULL_END