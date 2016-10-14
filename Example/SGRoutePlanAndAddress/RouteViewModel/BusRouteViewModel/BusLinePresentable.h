//
//  BusLinePresentable.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/29.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusTravelsLineCell.h"
#import "BusLineShowInMapViewController.h"
#import <SGRoutePlanAndAddress/SGRoutePlanAndAddress.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 15:09:49
 *
 *  @brief  公交路线protocol
 */
@protocol BusLineProtocol <NSObject>

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 15:09:36
 *
 *  @brief  公交列表
 */
@property(nullable,weak,nonatomic) UITableView *tableView;


/**
 *  @author crash         crash_wu@163.com   , 16-09-30 11:09:07
 *
 *  @brief  控制器
 */
@property(nonatomic,weak,nullable) UIViewController *viewController;

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 16:09:19
 *
 *  @brief  数据渲染
 *
 *  @param busTravels 公交路线数组
 *
 *  @param starStop 起点地址
 *  
 *  @param endStop 终点地址
 */
-(void)rendBusTravelsDate:(NSArray<BusTravelsModel *>  *_Nullable)busTravels andStarStop:(NSString *_Nullable) starStop andEndStop:(NSString *_Nullable) endStop;

@end

@interface BusLinePresentable : NSObject<BusLineProtocol>






@end
