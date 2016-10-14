//
//  ChangShaBusServiceHandler.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/27.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGBusStopServiceHandler.h"

@implementation SGBusStopServiceHandler

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 15:09:55
 *
 *  @brief  单例
 *
 *  @return
 */
+(instancetype)sharedInstance{
    static SGBusStopServiceHandler *instance = nil;
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
 *  @return 返回指定的请求方法为POST
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
    
    return @"http://59.37.169.186:7080/busquery/busStopQueryServlet";

}

-(id)requestParameters{
    
    return  @{@"stopName":self.stopName};
}

- (void)requestCompleteFilter {
    // 如果有错误直接返回
    if (self.error != nil) return ;

}


/**
 *  @author crash         crash_wu@163.com   , 16-09-27 15:09:21
 *
 *  @brief  查询公交站点名称
 *
 *  @param stopName 公交站点名称
 *  @param success  查询成功block
 *  @param fail     查询失败block
 */
-(void)busStopService:(NSString *_Nullable)stopName success:(nonnull void (^)(NSArray<NSString *> *_Nullable stopNames))success fail:(nonnull void(^)(NSError *_Nullable error))fail{

    [SVProgressHUD showWithStatus:@"正在获取公交站点数据..."];
    self.stopName = stopName;
    
    [self startWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
        
        NSString *stopString = [self.responseString stringByReplacingOccurrencesOfString:@"[" withString:@""];
        
        stopString = [stopString stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *stopNames = [stopString componentsSeparatedByString:@","];
        if (!stopNames && stopNames.count > 0) {
            [SVProgressHUD showErrorWithStatus:@"查找不到该类公交站点"];
        }else{
            [SVProgressHUD dismiss];
        }
        success(stopNames);
        
    } failure:^(__kindof SGSBaseRequest * _Nonnull request) {

        [SVProgressHUD showErrorWithStatus:@"查找公交站点失败!"];
        fail(request.error);
    } ];
}

@end
