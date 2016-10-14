//
//  CarRouteResultDetailView.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

@interface CarRouteResultDetailView : UIView

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 17:09:35
 *
 *  @brief  驾车路线起点终点地址查询
 */
@property(nonatomic,strong,nullable) UILabel *addressLb;

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 17:09:18
 *
 *  @brief  表格
 */
@property(nonatomic,strong,nullable) UITableView *tableView;

@end
