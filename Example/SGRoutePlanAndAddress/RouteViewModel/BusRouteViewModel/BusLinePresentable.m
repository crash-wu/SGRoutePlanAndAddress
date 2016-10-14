//
//  BusLinePresentable.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/29.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "BusLinePresentable.h"

static NSString *BUSLINETABLE = @"busLineTableView";

static NSString *VIEWCONTROLLER = @"viewController";

@interface BusLinePresentable ()<UITableViewDelegate,UITableViewDataSource>


/**
 *  @author crash         crash_wu@163.com   , 16-09-29 16:09:21
 *
 *  @brief  公交路线数组
 */
@property(nullable,nonatomic,strong) NSArray<BusTravelsModel *> *busTravels;

/**
 *  @author crash         crash_wu@163.com   , 16-09-30 11:09:02
 *
 *  @brief  起点地址
 */
@property(nullable ,nonatomic,strong) NSString *starStop;

/**
 *  @author crash         crash_wu@163.com   , 16-09-30 11:09:10
 *
 *  @brief  终点地址
 */
@property(nullable,nonatomic,strong) NSString *endStop;

@end

@implementation BusLinePresentable

-(void)setTableView:(UITableView *)tableView{
    
    objc_setAssociatedObject(self, &BUSLINETABLE, tableView,OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}


-(UITableView *)tableView{
    
    UITableView *tableView =(UITableView *) objc_getAssociatedObject(self, &BUSLINETABLE);
    [tableView registerClass:[BusTravelsLineCell class] forCellReuseIdentifier:@"BusLineCell"];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    return  tableView;
}

-(void)setViewController:(UIViewController *)viewController{
    
    objc_setAssociatedObject(self, &VIEWCONTROLLER, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIViewController *)viewController{
    
    UIViewController *vc = (UIViewController *)objc_getAssociatedObject(self, &VIEWCONTROLLER);
    
    return vc  ;
}


/**
 *  @author crash         crash_wu@163.com   , 16-09-29 16:09:19
 *
 *  @brief  数据渲染
 *
 *  @param busTravels 公交路线数组
 *
 *  @param starStop 起点地址
 *
 *  @param endStop 终点地址
 */
-(void)rendBusTravelsDate:(NSArray<BusTravelsModel *>  *_Nullable)busTravels andStarStop:(NSString *_Nullable) starStop andEndStop:(NSString *_Nullable) endStop{
    
    self.starStop = starStop;
    self.endStop = endStop;
    self.busTravels = busTravels;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.busTravels.count;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BusTravelsLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusLineCell" forIndexPath:indexPath ];
    
    BusTravelsModel *busModel = self.busTravels[indexPath.row];
    
    NSString *lineName = @"";
    
    for (BusLinesModel *lineModel in busModel.lines) {
        
        lineName = [NSString stringWithFormat:@"%@ -> %@",lineName,lineModel.lineName];
        
    }
    
    if (busModel.lines.count == 1) {
        cell.busLineDetailContentView.changNumLb.text = @"无需换乘";
        
    }else{
        cell.busLineDetailContentView.changNumLb.text = [NSString stringWithFormat:@"换乘:%lu次",busModel.lines.count -1];
    }

    cell.busLineDetailContentView.stopNameLb.text = [NSString stringWithFormat:@"经过站点:%ld 个",(long)busModel.stopTotal];
    cell.busLineDetailContentView.lineNameLb.text = [lineName substringFromIndex:3];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self.viewController.navigationController pushViewController:[[BusLineShowInMapViewController alloc] initWithBusLineModes:self.busTravels andStarStop:self.starStop andEndStop:self.endStop andRow:indexPath.row] animated:true];
    
}





@end
