//
//  BusTravelsContentView.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/30.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-30 09:09:25
 *
 *  @brief  公交路线单元页面
 */
@interface BusTravelsContentView : UIView


/**
 *  @author crash         crash_wu@163.com   , 16-09-29 15:09:17
 *
 *  @brief
 */
@property(nonatomic,strong,nonnull) UILabel *lineNameLb;

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 15:09:45
 *
 *  @brief  站点数
 */
@property(nonatomic,strong,nonnull) UILabel *stopNameLb;

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 15:09:22
 *
 *  @brief  换乘数
 */
@property(nonatomic,strong,nonnull) UILabel *changNumLb;

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 15:09:41
 *
 *  @brief  剪头
 */
@property(nonatomic,strong,nonnull) UIImageView *arrowImageView;

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 15:09:19
 *
 *  @brief  分隔线
 */
@property(nonnull,strong,nonatomic) UIView *separate;

@end
