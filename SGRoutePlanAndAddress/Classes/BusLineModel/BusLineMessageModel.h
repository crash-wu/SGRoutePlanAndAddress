//
//  BusLineMessageModel.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/28.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusTravelsModel.h"
#import <SGSHTTPModule/SGSHTTPModule.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 08:09:47
 *
 *  @brief  公交路线信息实体
 */
@interface BusLineMessageModel : NSObject<SGSResponseObjectSerializable>

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 10:09:54
 *
 *  @brief  公交路线终点地址
 */
@property(nonatomic,strong,nullable) NSString *end;

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 10:09:33
 *
 *  @brief  公交路线起点地址
 */
@property(nonatomic,strong,nullable) NSString *start;

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 14:09:48
 *
 *  @brief  公交路线数组
 */
@property(nonatomic,strong,nullable) NSArray<BusTravelsModel *> *travels;

@end
