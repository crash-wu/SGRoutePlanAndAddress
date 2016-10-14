//
//  BusStopPresentable.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/27.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusStopCell.h"
#import <objc/runtime.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 17:09:01
 *
 *  @brief  公交站点代理
 */
@protocol BusStopProtocol <NSObject>

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 17:09:33
 *
 *  @brief  公交站点表
 */
@property(nonatomic,weak,nullable) UITableView *tableView;

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 19:09:15
 *
 *  @brief  数据渲染
 *
 *  @param busStops 公交站点数据
 */
-(void)rendBusStopData:(NSArray <NSString *> *_Nullable) busStops;

@end

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 19:09:08
 *
 *  @brief  公交站点选择代理
 */
@protocol BusStopSelectDelegate <NSObject>

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 19:09:21
 *
 *  @brief   公交站点选择
 *
 *  @param busStop  选中的公交站点
 */
-(void) busStopSelect:(NSString *_Nullable) busStop;

@end

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 17:09:25
 *
 *  @brief  公交站点ViewModel
 */
@interface BusStopPresentable : NSObject<BusStopProtocol>

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 19:09:12
 *
 *  @brief  名称
 */
@property(nonatomic,strong,nullable) NSArray<NSString *> *busStops;


@property(nonatomic,weak,nullable) id<BusStopSelectDelegate> busStopDelegate;

@end
