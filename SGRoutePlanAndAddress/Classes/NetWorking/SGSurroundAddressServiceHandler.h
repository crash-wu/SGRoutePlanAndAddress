//
//  ChangShaSurroundAddressServiceHandler.h
//  ChangSha
//
//  Created by 吴小星 on 16/10/9.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SGSHTTPModule/SGSHTTPModule.h>
#import <YYModel/YYModel.h>
#import "SGAddressModel.h"
#import "SGSurroundAddressSearchModel.h"
#import <SVProgressHUD/SVProgressHUD.h>

/**
 *  @author crash         crash_wu@163.com   , 16-10-09 14:10:30
 *
 *  @brief  长沙地名地址周边查询
 */
@interface SGSurroundAddressServiceHandler : SGSBaseRequest


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 15:09:32
 *
 *  @brief  地名地址查询
 *
 *  @param searchModel 周边查询实体
 *  @param success     搜索成功block
 *  @param fail        搜索失败block
 */
-(void)changShaSurroundAddressService:(SGSurroundAddressSearchModel *_Nullable)searchModel success:(nonnull void(^)(NSArray<SGAddressModel *> *_Nullable models))success fail:(nonnull void (^)(NSError *_Nullable error))fail;


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 15:09:49
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance;

@end
