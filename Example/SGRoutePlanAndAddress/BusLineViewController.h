//
//  BusLineViewController.h
//  SGRoutePlanAndAddress
//
//  Created by 吴小星 on 16/10/14.
//  Copyright © 2016年 吴小星. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SGRoutePlanAndAddress/SGRoutePlanAndAddress.h>
#import "BusLinePresentable.h"

@interface BusLineViewController : UIViewController


@property(nonatomic,strong,nullable) UITableView *tableView;


/**
 *  @author crash         crash_wu@163.com   , 16-09-29 14:09:28
 *
 *  @brief  初始化控制器
 *
 *  @param busLines 公交路线数组
 *
 *  @param starStop 起点地址
 *
 *  @param endStop 终点地址
 *
 *  @return
 */
-(nonnull instancetype)initWithBusLine:(NSArray<BusTravelsModel *> *_Nullable)busLines andStarStop:(NSString *_Nullable)starStop andEndStop:(NSString *_Nullable)endStop;

@end
