//
//  BusStopViewController.h
//  SGRoutePlanAndAddress
//
//  Created by 吴小星 on 16/10/14.
//  Copyright © 2016年 吴小星. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusStopPresentable.h"
#import <SGRoutePlanAndAddress/SGRoutePlanAndAddress.h>
#import "BusLineViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface BusStopViewController : UIViewController


@property(nonatomic,strong,nullable) UIButton *startSearchBtn;

@property(nonatomic,strong,nullable) UIButton *endSearchBtn;

@property(nonatomic,strong,nullable) UIButton *busStopSearch;


@property(nonatomic,strong,nullable) UITableView *tableView;

@end
