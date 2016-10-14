//
//  ChangShaAddressSearchModel.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/28.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 12:09:57
 *
 *  @brief  长沙地名地址查询请求实体
 */
@interface SGAddressSearchModel : NSObject


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 12:09:28
 *
 *  @brief  搜索关键字，不传入或为空字符串则查询所有地名
 */
@property(nonatomic,strong,nullable) NSString *q;


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 12:09:56
 *
 *  @brief   要搜索的字段 name 只按地名搜索，address 只按地址搜索，不传入或为空字符串则按地名、地址组合搜索
 */
@property(nonatomic,strong,nullable) NSString *field;


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:41
 *
 *  @brief  页码（必须为整数，不传入则默认为 1）
 */
@property(nonatomic,assign) NSInteger page;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:27
 *
 *  @brief 每页显示数据量
 */
@property(nonatomic,assign) NSInteger size;



@end
