//
//  ChangShaBusLineServiceHandler.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/27.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGBusLineServiceHandler.h"

@interface SGBusLineServiceHandler ()

/**
 *  @author crash         crash_wu@163.com   , 16-10-14 17:10:48
 *
 *  @brief  请求服务url
 */
@property(nonatomic,strong,nullable) NSString *url;

@end

@implementation SGBusLineServiceHandler


/**
 *  @author crash         crash_wu@163.com   , 16-09-27 15:09:55
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype)sharedInstance{
    static SGBusLineServiceHandler *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc ]init];
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


-(nullable Class<SGSResponseObjectSerializable>)responseObjectClass{
    
    return [BusLineMessageModel class];
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
    //return @"http://192.168.10.72:8086/busquery/busTransferServlet";
}

-(id)requestParameters{
    
    return  @{@"start":[NSString stringWithFormat:@"%@",self.start],@"end":[NSString stringWithFormat:@"%@",self.end],@"request":@"getRoutes"};
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
    
}


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 09:09:57
 *
 *  @brief  公交路线搜索
 *
 *  @param start   起点地址
 *  @param end     终点地址
 *  @param url     公交路线搜索URL
 *  @param success 搜索成功block
 *  @param fail    搜索失败block
 */
-(void)busLineService:(NSString *_Nullable) start andEnd:(NSString *_Nullable) end andURL:(NSString *_Nullable)url success:(nonnull void(^)(NSArray<BusTravelsModel *> *_Nullable busLines))success fail:(nonnull void(^)(NSError *_Nullable error))fail{

    self.url = url;
    [SVProgressHUD showWithStatus:@"正在获取公交信息..."];
    self.start = start;
    self.end = end;
    
    [self startWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
        if (success) {
            
            BusLineMessageModel *model =(BusLineMessageModel *) request.responseObject;
            NSArray<BusTravelsModel *> *lines = model.travels;
            
            if (lines.count ==0) {
                [SVProgressHUD showErrorWithStatus:@"无该线路公交信息!"];
            }else{
                [SVProgressHUD dismiss];
            }
            
            success(lines);
            
        }
    } failure:^(__kindof SGSBaseRequest * _Nonnull request) {
        if (fail) {
            [SVProgressHUD showErrorWithStatus:@"获取公交路线失败!"];
            fail(request.error);
        }
    }];

    
}


@end
