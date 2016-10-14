//
//  BusLineViewController.m
//  SGRoutePlanAndAddress
//
//  Created by 吴小星 on 16/10/14.
//  Copyright © 2016年 吴小星. All rights reserved.
//

#import "BusLineViewController.h"

@interface BusLineViewController ()

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 17:09:19
 *
 *  @brief   viewModel
 */
@property(nonatomic,strong,nullable) BusLinePresentable *presentable;

@end

@implementation BusLineViewController

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
-(nonnull instancetype)initWithBusLine:(NSArray<BusTravelsModel *> *_Nullable)busLines andStarStop:(NSString *_Nullable)starStop andEndStop:(NSString *_Nullable)endStop{
    
    if (self = [super init]) {
        
        self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = true;
        [self.view addSubview:self.tableView];
        
        self.presentable = [[BusLinePresentable alloc]init];
        self.presentable.tableView = self.tableView;
        self.presentable.viewController = self;
        [self.presentable rendBusTravelsDate:busLines andStarStop:starStop andEndStop:endStop];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"公交方案"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
