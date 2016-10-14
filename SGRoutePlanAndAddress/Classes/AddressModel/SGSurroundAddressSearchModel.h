//
//  ChangShaSurroundAddressSearchModel.h
//  ChangSha
//
//  Created by 吴小星 on 16/10/9.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @author crash         crash_wu@163.com   , 16-10-09 14:10:39
 *
 *  @brief  长沙地名地址周边查询实体
 */
@interface SGSurroundAddressSearchModel : NSObject

/**
 *  @author crash         crash_wu@163.com   , 16-10-09 14:10:03
 *
 *  @brief  周边搜索参考坐标(112.3333,33.21)
 */
@property(nonatomic,nonnull,strong) NSString *location;

/**
 *  @author crash         crash_wu@163.com   , 16-10-09 14:10:46
 *
 *  @brief 周边搜索参考坐标系（wkid）
 */
@property(nonatomic,assign) NSInteger inSR;


/**
 *  @author crash         crash_wu@163.com   , 16-10-09 14:10:16
 *
 *  @brief  周边搜索结果坐标系（wkid,不传入则默认和inSR相同，inSR 为空时，默认为服务器服务的 wkid)
 */
@property(nonatomic,assign) NSInteger outSR;

/**
 *  @author crash         crash_wu@163.com   , 16-10-09 14:10:55
 *
 *  @brief   查询半径，单位为米，以 location 为圆心，distance 为半径查询周边地名地址，默认为 500米
 */
@property(nonatomic,assign)NSInteger  distance;

/**
 *  @author crash         crash_wu@163.com   , 16-10-09 14:10:28
 *
 *  @brief  页码，默认为 1，传入负数或0时强制为1
 */
@property(nonatomic,assign) NSInteger page;

/**
 *  @author crash         crash_wu@163.com   , 16-10-09 14:10:51
 *
 *  @brief  每页数据量，默认为 10，传入负数或0时强制为10
 */
@property(nonatomic,assign) NSInteger size;

/**
 *  @author crash         crash_wu@163.com   , 16-10-09 15:10:45
 *
 *  @brief  周边搜索关键字
 */
@property(nonatomic,strong,nullable) NSString *q;

/**
 *  @author crash         crash_wu@163.com   , 16-10-10 16:10:41
 *
 *  @brief  要搜索的字段 name 只按地名搜索，address 只按地址搜索，不传入或为空字符串则按地名、地址组合搜索
 */
@property(nonatomic,strong,nullable) NSString *field;


@end
