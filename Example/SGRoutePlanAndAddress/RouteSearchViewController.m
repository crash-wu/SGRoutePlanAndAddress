//
//  RouteSearchViewController.m
//  SGRoutePlanAndAddress
//
//  Created by 吴小星 on 16/10/14.
//  Copyright © 2016年 吴小星. All rights reserved.
//

#import "RouteSearchViewController.h"

@interface RouteSearchViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation RouteSearchViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.view addSubview:self.tableView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -UITableViewDateSource,UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = @"公交";
    }else{
        cell.textLabel.text = @"驾车";
    }
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        
        [self.navigationController pushViewController:[[BusStopViewController alloc] init] animated:true    ];
        
    }else{
        
        [self carRouteSearch];
    }
}


#pragma mark -驾车
/**
 *  @author crash         crash_wu@163.com   , 16-10-13 10:10:04
 *
 *  @brief  驾车路线查询
 *
 *  @param starLocation 起点坐标
 *  @param endLocation  终点坐标
 */
-(void)carRouteSearch{
    
    //获取终点，起点坐标
    
    NSString *starLocation = @"113.112968,26.133061";
    NSString *endLocation = @"113.10751,26.115331";
    
    NSArray *starLonlat = [starLocation componentsSeparatedByString:@","];
    
    NSArray *stopLonlat = [endLocation componentsSeparatedByString:@","];
    
    
    if (starLonlat == nil || starLonlat.count != 2) {
        
        return;
    }
    AGSPoint *startPoint = [[AGSPoint alloc]initWithX:[starLonlat[0]  doubleValue] y:[starLonlat[1] doubleValue] spatialReference:[[AGSSpatialReference alloc]initWithWKID:4490]];
    
    if (stopLonlat == nil || stopLonlat.count != 2) {
        
        return ;
    }
    
    AGSPoint *stopPoint = [[AGSPoint alloc]initWithX:[stopLonlat[0] doubleValue] y:[stopLonlat[1] doubleValue] spatialReference:[[AGSSpatialReference alloc]initWithWKID:4490]];
    
    
    __weak typeof(&*self) weak = self;

    [SVProgressHUD showWithStatus:@"正在搜索数据..."];
    [[SGRouteServiceHandler sharedInstance ] changShaRouteSearch:@[startPoint,stopPoint] success:^(AGSRouteResult * _Nullable resut) {
        

        [SVProgressHUD dismiss];
        [weak.navigationController pushViewController:[[CarRouteResultViewController alloc] initWithRouteResult:resut andStartAddress:@"起点" andStopAddress:@"终点"] animated:true]  ;
        
    } fail:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"搜索不到该段线路信息!"];
    }];
}



@end
