//
//  ChangShaGetBusLinePolylineHandler.h
//  ChangSha
//
//  Created by 吴小星 on 16/10/11.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusTravelsModel.h"
#import <ArcGIS/ArcGIS.h>
#import <SVProgressHUD/SVProgressHUD.h>

/**
 *  @author crash         crash_wu@163.com   , 16-10-11 10:10:34
 *
 *  @brief  获取公交路线数据(Ployline)
 */
@interface SGGetBusLinePolylineHandler : NSObject


/**
 *  @author crash         crash_wu@163.com   , 16-09-06 15:09:48
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance;

/**
 *  @author crash         crash_wu@163.com   , 16-10-11 10:10:56
 *
 *  @brief  获取公交路线线路坐标
 *
 *  @param starStop     起点站点
 *  @param endStop      终点站点
 *  @param travelsModel 公交路线实体
 *  @param url          服务地址（ArcGIS 服务）
 *  @param success      成功block
 *  @param failed       失败block
 */
-(void)busStopLine:(NSString *_Nonnull)starStop
        andEndStop:(NSString *_Nonnull)endStop
       andBusTravles:(BusTravelsModel *_Nullable)travelsModel
       andURL:(NSString *_Nullable)url
       succes:
            (nonnull void (^)( NSArray<AGSGraphic *> *_Nullable graphics))success
       failed:
           (nonnull void(^)(NSError *_Nullable error))failed;

@end
