//
//  ChangShaAddressServiceHandler.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/28.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGAddressServiceHandler.h"

@interface SGAddressServiceHandler ()

/**
 *  @author crash         crash_wu@163.com   , 16-10-14 17:10:48
 *
 *  @brief  请求服务url
 */
@property(nonatomic,strong,nullable) NSString *url;

@end

@implementation SGAddressServiceHandler


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 15:09:49
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance{
    
    static SGAddressServiceHandler *instance = nil;
    static dispatch_once_t onceToken ;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc]init];
    });
    
    return instance;
}


/**
 *  @author crash         crash_wu@163.com   , 16-09-09 09:09:57
 *
 *  @brief  重新请求方法
 *
 *  @return 返回指定的请求方法为
 */
-(SGSRequestMethod)requestMethod{
    return SGSRequestMethodGet;
}



-(SGSRequestSerializerType)requestSerializerType{
    return SGSRequestSerializerTypeJSON;
}


/**
 *  @author crash         crash_wu@163.com   , 16-09-09 09:09:07
 *
 *  @brief  重写 requestURL 方法
 *
 *  @return 返回纠错请求地址
 */
-(NSString *)requestURL{

    return self.url;
//    return @"http://192.168.10.72:8088/cloud_place/gazetteer/search.do";
}

-(id)requestParameters{
    
    
    return  [self.searchModel yy_modelToJSONObject];
}


- (nullable Class<SGSResponseCollectionSerializable>)responseObjectArrayClass{
    
    return [SGAddressModel class];
}

- (void)requestCompleteFilter {
    // 如果有错误直接返回
    if (self.error != nil) return ;
    
    id json = self.responseJSON;
    
    // 不是JSON数据
    if ((json == nil) || ![json isKindOfClass:[NSDictionary class]]) {
        self.error = [NSError errorWithDomain:@"com.southgis.error" code:-8000 userInfo:@{NSLocalizedDescriptionKey: @"非JSON数据"}];
        
        // 清空返回结果
        self.responseData = nil;
        return ;
    }
    
    // 返回的状态码不合法
    NSInteger code = [[json objectForKey:@"code"] integerValue];
    
    if (code != 200) {
        NSString *desc = [json objectForKey:@"description"];
        self.error = [NSError errorWithDomain:@"com.southgis.error" code:code userInfo:@{NSLocalizedDescriptionKey: desc ?: @""}];
        
        // 清空返回结果
        self.responseData = nil;
    }
    
    // 获取结果
    id result = [json objectForKey:@"results"];
    NSArray *rows = [result objectForKey:@"rows"];
    
    if (rows != nil) {
        // 重置结果
        self.responseData = [NSJSONSerialization dataWithJSONObject:rows options:kNilOptions error:nil];
    } else {
        self.responseData = nil;
    }
}


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
-(void)changShaAddressService:(SGAddressSearchModel *_Nullable)searchModel andUrl:(NSString *_Nullable)url success:(nonnull void(^)(NSArray<SGAddressModel *> *_Nullable models))success fail:(nonnull void (^)(NSError *_Nullable error))fail{

    self.url = url;
    [SVProgressHUD showWithStatus:@"正在搜索数据..."];
    self.searchModel = searchModel;
    [self startWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
        
        NSArray<SGAddressModel *> *models =( NSArray<SGAddressModel *>*) request.responseObjectArray;
        
        if (!models && models.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"无该类型数据"];
        }else{
            [SVProgressHUD dismiss];
        }
        success(models);
        
    } failure:^(__kindof SGSBaseRequest * _Nonnull request) {
        [SVProgressHUD showErrorWithStatus:@"搜索失败"];
        fail(request.error);
    }];
    
}

@end
