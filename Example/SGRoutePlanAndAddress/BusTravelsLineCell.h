//
//  BusTravelsLineCell.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/29.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "BusTravelsContentView.h"

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 15:09:10
 *
 *  @brief  公交路线表格单元格
 */
@interface BusTravelsLineCell : UITableViewCell

/**
 *  @author crash         crash_wu@163.com   , 16-09-30 09:09:28
 *
 *  @brief  单元格内容页面
 */
@property(nonatomic,strong,nonnull) BusTravelsContentView *busLineDetailContentView;

@end
