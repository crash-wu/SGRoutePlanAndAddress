//
//  ChangShaGetBusStopLocationHandler.m
//  ChangSha
//
//  Created by 吴小星 on 16/10/11.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGGetBusStopLocationHandler.h"

typedef void(^Success)(NSArray<AGSGraphic *> *_Nullable graphic);

typedef void(^Failed)(NSError  *_Nullable error);

@interface SGGetBusStopLocationHandler ()<AGSQueryTaskDelegate>

@property(nonatomic,strong,nullable)  AGSQueryTask *querytask;
@property(nonatomic,copy) Success success;
@property(nonatomic,copy) Failed failed;

@end

@implementation SGGetBusStopLocationHandler


/**
 *  @author crash         crash_wu@163.com   , 16-09-06 15:09:48
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance{
    static SGGetBusStopLocationHandler *instance = nil;
    static dispatch_once_t one;
    dispatch_once(&one, ^{
        
        instance = [[self alloc]init];
    });
    
    return instance;
}

-(instancetype)init{
    self = [super init];
    if (self) {

    }
    return  self;
}



/**
 *  @author crash         crash_wu@163.com   , 16-10-11 10:10:56
 *
 *  @brief  获取公交路线途径站点经纬度
 *
 *  @param starStop     起点站点
 *  @param endStop      终点站点
 *  @param travelsModel 公交路线实体
 *  @param url          获取公交路线途径站点经纬度服务URL(ArcGIS 服务)
 *  @param success      成功block
 *  @param failed       失败block
 */
-(void)busStopLocation:(NSString *_Nonnull)starStop andEndStop:(NSString *_Nonnull)endStop andBusTravles:(BusTravelsModel *_Nullable) travelsModel andURL:(NSString *_Nullable)url succes:
(nonnull void (^)( NSArray<AGSGraphic *> *_Nullable graphics))success failed:
(nonnull void(^)(NSError *_Nullable error))failed{
    
    AGSQuery  *query = [AGSQuery query];
    query.returnGeometry = true;



//    NSString *url = @"http://59.37.169.186:6080/arcgis/rest/services/hsgongjiao/MapServer/0";
    
    if (self.querytask) {
        
        self.querytask = nil;
    }
   self.querytask=[AGSQueryTask queryTaskWithURL:[NSURL URLWithString:url]];
    
    //起点站点
    NSString *firstS = [NSString stringWithFormat:@"ZDM = '%@'",starStop];

    //中间站点
    for (BusLinesModel *busLine in travelsModel.lines) {
        
        for (NSString *stop in busLine.stopName) {
            
            firstS = [firstS stringByAppendingFormat:@" or ZDM = '%@'",stop];
        }
        
    }
    
    //终点站点
    firstS = [firstS stringByAppendingFormat:@" or ZDM = '%@'",endStop];
    
    self.success = success;
    self.failed = failed;
    query.whereClause = firstS;
    [self.querytask executeWithQuery:query];
    self.querytask.delegate=self;
}


#pragma mark -AGSQueryTaskDelegate
-(void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet{
    
    NSArray *features  = featureSet.features;

    self.success(features);
}

-(void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didFailQueryFeatureCountWithError:(NSError *)error{
    self.failed(error);
}


@end
