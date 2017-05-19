/*!
 @header SGSHTTPConfig.h
 
 @abstract 网络请求配置
 
 @author Created by Lee on 16/8/12.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import <Foundation/Foundation.h>

#if __has_include(<AFNetworking/AFSecurityPolicy.h>)
#import <AFNetworking/AFSecurityPolicy.h>
#else
#import "AFSecurityPolicy.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @class SGSHTTPConfig
 *
 *  @abstract 网络配置类
 *
 *  @classdesign `SGSHTTPConfig` 为单例设计模式，用于统一设置网络请求配置
 */
@interface SGSHTTPConfig : NSObject

/*!
 *  @abstract 基础地址，默认为 @""
 */
@property (nonatomic, copy) NSString *baseURL;

/*!
 *  @abstract 下载数据的保存目录，默认为 `~/Library/Caches/com.southgis.iMobile.HTTPModule.downloads`
 */
@property (nonatomic, copy) NSString *defaultDownloadsDirectory;


/*!
 *  @abstract 安全策略，可以通过该属性设置证书
 *
 *  @note 该属性仅用于设置 AFURLSessionManager+SGS 中的 defaultSessionManager 单例,
 *      如果需要使用不同的安全策略，可以自行创建不同的 AFURLSessionManager, 通过 SGSBaseRequest 的
 *      以下方法调用不同的 AFURLSessionManager 对象：
 *          1. -startWithSessionManager:
 *          2. -startDownloadWithSessionManager:
 *          3. -startUploadWithSessionManager:fromFile:
 *          4. -startUploadWithSessionManager:fromData:
 *          5. -startWithSessionManager:success:failure:
 *          6. -downloadWithSessionManager:success:failure:
 *          7. -uploadWithSessionManager:fromFile:success:failure:
 *          8. -uploadWithSessionManager:fromData:success:failure:
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/*!
 *  @abstract 单例
 *
 *  @return SGSHTTPConfig sharedInstance
 */
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
