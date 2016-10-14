//
//  ChangShaAddressTypeModel.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/28.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SGSHTTPModule/SGSHTTPModule.h>
#import <YYModel/YYModel.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:41
 *
 *  @brief  长沙地名地址搜索结果
 */
@interface SGAddressModel : NSObject<SGSResponseCollectionSerializable>

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:31
 *
 *  @brief  地名地址id
 */
@property(nonatomic,strong,nullable)  NSString *id;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:03
 *
 *  @brief  名称
 */
@property(nonatomic,strong,nullable) NSString *name;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:35
 *
 *  @brief  服务ID
 */
@property(nonatomic,strong,nullable) NSString *objectId;


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:11
 *
 *  @brief  地名类型
 */
@property(nonatomic,strong,nullable) NSString *typecode;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:47
 *
 *  @brief  地址
 */
@property(nonatomic,strong,nullable) NSString *address;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:23
 *
 *  @brief  联系电话
 */
@property(nonatomic,strong,nullable) NSString *tel;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:52
 *
 *  @brief  省份
 */
@property(nonatomic,strong,nullable) NSString *pname;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:29
 *
 *  @brief  城市名称
 */
@property(nonatomic,strong,nullable) NSString *cityname;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:52
 *
 *  @brief  县
 */
@property(nonatomic,strong,nullable) NSString *adname;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:10
 *
 *  @brief  经纬度
 */
@property(nonatomic,strong,nullable) NSString *location;



@end
