//
//  GDRouteHandler.m
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import "GDRouteHandler.h"
#import "GDPathListModel.h"

@interface GDRouteHandler()

//起点
@property(nonatomic,strong,nonnull) AGSPoint *from;

//终点
@property(nonatomic,strong,nonnull) AGSPoint *to;

@end

@implementation GDRouteHandler


/**
 单例
 */
+(nonnull instancetype )sharedManager{
    
    static GDRouteHandler *shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        shared = [[self alloc]init];
    });
    
    return shared;
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
    NSInteger status = [[json objectForKey:@"status"] integerValue];
    
    if (status != 1) {
        NSString *desc = [json objectForKey:@"description"];
        self.error = [NSError errorWithDomain:@"com.southgis.error" code:status userInfo:@{NSLocalizedDescriptionKey: desc ?: @""}];
        
        // 清空返回结果
        self.responseData = nil;
        
        return ;
    }
    
    // 获取结果
    id result = [json objectForKey:@"data"];
    
    if (result != nil) {
        
        id path_list = [result objectForKey:@"path_list"];
        if (path_list != nil) {
            
            // 重置结果
            self.responseData = [NSJSONSerialization dataWithJSONObject:path_list options:kNilOptions error:nil];
            
        }else{
            self.responseData = nil;
        }

    } else {
        self.responseData = nil;
    }
}


-(NSString *)requestURL{
    
    if (self.from && self.to) {
        
           return [NSString stringWithFormat:@"http://ditu.amap.com/service/autoNavigat?coor_need=true&rendertemplate=1&invoker=plan&engine_version=3&start_types=1&end_types=1&viapoint_types=1&policy2=1&fromX=%lf&fromY=%lf&toX=%lf&toY=%lf&key=bfe31f4e0fb231d29e1d3ce951e2c780",self.from.x,self.from.y,self.to.x,self.to.y];
        
    }else{
        
        return [NSString stringWithFormat:@"http://ditu.amap.com/service/autoNavigat?coor_need=true&rendertemplate=1&invoker=plan&engine_version=3&start_types=1&end_types=1&viapoint_types=1&policy2=1&fromX=113.37381&fromY=23.1237&toX=113.182951&toY=23.257951&key=bfe31f4e0fb231d29e1d3ce951e2c780"];
    }
    
}


// 响应对象类型
- (nullable Class<SGSResponseCollectionSerializable>)responseObjectArrayClass{
    
    return [GDPathListModel class];
}


/**
 高德地图路线规划

 @param from 起点
 @param to 终点
 @param success 搜索成功
 @param fail 搜索失败
 */
-(void)gdRoute:(AGSPoint *_Nonnull)from andTo:(AGSPoint *_Nonnull)to andSuccess:(void(^) (AGSMutablePolyline *_Nonnull polyline)  ) success andFail:(void(^) (NSError *_Nullable error)) fail{
    
    self.from = from;
    self.to = to;
    
    [self startWithCompletionSuccess:^(__kindof SGSBaseRequest * _Nonnull request) {
        
        NSArray<GDPathListModel *> *models =( NSArray<GDPathListModel *>*) request.responseObjectArray;
        
        if (models.count > 0) {
            
            AGSMutablePolyline *polyline = [[GDRouteAnalysisManager sharedManager] analysisGDRoute:models[0]];
            
            success(polyline);
        }
        
    } failure:^(__kindof SGSBaseRequest * _Nonnull request) {
        
        fail(request.error);

    }];
}

@end
