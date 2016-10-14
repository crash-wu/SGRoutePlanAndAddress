//
//  CarRoutePresentable.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarRouteDetailCell.h"
#import "CarRouteDetailSegmentViewController.h"
#import <objc/runtime.h>
#import <SGRoutePlanAndAddress/SGRoutePlanAndAddress.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 17:09:49
 *
 *  @brief  驾车路线代理
 */
@protocol CarRoutePresentableDelegate <NSObject>

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 17:09:26
 *
 *  @brief  列表
 */
@property(nonatomic,weak,nullable) UITableView *tableView;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:14
 *
 *  @brief  数据渲染
 *
 *  @param carRoute 路线分段数据
 */

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:39
 *
 *  @brief  数据渲染
 *
 *  @param carRoute    驾车路线
 *  @param starAddress 路线起点
 *  @param stopAddress 路线终点
 */
-(void)rendCarRouteDate:(AGSRouteResult * _Nullable) carRoute andStarAddress:(NSString *_Nullable) starAddress andStopAddress:(NSString *_Nullable) stopAddress;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:57
 *
 *  @brief  上层控制器
 */
@property(nonatomic,weak,nullable) UIViewController *viewController;

@end

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 08:09:31
 *
 *  @brief  驾车规划ViewModel
 */
@interface CarRoutePresentable : NSObject<CarRoutePresentableDelegate>

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:17
 *
 *  @brief  路线规划分段数组
 */
@property(nonatomic,strong,nullable) NSArray<AGSDirectionGraphic *> *carRouteDirectionS;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 11:09:29
 *
 *  @brief  驾车路线结果
 */
@property(nonatomic,strong,nullable) AGSRouteResult *carRoute;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:00
 *
 *  @brief  驾车起点
 */
@property(nonatomic,strong,nullable) NSString *starAddress;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:09
 *
 *  @brief  驾车终点
 */
@property(nonatomic,strong,nullable) NSString *stopAddress;

@end
