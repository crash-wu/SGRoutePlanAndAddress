//
//  ChangShaAddressServiceHandler.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/28.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SGSHTTPModule/SGSHTTPModule.h>
#import "SGAddressSearchModel.h"
#import <YYModel/YYModel.h>
#import "SGAddressModel.h"
#import <SVProgressHUD/SVProgressHUD.h>

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:49
 *
 *  @brief  地名地址查询
 */
@interface SGAddressServiceHandler : SGSBaseRequest


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 15:09:32
 *
 *  @brief  地名地址查询
 *
 *  @param searchModel 查询实体
 *  @param url         请求服务URL
 *  @param success     搜索成功block
 *  @param fail        搜索失败block
 */
-(void)changShaAddressService:(SGAddressSearchModel *_Nullable)searchModel
   andUrl:(NSString *_Nullable)url
  success:(nonnull void(^)(NSArray<SGAddressModel *> *_Nullable models))success
     fail:(nonnull void (^)(NSError *_Nullable error))fail;


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 14:09:09
 *
 *  @brief  地名地址搜索请求实体
 */
@property(nonatomic,strong,nullable) SGAddressSearchModel *searchModel;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 15:09:49
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance;


@end
