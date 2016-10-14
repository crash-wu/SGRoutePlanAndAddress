//
//  CarRouteResultViewController.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CommonMapViewController.h"
#import "CarRouteMessageView.h"
#import "CarRouteResultDetailViewController.h"

@interface CarRouteResultViewController : CommonMapViewController

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 10:09:23
 *
 *  @brief  初始化函数
 *
 *  @param routeResult 驾车路线
 *
 *  @return
 */
-(nonnull instancetype) initWithRouteResult:(AGSRouteResult *_Nullable)routeResult andStartAddress:(NSString *_Nullable) startAddress andStopAddress:(NSString *_Nullable)stopAddress;

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 12:09:21
 *
 *  @brief  驾车路线页面
 */
@property(nonatomic,strong,nullable ) CarRouteMessageView *routeMessageView;



@end
