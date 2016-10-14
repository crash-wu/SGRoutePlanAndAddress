//
//  BusTravelLineModel.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/29.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusLinesModel.h"
#import <YYModel/YYModel.h>
#import <SGSHTTPModule/SGSHTTPModule.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 10:09:33
 *
 *  @brief  公交线路段信息
 */
@interface BusTravelsModel : NSObject<SGSResponseObjectSerializable>

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 10:09:54
 *
 *  @brief  站点经过
 */
@property(nonatomic,assign) NSInteger stopTotal;

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 10:09:09
 *
 *  @brief   单条线路信息
 */
@property(nonatomic,strong,nullable) NSArray<BusLinesModel *> *lines;


@end
