//
//  BusLinesModel.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/29.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
#import <SGSHTTPModule/SGSHTTPModule.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 10:09:14
 *
 *  @brief  单条公交路线
 */
@interface BusLinesModel : NSObject<SGSResponseCollectionSerializable>


/**
 *  @author crash         crash_wu@163.com   , 16-09-29 10:09:46
 *
 *  @brief  公交线路名称
 */
@property(nonatomic,strong,nullable) NSString *lineName;

/**
 *  @author crash         crash_wu@163.com   , 16-09-29 10:09:28
 *
 *  @brief  经过站点
 */
@property(nonatomic,strong,nullable) NSArray<NSString *> *stopName;

@end
