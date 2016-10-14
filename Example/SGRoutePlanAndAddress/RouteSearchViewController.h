//
//  RouteSearchViewController.h
//  SGRoutePlanAndAddress
//
//  Created by 吴小星 on 16/10/14.
//  Copyright © 2016年 吴小星. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SGRoutePlanAndAddress/SGRoutePlanAndAddress.h>
#import "BusStopViewController.h"
#import "CarRouteResultViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface RouteSearchViewController : UIViewController

/**
 *  @author crash         crash_wu@163.com   , 16-10-14 14:10:00
 *
 *  @brief  表格
 */
@property(nonatomic,strong,nullable) UITableView *tableView;

@end
