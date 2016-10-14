//
//  CarRouteDetailCell.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/26.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 08:09:09
 *
 *  @brief  驾车线路详情单元格
 */
@interface CarRouteDetailCell : UITableViewCell

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 08:09:02
 *
 *  @brief  上竖线
 */
@property(nonatomic,strong,nonnull) UIView *upLine;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 08:09:58
 *
 *  @brief  提示图标
 */
@property(nonatomic,strong,nonnull) UIImageView *plottingImageView;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 08:09:25
 *
 *  @brief  下竖线
 */
@property(nonatomic,strong,nonnull) UIView *downLine;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 08:09:28
 *
 *  @brief  文本
 */
@property(nonnull,strong,nonatomic) UILabel *detailLb;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 09:09:28
 *
 *  @brief  分隔线
 */
@property(nonatomic,strong,nonnull) UIView *separateLine;


/**
 *  @author crash         crash_wu@163.com   , 16-09-26 09:09:19
 *
 *  @brief  右边剪头
 */
@property(nonatomic,strong,nonnull) UIImageView *arrowImagView;


@end
