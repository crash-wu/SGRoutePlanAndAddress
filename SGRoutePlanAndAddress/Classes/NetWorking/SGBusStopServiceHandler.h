//
//  ChangShaBusServiceHandler.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/27.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SGSHTTPModule/SGSHTTPModule.h>
#import <SVProgressHUD/SVProgressHUD.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 14:09:43
 *
 *  @brief  公交站点查询
 */
@interface SGBusStopServiceHandler : SGSBaseRequest

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 15:09:55
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype)sharedInstance;

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 14:09:38
 *
 *  @brief  站点名称
 */
@property(nonatomic,strong,nullable) NSString *stopName;


/**
 *  @author crash         crash_wu@163.com   , 16-09-27 15:09:21
 *
 *  @brief  查询公交站点名称
 *
 *  @param stopName 公交站点名称
 *  @param url      公交站点查询URL
 *  @param success  查询成功block
 *  @param fail     查询失败block
 */
-(void)busStopService:(NSString *_Nullable)stopName
               andURL:(NSString *_Nullable)url
              success:(nonnull void (^)(NSArray<NSString *> *_Nullable stopNames))success
                 fail:(nonnull void(^)(NSError *_Nullable error))fail;

@end
