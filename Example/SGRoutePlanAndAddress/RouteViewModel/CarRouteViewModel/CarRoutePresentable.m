//
//  CarRoutePresentable.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CarRoutePresentable.h"

static NSString *CARROUTEPRESENTABLE = @"carRoutePresentable";

static NSString *SUPERCONTROLLER = @"superController";

@interface CarRoutePresentable ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation CarRoutePresentable

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 08:09:04
 *
 *  @brief  set函数
 *
 *  @param tableView
 */
-(void)setTableView:(UITableView *)tableView{
    
    objc_setAssociatedObject(self, &CARROUTEPRESENTABLE, tableView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 08:09:19
 *
 *  @brief  get函数
 *
 *  @return 
 */
-(UITableView *)tableView{
    
    UITableView *tableView = (UITableView *)objc_getAssociatedObject(self, &CARROUTEPRESENTABLE);
    [tableView registerClass:[CarRouteDetailCell class] forCellReuseIdentifier:CARROUTEPRESENTABLE];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return tableView;
}

-(void)setViewController:(UIViewController *)viewController{
    
    objc_setAssociatedObject(self, &SUPERCONTROLLER, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIViewController *)viewController{
    
    UIViewController *viewController = (UIViewController *)objc_getAssociatedObject(self, &SUPERCONTROLLER);
    
    return viewController;
}

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:39
 *
 *  @brief  数据渲染
 *
 *  @param carRoute    驾车路线
 *  @param starAddress 路线起点
 *  @param stopAddress 路线终点
 */
-(void)rendCarRouteDate:(AGSRouteResult * _Nullable) carRoute andStarAddress:(NSString *_Nullable) starAddress andStopAddress:(NSString *_Nullable) stopAddress{
    self.carRoute = carRoute;
    self.carRouteDirectionS = carRoute.directions.graphics;
    self.starAddress =starAddress;
    self.stopAddress = stopAddress;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDateSource ,UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.carRouteDirectionS.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CarRouteDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CARROUTEPRESENTABLE forIndexPath:indexPath];
    
    AGSDirectionGraphic *direction = self.carRouteDirectionS[indexPath.row];

    if (indexPath.row == 0) {
        cell.upLine.hidden = true;
        cell.downLine.hidden = NO;
        cell.plottingImageView.image = [UIImage imageNamed:@"jiache_start"];
        cell.detailLb.text = self.starAddress;
    }else if(indexPath.row == self.carRouteDirectionS.count - 1) {
        
        cell.upLine.hidden = NO;
        cell.downLine.hidden = true;
        cell.plottingImageView.image = [UIImage imageNamed:@"jiache_end"];
        cell.detailLb.text = self.stopAddress;
        
    }else{
        
        cell.upLine.hidden = NO;
        cell.downLine.hidden = NO;
        cell.plottingImageView.image = [UIImage imageNamed:@"jiache_icon"];
        cell.detailLb.text = direction.text;
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    [self.viewController.navigationController pushViewController:[[CarRouteDetailSegmentViewController alloc] initWithCarRoute:self.carRoute andShowRow:indexPath.row andStarAddress:self.starAddress andStopAddress:self.stopAddress] animated:true];
}
@end
