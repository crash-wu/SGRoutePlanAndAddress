//
//  BusStopViewController.m
//  SGRoutePlanAndAddress
//
//  Created by 吴小星 on 16/10/14.
//  Copyright © 2016年 吴小星. All rights reserved.
//

#import "BusStopViewController.h"

@interface BusStopViewController ()<BusStopSelectDelegate>

/**
 *  @author crash         crash_wu@163.com   , 16-10-14 15:10:34
 *
 *  @brief  是否为起点站点查询
 */
@property(nonatomic,assign) BOOL isStartStop;

/**
 *  @author crash         crash_wu@163.com   , 16-10-14 14:10:59
 *
 *  @brief  公交起点站点
 */
@property(nonatomic,strong,nullable) NSString *starStop;

/**
 *  @author crash         crash_wu@163.com   , 16-10-14 14:10:26
 *
 *  @brief  公交终点站点
 */
@property(nonatomic,strong,nullable) NSString *endStop;


@property(nonatomic,strong,nullable) BusStopPresentable * busStopPresentable;

@end

@implementation BusStopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.startSearchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.startSearchBtn];
    
    self.startSearchBtn.frame  = CGRectMake(10, 10, self.view.frame.size.width - 20, 30);
    [self.startSearchBtn setTitle:@"搜鹤山广场公交站" forState:UIControlStateNormal];
    [self.startSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startSearchBtn.backgroundColor = [UIColor blueColor];
    [self.startSearchBtn addTarget:self action:@selector(starStopSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.endSearchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.endSearchBtn];
    
    self.endSearchBtn.frame = CGRectMake(10, 50, self.view.frame.size.width - 20, 30);
    [self.endSearchBtn setTitle:@"搜汽车总站" forState:UIControlStateNormal];
    [self.endSearchBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.endSearchBtn.backgroundColor = [UIColor blueColor];
    [self.endSearchBtn addTarget:self action:@selector(endStopSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    self.busStopSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    self.busStopSearch.frame = CGRectMake(10, 100, self.view.frame.size.width - 20, 30);
    [self.busStopSearch setTitle:@"搜索公交路线" forState:UIControlStateNormal];
    [self.busStopSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.busStopSearch.backgroundColor = [UIColor redColor];
    [self.busStopSearch addTarget:self action:@selector(searchBusLine:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.busStopSearch];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 140, self.view.frame.size.width - 20, self.view.frame.size.height - 160) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


/**
 *  @author crash         crash_wu@163.com   , 16-10-14 15:10:59
 *
 *  @brief  搜索公交站点起点
 *
 *  @param button <#button description#>
 */
-(void)starStopSearch:(UIButton *)button{
    self.isStartStop = true;
    [self searchBusStop:@"鹤山广场"];
}

/**
 *  @author crash         crash_wu@163.com   , 16-10-14 15:10:44
 *
 *  @brief  搜索公交站点终点
 *
 *  @param button <#button description#>
 */
-(void)endStopSearch:(UIButton *)button{
    self.isStartStop = false;
    [self searchBusStop:@"汽车总站"];
}

/**
 *  @author crash         crash_wu@163.com   , 16-10-14 15:10:36
 *
 *  @brief  搜索公交路线
 *
 *  @param button <#button description#>
 */
-(void)searchBusLine:(UIButton *)button{
    
    if (!self.starStop) {
        [SVProgressHUD showErrorWithStatus:@"请先搜索鹤山广场"];
        return;
    }
    
    if (!self.endStop) {
        
        [SVProgressHUD showErrorWithStatus:@"请先搜索汽车总站"];
        return;
    }
    
    
    [self busLineSearch:self.starStop andEndStop:self.endStop];
}

/**
 *  @author crash         crash_wu@163.com   , 16-10-12 18:10:25
 *
 *  @brief  搜索公交站点
 *
 *  @param stopName 公交站点名称
 */
-(void)searchBusStop:(NSString *)stopName{
    
    __weak typeof(&* self) weak = self;
    
    if (!self.busStopPresentable ) {
        self.busStopPresentable = [[BusStopPresentable alloc] init];
        self.busStopPresentable.tableView = self.tableView;
        self.busStopPresentable.busStopDelegate = self;
    }
    
    [[SGBusStopServiceHandler sharedInstance] busStopService:stopName success:^(NSArray<NSString *> * _Nullable stopNames) {
        weak.tableView.hidden = false;
        [weak.busStopPresentable rendBusStopData:stopNames];
    } fail:^(NSError * _Nullable error) {
        
    }];
}


#pragma mark - BusStopSelectDelegate
-(void)busStopSelect:(NSString *)busStop{
    //判断是公交起点站点查询，还是公交终点站点查询
    if (self.isStartStop) {
        //起点站点

        self.starStop = busStop;
        
    }else{
        //终点站点

        self.endStop = busStop;
    }
    self.tableView.hidden = true;
}


#pragma mark - 公交路线查询
/**
 *  @author crash         crash_wu@163.com   , 16-10-13 09:10:44
 *
 *  @brief  公交路线查询
 *
 *  @param starStop 公交路线起点站点
 *  @param endStop  公交路线终点站点
 */
-(void)busLineSearch:(NSString *_Nullable)starStop andEndStop:(NSString *_Nullable)endStop{
    
    __weak typeof(&*self) weak = self;
    //公交
    [[SGBusLineServiceHandler sharedInstance] busLineService:starStop andEnd:endStop success:^(NSArray<BusTravelsModel *> * _Nullable busLines) {
        
        if (busLines.count > 0) {
            
            [weak.navigationController pushViewController:[[BusLineViewController alloc] initWithBusLine:busLines andStarStop:self.starStop andEndStop:self.endStop] animated:true];
        }
        
    } fail:^(NSError * _Nullable error) {
        
    }];
}


@end
