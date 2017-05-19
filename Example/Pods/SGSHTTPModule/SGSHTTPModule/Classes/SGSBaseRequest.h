/*!
 @header SGSBaseRequest.h
 
 @abstract 网络请求基础类
 
 @author Created by Lee on 16/8/12.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import <Foundation/Foundation.h>

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#import "SGSRequestDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SGSResponseObjectSerializable;
@protocol SGSResponseCollectionSerializable;

/*!
 *  @abstract HTTP 请求方法，这里仅包含 `AFNetworking` 支持的6种方式
 *
 *  @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html
 */
typedef NS_ENUM(NSInteger , SGSRequestMethod) {
    SGSRequestMethodGet    = 0, //! GET请求
    SGSRequestMethodPost   = 1, //! POST请求
    SGSRequestMethodHead   = 2, //! HEAD请求
    SGSRequestMethodPut    = 3, //! PUT请求
    SGSRequestMethodPatch  = 4, //! PATCH请求
    SGSRequestMethodDelete = 5, //! DELETE请求
};


/*!
 *  @abstract HTTP请求序列化类型
 */
typedef NS_ENUM(NSInteger, SGSRequestSerializerType) {
    SGSRequestSerializerTypeForm         = 0, //! 表单形式，默认
    SGSRequestSerializerTypeJSON         = 1, //! JSON形式
    SGSRequestSerializerTypePropertyList = 2, //! XML形式
};


/*!
 *  @abstract 请求优先级
 *
 *  @discussion 分别对应 `NSURLSessionTask` 的三种默认优先级:
 *      1. NSURLSessionTaskPriorityLow
 *      2. NSURLSessionTaskPriorityDefault
 *      3. NSURLSessionTaskPriorityHigh
 *
 *  @see `NSURLSessionTask` -> `priority`
 */
typedef NS_ENUM(NSInteger, SGSRequestPriority) {
    SGSRequestPriorityLow     = -1, //! 低优先级
    SGSRequestPriorityDefault = 0,  //! 默认优先级
    SGSRequestPriorityHigh    = 1,  //! 高优先级
};



/*!
 *  @class SGSBaseRequest
 *
 *  @abstract HTTP 异步请求基础类
 *  
 *  @discussion 请求实体只需继承该类，通过重写请求地址、请求参数等方法来指定不同的网络请求
 *      可以对请求进行发起、暂停、取消等操作，并且通过 block 或代理方法进行回调
 *      还可以根据需求自定义响应数据过滤，返回业务需要的数据类型
 */
@interface SGSBaseRequest : NSObject

/*!
 *  @abstract 代理
 *  
 *  @discussion 通过代理可以获取请求过程的代理方法，包括请求的开始、暂停、取消、成功、失败等
 */
@property (nullable, weak) id<SGSRequestDelegate> delegate;

#pragma mark - 请求
///-----------------------------------------------------------------------------
/// @name 请求
///-----------------------------------------------------------------------------

/*!
 *  @abstract 请求任务
 */
@property (nullable, nonatomic, strong) NSURLSessionTask *task;

/*!
 *  @abstract 请求状态，包括：正在请求、暂停、已取消、已完成
 */
@property (nonatomic, assign, readonly) NSURLSessionTaskState state;

/*!
 *  @abstract 原始请求，由 `task.originalRequest` 获取
 */
@property (nullable, nonatomic, strong, readonly) NSURLRequest *originalRequest;

/*!
 *  @abstract 当前请求，由 `task.currentRequest` 获取，服务器重定向后可能与 `originalRequest` 有所区别
 */
@property (nullable, nonatomic, strong, readonly) NSURLRequest  *currentRequest;

/*!
 *  @abstract 原始请求地址，根据 `-requestURL` , `-baseURL` , 以及 SGSHTTPConfig 的 `-baseURL` 拼接
 *
 *  @discussion 当发起请求时会基于以下规则拼接请求地址：
 *      1. `-requestURL` 返回的字符串是否包含了“http://”协议，如果包含直接使用该地址进行请求
 *      2. 判断是否重写父类的 `-baseURL` 方法，如果有则与 `-requestURL` 进行组合并发起请求
 *      3. 判断 SGSHTTPConfig 是否设置了 `-baseURL`，如果有则将配置的基础地址与 `-requestURL` 进行组合并发起请求
 *      4. 如果都没有设置 `-baseURL`，并且 `-requestURL` 的头部没有包含“http://”，那么会尝试直接使用 `-requestURL` 的链接发起请求
 */
@property (nonatomic, copy, readonly) NSString *originURLString;

/*!
 *  @abstract 请求优先级，默认为 `SGSRequestPriorityDefault`
 */
@property (nonatomic, assign) SGSRequestPriority requestPriority;


#pragma mark - 快捷初始化方法

- (instancetype)initWithURLString:(nullable NSString *)urlString;
- (instancetype)initWithURLString:(nullable NSString *)urlString parameters:(nullable id)parameters;
- (instancetype)initWithURLString:(nullable NSString *)urlString relativeToURLString:(nullable NSString *)baseURLString parameters:(nullable id)parameters;


#pragma mark - 请求参数
///-----------------------------------------------------------------------------
/// @name 子类可以重写以下参数来指定不同的网络请求
///-----------------------------------------------------------------------------


#pragma mark - 请求方法

/*!
 *  @abstract HTTP请求方法，默认为 `GET` 请求
 *
 *  @return 请求方法
 *
 *  @see `SGSRequestMethod`
 */
@property (nonatomic, assign) SGSRequestMethod requestMethod;


#pragma mark - 请求参数 - URL

/*!
 *  @abstract 请求序列化类型，默认为 `SGSRequestSerializerTypeForm`
 *
 *  @return 请求序列化类型
 *
 *  @see `SGSRequestSerializerType`
 */
@property (nonatomic, assign) SGSRequestSerializerType requestSerializerType;


/*!
 *  @abstract 请求基础URL字符串，例如：http://192.186.10.10/ ，默认为 `nil`
 *
 *  @discussion 字符串需遵守 URL 编码规则，不允许有中文字符
 *
 *  @return 请求基础URL字符串
 */
@property (nullable, nonatomic, copy) NSString *baseURL;


/*!
 *  @abstract 请求地址字符串，默认为 `nil`
 *
 *  @discussion 字符串需遵守 URL 编码规则，不允许有中文字符
 *
 *  @return 请求地址字符串
 */
@property (nullable, nonatomic, copy) NSString *requestURL;


/*!
 *  @abstract 请求的参数列表，默认为 `nil`
 *
 *  @return 请求参数列表
 */
@property (nullable, nonatomic, strong) id requestParameters;



#pragma mark - 请求参数 - NSMutableURLRequest Property

/*!
 *  @abstract NSURLRequest 缓存策略，默认为 `NSURLRequestUseProtocolCachePolicy`
 *
 *  @return NSURLRequest 缓存策略
 *
 *  @see NSMutableURLRequest `cachePolicy` 属性
 */
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;

/*!
 *  @abstract 请求的连接超时时长，单位为: *秒* ，默认为60秒
 *
 *  @return 请求超时时长
 *
 *  @see NSMutableURLRequest `requestTimeout` 属性
 */
@property (nonatomic, assign) NSTimeInterval requestTimeout;


/*!
 *  @abstract 网络服务类型，默认为 `NSURLNetworkServiceTypeDefault`
 *
 *  @return 网络服务类型
 *
 *  @see NSMutableURLRequest `networkServiceType` 属性
 */
@property (nonatomic, assign) NSURLRequestNetworkServiceType networkServiceType;


/*!
 *  @abstract 是否允许蜂窝网络传输数据，默认为 `YES`
 *
 *  @return `YES` 允许蜂窝网络传输； `NO` 不允许蜂窝网络传输，仅在 WiFi 环境下传输数据
 *
 *  @see NSMutableURLRequest `allowsCellularAccess` 属性
 */
@property (nonatomic, assign) BOOL allowsCellularAccess;


/*!
 *  @abstract 是否允许处理 cookies 数据，默认为 `YES`
 *
 *  @return `YES` 允许处理； `NO` 不允许保存 cookies
 *
 *  @see NSMutableURLRequest (NSMutableHTTPURLRequest)  `HTTPShouldHandleCookies` 属性
 */
@property (nonatomic, assign) BOOL HTTPShouldHandleCookies;


/*!
 *  @abstract 是否等待之前的响应，默认为 `NO`
 *
 *  @return `YES` 等待； `NO` 不等待
 *
 *  @see NSMutableURLRequest (NSMutableHTTPURLRequest)  `HTTPShouldUsePipelining` 属性
 */
@property (nonatomic, assign) BOOL HTTPShouldUsePipelining;


#pragma mark - 请求参数 - HTTP Request Headers

/*!
 *  @abstract 需要认证的 HTTP 请求头的用户名（内部默认进行 Base-64 编码），默认为 `nil`
 *
 *  @return 用户名字符串
 */
@property (nullable, nonatomic, copy) NSString *authorizationUsername;

/*!
 *  @abstract 需要认证的 HTTP 请求头的密码（内部默认进行 Base-64 编码），默认为 `nil`
 *
 *  @return 密码字符串
 */
@property (nullable, nonatomic, copy) NSString *authorizationPassword;


/*!
 *  @abstract 请求报头自定义参数，默认为拼接 If-Modified-Since 和 If-None-Match
 *
 *  @return 请求报头参数字典
 */
@property (nullable, nonatomic, strong) NSDictionary<NSString *, NSString *> *requestHeaders;



#pragma mark - 请求参数 - customURLRequest

/*!
 *  @abstract 使用自定义的URLRequest发起请求，默认为 `nil`
 *
 *  @discussion 如果该方法返回非 `nil` 对象，将忽略以下参数：
 *      - requestSerializerType
 *      - baseURL
 *      - requestURL
 *      - requestParameters
 *      - requestHeaders
 *      - cachePolicy
 *      - requestTimeout
 *      - networkServiceType
 *      - allowsCellularAccess
 *      - HTTPShouldHandleCookies
 *      - HTTPShouldUsePipelining
 *      - requestMethod
 *      - authorizationUsername
 *      - authorizationPassword
 *      - requestHeaders
 *      - constructingBodyBlock
 */
@property (nullable, nonatomic, strong) NSURLRequest *customURLRequest;



#pragma mark - 请求参数 - Upload

/*!
 *  @abstract 拼接上传表单数据的Block，默认为 `nil`
 */
@property (nullable, nonatomic, copy) void (^constructingBodyBlock)(id<AFMultipartFormData> formData);



#pragma mark - 请求参数 - Download


/*!
 *  @abstract 下载完毕后需要保存的本地路径
 *
 *  @discussion 只有调用 `-downloadWithCompletionSuccess:failure:` 或 `-startDownload` 才会生效，
 *      在调用该闭包的同时，会根据 `-removeAlreadyExistsFileWhenDownloadSuccess` 判断是否要先删除已存在的同名文件再进行保存
 *
 *      默认返回： [SGSHTTPConfig sharedInstance].defaultDownloadsDirectory/response.suggestedFilename
 */
@property (null_resettable, nonatomic, copy) NSURL * (^downloadTargetPath)(NSURL *location, NSURLResponse *response);


/*!
 *  @abstract 下载是否忽略断点数据，默认为NO
 *
 *  @return 返回 `YES` 将忽略断点数据，始终发起新的下载请求；返回 `NO` 请求前判断如果有断点数据，优先进行断点续传
 */
@property (nonatomic, assign) BOOL ignoreResumeData;



#pragma mark - 请求参数 - Response


/*!
 *  @abstract 可序列化的响应对象类型，默认为 `nil`
 *
 *  @return 可序列化的响应对象类
 */
@property (nullable, nonatomic, strong) Class<SGSResponseObjectSerializable> responseObjectClass;


/*!
 *  @abstract 可序列化的响应对象集合类型，默认为 `nil`
 *
 *  @return 可序列化的对象集合类
 */
@property (nullable, nonatomic, strong) Class<SGSResponseCollectionSerializable> responseObjectArrayClass;



#pragma mark - 请求过程
///-----------------------------------------------------------------------------
/// @name 请求过程
///-----------------------------------------------------------------------------


/*!
 *  @abstract 请求成功回调闭包
 */
@property (nullable, nonatomic, copy) void (^successCompletionBlock)(__kindof SGSBaseRequest *request);


/*!
 *  @abstract 请求失败回调闭包
 */
@property (nullable, nonatomic, copy) void (^failureCompletionBlock)(__kindof SGSBaseRequest *request);


/*!
 *  @abstract 即将开始请求回调闭包
 */
@property (nullable, nonatomic, copy) void (^requestWillStartBlock)(__kindof SGSBaseRequest *request);


/*!
 *  @abstract 即将暂停回调闭包
 *  
 *  @discussion 只有调用 `-suspend` 方法才会触发
 */
@property (nullable, nonatomic, copy) void (^requestWillSuspendBlock)(__kindof SGSBaseRequest *request);


/*!
 *  @abstract 已经暂停回调闭包
 *
 *  @discussion 只有调用 `-suspend` 方法才会触发
 */
@property (nullable, nonatomic, copy) void (^requestDidSuspendBlock)(__kindof SGSBaseRequest *request);


/*!
 *  @abstract 即将停止请求回调闭包
 *
 *  @discussion 当有以下情形时，该闭包将会被调用:
 *      - 请求成功
 *      - 请求失败
 *      - 主动调用 `-stop` 方法停止请求
 *      - 调用 `NSURLSessionTask` 及其子类的 `-cancel` 方法
 *      - 调用 `NSURLSessionDownloadTask` 的 `-cancelByProducingResumeData:` 方法
 */
@property (nullable, nonatomic, copy) void (^requestWillStopBlock)(__kindof SGSBaseRequest *request);


/*!
 *  @abstract 已经停止请求回调闭包
 *
 *  @discussion 调用情形参考 `requestWillStopBlock` 属性
 */
@property (nullable, nonatomic, copy) void (^requestDidStopBlock)(__kindof SGSBaseRequest *request);


/*!
 *  @abstract 请求进度回调闭包，包括下载进度和上传进度
 */
@property (nullable, nonatomic, copy) void (^progressBlock)(__kindof SGSBaseRequest *request, NSProgress *progress);



#pragma mark - 响应
///-----------------------------------------------------------------------------
/// @name 响应
///-----------------------------------------------------------------------------

/*!
 *  @abstract HTTP 响应
 *  
 *  @discussion 当请求失败时可能为 `nil`
 */
@property (nullable, nonatomic, strong) NSHTTPURLResponse *response;


/*!
 *  @abstract 请求响应的原始数据
 *
 *  @discussion 当响应码为 `204` 或请求失败时可能为 `nil`
 */
@property (nullable, nonatomic, strong) NSData *responseData;


/*!
 *  @abstract 请求错误
 *
 *  @discussion 当请求失败时将会有值，只要该属性不为空，最终将判断为请求失败
 */
@property (nullable, nonatomic, strong) NSError *error;


/*!
 *  @abstract 响应字符串
 *
 *  @discussion 默认根据 `responseData` 解析，可通过重写该属性的 getter 方法自定义解析
 */
@property (nullable, nonatomic, copy  , readonly) NSString *responseString;


/*!
 *  @abstract 响应JSON数据
 *
 *  @discussion 默认根据 `responseData` 解析，可通过重写该属性的 getter 方法自定义解析
 */
@property (nullable, nonatomic, strong, readonly) id responseJSON;


/*!
 *  @abstract 响应模型对象，响应数据转为模型对象的便捷获取方法
 *
 *  @discussion 该属性通过 `-responseObjectClass` 方法获取对象类型
 *      该对象类型需要遵守 `SGSResponseObjectSerializable` 协议
 *      默认根据 `responseJSON` 调用该协议的方法序列化为对象
 *      可通过重写该属性的 getter 方法自定义解析
 */
@property (nullable, nonatomic, strong, readonly) id<SGSResponseObjectSerializable> responseObject;


/*!
 *  @abstract 响应对象数组
 *
 *  @discussion 响应数据转为模型数组的便捷获取方法
 *
 *  该属性通过 `--responseObjectArrayClass` 方法获取对象类型，
 *  该对象类型需要遵守 `SGSResponseCollectionSerializable` 协议
 *
 *  默认根据 `responseJSON` 调用该协议的方法序列化为对象，可通过重写该属性的 getter 方法自定义解析
 */
@property (nullable, nonatomic, strong, readonly) NSArray<id<SGSResponseObjectSerializable>> *responseObjectArray;



#pragma mark - 操作方法
///-----------------------------------------------------------------------------
/// @name 操作方法
///-----------------------------------------------------------------------------


/*!
 *  @abstract 开始请求
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 *      详细参考 `-startWithSessionManager:success:failure:`
 *
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 */
- (void)startWithCompletionSuccess:(nullable void (^)(__kindof SGSBaseRequest *request))success
                           failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/*!
 *  @abstract 开始请求
 *
 *  @discussion 可以发起 `GET`, `POST`, `HEAD`, `PUT`, `PATCH`, `DELETE` 请求
 *
 *  如果需要上传，可以在 `constructingBodyBlock` 里添加需要上传的内容，然后用 `POST` 发起请求
 *  如果需要下载，可以直接发起 `GET` 请求，但是不支持断点续传
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-startWithCompletionSuccess:failure:`
 *  @param success 请求成功回调
 *  @param failure 请求失败回调
 */
- (void)startWithSessionManager:(nullable AFURLSessionManager *)manager
                        success:(nullable void (^)(__kindof SGSBaseRequest *request))success
                        failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/*!
 *  @abstract 下载数据，支持断点续传
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 *      详细参考 `-downloadWithSessionManager:success:failure:`
 *
 *  @param success 下载成功回调
 *  @param failure 下载失败回调
 */
- (void)downloadWithCompletionSuccess:(nullable void (^)(__kindof SGSBaseRequest *request))success
                              failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/*!
 *  @abstract 下载数据，支持断点续传
 *
 *  @discussion
 *    1.
 *      在下载请求前，根据下载地址自动判断本地是否有断点数据，
 *      如果没有断点数据将重新创建下载请求，
 *      如果有断点数据，那么将重新获取本地的断点数据，继续下载
 *
 *      当下载或者断点续传失败时，会在磁盘和缓存中保存这次请求的断点数据，
 *      该断点数据是数据概要（因此很小），并非真实下载数据，
 *      真实下载数据是 ~/tmp 文件夹中的 CFNetworkDownload_xxxxxx.tmp 文件，
 *      如果是后台下载，目录则是 ~/Library/Caches/com.apple.nsurlsessiond/Downloads/(App ID)/CFNetworkDownload_xxxxxx.tmp
 *
 *    2.
 *      由于 `NSURLSession` 使用 download task 下载数据时，数据保存在临时文件夹中，
 *      当数据下载完毕 `NSURLSession` 会自动删除该临时数据，因此使用该方法下载数据时，
 *      可以重写 `-downloadTargetPath` 方法指定保存路径，该方法默认路径为：~/Library/Caches/com.southgis.iMobile.HTTPModule.downloads
 *
 *    3.
 *      如果使用该方法发起多次同样的下载请求，上一次的下载请求将会取消并且保存断点数据，使用断点续传发起新的下载请求
 *
 *      例如，第一次发起的下载请求的回调:
 *      @code
 *          [Adownload downloadWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
 *              NSLog(@"第一次请求成功");
 *          } failure:nil];
 *      @endcode
 *
 *      第二次发起的下载请求回调:
 *      @code
 *          [Adownload downloadWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
 *              NSLog(@"第二次请求成功");
 *          } failure:nil];
 *      @endcode
 *
 *      此时第二次发起的下载请求将被判断为重复请求，取消第一次下载请求并保存断点数据，再使用断点续传发起第二次下载请求
 *      下载成功后，将会打印"第二次请求成功"，而不是"第一次请求成功"
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-downloadWithCompletionSuccess:failure:`
 *  @param success 下载成功回调
 *  @param failure 下载失败回调
 */
- (void)downloadWithSessionManager:(nullable AFURLSessionManager *)manager
                           success:(nullable void (^)(__kindof SGSBaseRequest *request))success
                           failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/*!
 *  @abstract 上传文件
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 *
 *  @param fileURL 待上传文件路径
 *  @param success 上传成功回调
 *  @param failure 上传失败回调
 */
- (void)uploadWithFile:(NSURL *)fileURL
               success:(nullable void (^)(__kindof SGSBaseRequest *request))success
               failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/*!
 *  @abstract 上传文件
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-uploadWithFile:success:failure:` 方法
 *  @param fileURL 待上传文件路径
 *  @param success 上传成功回调
 *  @param failure 上传失败回调
 */
- (void)uploadWithSessionManager:(nullable AFURLSessionManager *)manager
                        fromFile:(NSURL *)fileURL
                         success:(nullable void (^)(__kindof SGSBaseRequest *request))success
                         failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/*!
 *  @abstract 上传数据
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 *
 *  @param bodyData 待上传数据
 *  @param success  上传成功回调
 *  @param failure  上传失败回调
 */
- (void)uploadWithData:(nullable NSData *)bodyData
               success:(nullable void (^)(__kindof SGSBaseRequest *request))success
               failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/*!
 *  @abstract 上传数据
 *
 *  @param manager  AFNetworking 的会话管理类，如果为空等同于调用 `-uploadWithData:success:failure:` 方法
 *  @param bodyData 待上传数据
 *  @param success  上传成功回调
 *  @param failure  上传失败回调
 */
- (void)uploadWithSessionManager:(nullable AFURLSessionManager *)manager
                        fromData:(nullable NSData *)bodyData
                         success:(nullable void (^)(__kindof SGSBaseRequest *request))success
                         failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/*!
 *  @abstract 开始请求
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 */
- (void)start;


/*!
 *  @abstract 开始请求
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-start` 方法
 */
- (void)startWithSessionManager:(nullable AFURLSessionManager *)manager;


/*!
 *  @abstract 开始下载，支持断点续传
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 */
- (void)startDownload;


/*!
 *  @abstract 开始下载，支持断点续传
 *
 *  @discussion 参见 `-downloadWithCompletionSuccess:failure:`
 *      由于 `NSURLSession` 使用 download task 下载数据时，数据是保存在临时文件夹中，
 *      当数据下载完毕 `NSURLSession` 会自动删除该临时数据，因此使用该方法下载数据时，
 *      可以重写 `-downloadTargetPath` 方法指定保存路径，该方法默认路径为：~/Library/Caches/com.southgis.iMobile.HTTPModule.downloads
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-startDownload`
 */
- (void)startDownloadWithSessionManager:(nullable AFURLSessionManager *)manager;


/*!
 *  @abstract 开始上传文件
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 *
 *  @param fileURL 待上传文件的地址
 */
- (void)startUploadWithFile:(NSURL *)fileURL;


/*!
 *  @abstract 开始上传文件
 *
 *  @param manager AFNetworking 的会话管理类，如果为空等同于调用 `-startUploadWithFile:` 方法
 *  @param fileURL 待上传文件的地址
 */
- (void)startUploadWithSessionManager:(nullable AFURLSessionManager *)manager
                             fromFile:(NSURL *)fileURL;


/*!
 *  @abstract 开始上传数据
 *
 *  @discussion 默认使用 defaultSessionConfiguration 初始化的 AFURLSessionManager 单例
 *
 *  @param bodyData 待上传的数据
 */
- (void)startUploadWithData:(nullable NSData *)bodyData;


/*!
 *  @abstract 开始上传数据
 *
 *  @param manager  AFNetworking 的会话管理类，如果为空等同于调用 `-startUploadWithData:` 方法
 *  @param bodyData 待上传的数据
 */
- (void)startUploadWithSessionManager:(nullable AFURLSessionManager *)manager
                             fromData:(nullable NSData *)bodyData;


/*!
 *  @abstract 继续执行请求
 */
- (void)resume;


/*!
 *  @abstract 暂停请求
 */
- (void)suspend;


/*!
 *  @abstract 主动停止请求
 */
- (void)stop;


/*!
 *  @abstract 设置请求完毕回调block
 *
 *  @param success 将赋值给 `successCompletionBlock` 属性，在请求成功时回调
 *  @param failure 将赋值给 `failureCompletionBlock` 属性，在请求失败时回调
 */
- (void)setCompletionBlockWithSuccess:(nullable void (^)(__kindof SGSBaseRequest *request))success
                              failure:(nullable void (^)(__kindof SGSBaseRequest *request))failure;


/*!
 *  @abstract 把所有block属性置为nil来打破循环引用
 */
- (void)clearBlock;


/*!
 *  @abstract 用于检查Status Code是否正常
 *
 *  @return 响应码
 */
- (BOOL)statusCodeValidator;


/*!
 *  @abstract 请求完毕的回调过滤，如果子类不重写，将不做任何处理
 *
 *  @discussion 该方法将在回调前调用，可以通过该方法验证返回的数据是否为有效数据
 *
 *      例如在获取到JSON数据时，验证是否是指定格式的JSON数据，
 *      如果获取到非法的JSON数据，可以直接给 `error` 属性赋值自定义的错误信息，
 *      在最终执行回调block或代理方法前判断，只要 `error` 属性不为 `nil` ，即视为请求失败
 *
 *      因此可以通过重写该方法验证和过滤数据
 */
- (void)requestCompleteFilter;

@end

NS_ASSUME_NONNULL_END
