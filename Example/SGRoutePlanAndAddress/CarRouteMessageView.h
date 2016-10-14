//
//  CarRouteMessageView.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>


/**
 *  @author crash         crash_wu@163.com   , 16-09-23 11:09:28
 *
 *  @brief  驾车路线信息页面
 */
@interface CarRouteMessageView : UIView

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 11:09:39
 *
 *  @brief  地址
 */
@property(nonatomic,strong,nullable) UILabel *addressLb;


/**
 *  @author crash         crash_wu@163.com   , 16-09-23 11:09:35
 *
 *  @brief  路程标题
 */
@property(nonatomic,strong,nullable) UILabel *placeholderLb;



/**
 *  @author crash         crash_wu@163.com   , 16-09-23 11:09:22
 *
 *  @brief  路程
 */
@property(nonatomic,strong,nullable) UILabel *distancLb;

@end
