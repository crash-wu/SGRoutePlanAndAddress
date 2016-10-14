//
//  BusStopPresentable.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/27.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "BusStopPresentable.h"

static NSString *BUSSTOPTABLE = @"busStopTalbe";

@interface BusStopPresentable ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation BusStopPresentable


-(void)setTableView:(UITableView *)tableView{
    
    objc_setAssociatedObject(self, &BUSSTOPTABLE, tableView,OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    
}

-(UITableView*)tableView{
    
    UITableView *tableView =(UITableView *) objc_getAssociatedObject(self, &BUSSTOPTABLE);
    [tableView registerClass:[BusStopCell class] forCellReuseIdentifier:@"busStopCell"];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    return tableView;
}

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 19:09:15
 *
 *  @brief  数据渲染
 *
 *  @param busStops 公交站点数据
 */
-(void)rendBusStopData:(NSArray<NSString *> *)busStops{
    
    self.busStops = busStops;
    [self.tableView reloadData];
    
}


#pragma mark -UITableViewDelegate ,UITableDateSource

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.busStops.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BusStopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"busStopCell" forIndexPath:indexPath];
    cell.detailLb.text = self.busStops[indexPath.row];
    cell.searchImageView.image = [UIImage imageNamed:@"search_img"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.busStopDelegate && [self.busStopDelegate respondsToSelector:@selector(busStopSelect:)]) {
        
        [self.busStopDelegate busStopSelect:self.busStops[indexPath.row]];
    }
}

@end
