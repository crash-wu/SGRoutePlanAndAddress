//
//  CarRouteResultDetailViewController.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CarRouteResultDetailViewController.h"

@interface CarRouteResultDetailViewController ()

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 09:09:46
 *
 *  @brief  驾车路线详情ViewModel
 */
@property(nonatomic,strong,nullable) CarRoutePresentable *carRoutePresent;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 09:09:50
 *
 *  @brief  结果
 */
@property(nonatomic,strong,nullable) AGSRouteResult *carRoute;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:24
 *
 *  @brief  起点
 */
@property(nonatomic,strong,nullable) NSString *starAddress;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:34
 *
 *  @brief  终点
 */
@property(nonatomic,strong,nullable) NSString *stopAddress;

@end

@implementation CarRouteResultDetailViewController

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
-(nonnull instancetype) initWithRouteResult:(AGSRouteResult *_Nullable)routeResult andStartAddress:(NSString *_Nullable) startAddress andStopAddress:(NSString *_Nullable)stopAddress{
    if (self= [super init]) {
        
        self.detailView = [[CarRouteResultDetailView alloc]initWithFrame:self.view.frame];
        self.detailView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.detailView];
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = true;
        
        self.detailView.addressLb.text = [NSString stringWithFormat:@"%@ -> %@" ,startAddress,stopAddress];
        
        self.carRoute = routeResult;
        self.starAddress = startAddress;
        self.stopAddress = stopAddress;
        
        self.carRoutePresent = [[CarRoutePresentable alloc]init];
    }
    
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"驾车详情"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.carRoutePresent.tableView = self.detailView.tableView;
    self.carRoutePresent.viewController = self;

    [self.carRoutePresent rendCarRouteDate:self.carRoute andStarAddress:self.starAddress andStopAddress:self.stopAddress ];

}


@end
