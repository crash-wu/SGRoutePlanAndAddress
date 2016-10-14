//
//  BusStopCell.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/27.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>


/**
 *  @author crash         crash_wu@163.com   , 16-09-27 17:09:13
 *
 *  @brief  公交站点单元格
 */
@interface BusStopCell : UITableViewCell

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 17:09:39
 *
 *  @brief  搜索图标
 */
@property(nonatomic,strong,nullable) UIImageView *searchImageView;

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 17:09:01
 *
 *  @brief  文本
 */
@property(nonatomic,strong,nullable) UILabel *detailLb;


/**
 *  @author crash         crash_wu@163.com   , 16-09-27 17:09:04
 *
 *  @brief  分割线
 */
@property(nonatomic,strong,nullable) UIView *line;

@end
