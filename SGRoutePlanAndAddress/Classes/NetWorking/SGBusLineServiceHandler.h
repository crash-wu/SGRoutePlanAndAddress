//
//  ChangShaBusLineServiceHandler.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/27.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SGSHTTPModule/SGSHTTPModule.h>
#import "BusLineMessageModel.h"
#import <SVProgressHUD/SVProgressHUD.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 20:09:14
 *
 *  @brief  公交路线查询
 */
@interface SGBusLineServiceHandler : SGSBaseRequest


/**
 *  @author crash         crash_wu@163.com   , 16-09-27 20:09:27
 *
 *  @brief  路线起点地址
 */
@property(nonatomic,strong,nullable) NSString *start;

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 20:09:09
 *
 *  @brief  路线终点
 */
@property(nonatomic,strong,nullable) NSString *end;


/**
 *  @author crash         crash_wu@163.com   , 16-09-27 15:09:55
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype)sharedInstance;


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 09:09:57
 *
 *  @brief  公交路线搜索
 *
 *  @param start   起点地址
 *  @param end     终点地址
 *  @param success 搜索成功block
 *  @param fail    搜索失败block
 */
-(void)busLineService:(NSString *_Nullable) start andEnd:(NSString *_Nullable) end success:(nonnull void(^)(NSArray<BusTravelsModel *> *_Nullable busLines))success fail:(nonnull void(^)(NSError *_Nullable error))fail;

@end
