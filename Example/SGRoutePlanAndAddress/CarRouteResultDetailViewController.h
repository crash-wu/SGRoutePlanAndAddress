//
//  CarRouteResultDetailViewController.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//


#import "CarRouteResultDetailView.h"
#import "CarRoutePresentable.h"
#import <ArcGIS/ArcGIS.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 17:09:18
 *
 *  @brief  驾车路线详情页面
 */
@interface CarRouteResultDetailViewController : UIViewController

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 17:09:19
 *
 *  @brief  驾车路线详情
 */
@property(nonatomic,strong,nonnull) CarRouteResultDetailView *detailView;


/**
 *  @author crash         crash_wu@163.com   , 16-09-23 17:09:30
 *
 *  @brief  驾车路线规划详情
 *
 *  @param routeResult  驾车路线结果
 *  @param startAddress 起点地址
 *  @param stopAddress  终点地址
 *
 *  @return
 */
-(nonnull instancetype) initWithRouteResult:(AGSRouteResult *_Nullable)routeResult andStartAddress:(NSString *_Nullable) startAddress andStopAddress:(NSString *_Nullable)stopAddress;

@end
