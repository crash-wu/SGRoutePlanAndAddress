//
//  BusLineShowInMapViewController.h
//  ChangSha
//
//  Created by 吴小星 on 16/10/10.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CommonMapViewController.h"
#import "BusTravelsContentView.h"
#import <SGRoutePlanAndAddress/SGRoutePlanAndAddress.h>
#import <Masonry/Masonry.h>
#import <SVProgressHUD/SVProgressHUD.h>


/**
 *  @author crash         crash_wu@163.com   , 16-10-10 18:10:00
 *
 *  @brief  在地图上展示公交路线控制器
 */
@interface BusLineShowInMapViewController : CommonMapViewController


/**
 *  @author crash         crash_wu@163.com   , 16-10-11 08:10:36
 *
 *  @brief  初始化函数
 *
 *  @param busLines 公交路线数组
 *  @param starStop 公交起点站点
 *  @param endStop  公交终点站点
 *  @param row      公交路线下标
 *
 *  @return
 */
-(nonnull instancetype)initWithBusLineModes:(NSArray<BusTravelsModel *> *_Nullable) busLines andStarStop:(NSString *_Nullable)starStop andEndStop:(NSString *_Nullable)endStop andRow:(NSInteger)row;

@end
