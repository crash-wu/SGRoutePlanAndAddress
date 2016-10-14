//
//  ChangShaRouteServiceHandler.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/22.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>


/**
 *  @author crash         crash_wu@163.com   , 16-09-22 15:09:17
 *
 *  @brief  长沙驾车路线规划
 */
@interface SGRouteServiceHandler : NSObject


/**
 *  @author crash         crash_wu@163.com   , 16-09-22 16:09:47
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype)sharedInstance;




/**
 *  @author crash         crash_wu@163.com   , 16-09-22 17:09:46
 *
 *  @brief  驾车路线规划
 *
 *  @param points  路线经过点
 *  @param url     驾车路线规划请求服务(ArcGIS 服务)
 *  @param success 请求成功
 *  @param fail    请求失败
 */
-(void)changShaRouteSearch:(NSArray<AGSPoint *> *_Nonnull)points
                    andURL:(NSString *_Nullable)url
                    success:(nullable void(^)(AGSRouteResult *_Nullable resut))success
                    fail:(nullable void(^) (NSError *_Nullable error) )fail;

@end
