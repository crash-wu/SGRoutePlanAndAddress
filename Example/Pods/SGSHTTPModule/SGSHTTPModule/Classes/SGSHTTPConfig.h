/*!
 @header SGSHTTPConfig.h
 
 @abstract 网络请求配置
 
 @author Created by Lee on 16/8/12.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 
 */

#import <Foundation/Foundation.h>

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
 *  @abstract 单例
 *
 *  @return SGSHTTPConfig sharedInstance
 */
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END