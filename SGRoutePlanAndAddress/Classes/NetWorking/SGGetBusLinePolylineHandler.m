//
//  ChangShaGetBusLinePolylineHandler.m
//  ChangSha
//
//  Created by 吴小星 on 16/10/11.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGGetBusLinePolylineHandler.h"

typedef void(^Success)(NSArray<AGSGraphic *> *_Nullable graphics);

typedef void(^Failed)(NSError  *_Nullable error);

@interface SGGetBusLinePolylineHandler ()<AGSQueryTaskDelegate>

@property(nonatomic,strong,nullable)  AGSQueryTask *querytask;

@property(nonatomic,copy) Success success;
@property(nonatomic,copy) Failed failed;



@end

@implementation SGGetBusLinePolylineHandler


/**
 *  @author crash         crash_wu@163.com   , 16-09-06 15:09:48
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance{
    static SGGetBusLinePolylineHandler *instance = nil;
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


-(void)dealloc{
    
    self.querytask = nil;
}

/**
 *  @author crash         crash_wu@163.com   , 16-10-11 10:10:56
 *
 *  @brief  获取公交路线线路坐标
 *
 *  @param starStop     起点站点
 *  @param endStop      终点站点
 *  @param travelsModel 公交路线实体
 *  @param url          服务地址（ArcGIS 服务）
 *  @param success      成功block
 *  @param failed       失败block
 */
-(void)busStopLine:(NSString *_Nonnull)starStop andEndStop:(NSString *_Nonnull)endStop andBusTravles:(BusTravelsModel *_Nullable) travelsModel andURL:(NSString *_Nullable)url succes:
(nonnull void (^)( NSArray<AGSGraphic *> *_Nullable graphics))success failed:
(nonnull void(^)(NSError *_Nullable error))failed{


    //NSString *url = @"http://59.37.169.186:6080/arcgis/rest/services/hsgongjiao/MapServer/1";
    
    
    AGSQuery *query = [AGSQuery query];
    query.returnGeometry = true;
    

    if (self.querytask) {
        
        self.querytask = nil;
    }

    self.querytask = [[AGSQueryTask alloc]initWithURL:[NSURL URLWithString:url]];
    self.querytask.timeoutInterval = 30;
    //起点站点
    NSString *whereClause = [NSString stringWithFormat:@"STOP1 = '%@'",starStop];
    
    NSString *firstS = @"%";
    NSString *lastS = @"%";
    
    NSString *lastStop = nil;
    for(int i = 0;i< travelsModel.lines.count;i++){
        
        BusLinesModel *busline  = travelsModel.lines[i];
        
        if (lastStop) {
            
            whereClause = [whereClause stringByAppendingFormat:@" or STOP1 = '%@'",lastStop];
            lastStop = nil;
        }
        
        whereClause = [whereClause stringByAppendingFormat:@" and (XLM like '%@%@%@')",firstS,busline.lineName,lastS];
        
        for (int j = 0; j<busline.stopName.count; j++) {
            
            NSString *busStop = busline.stopName[j];
            whereClause = [whereClause stringByAppendingFormat:@" and STOP2 = '%@'",busStop];
            whereClause = [whereClause stringByAppendingFormat:@" or STOP1 = '%@'",busStop];
            whereClause = [whereClause stringByAppendingFormat:@" and (XLM like '%@%@%@')",firstS,busline.lineName,lastS];
            
            if (i != travelsModel.lines.count - 1 && j == busline.stopName.count -1) {
                lastStop = busStop;
            }
        }
        
        if (lastStop) {
            whereClause = [whereClause stringByAppendingFormat:@" and STOP2 = '%@'",lastStop];
        }
    }

    whereClause = [whereClause stringByAppendingFormat:@" and STOP2 = '%@'",endStop];
    self.success = success;
    self.failed = failed;


    
    /*
    @"stop1 = '汽车总站' and (xlm like '%506%') and stop2 = '文明酒店1' or stop1 = '文明酒店1' and (xlm like '%506%') and stop2 = '文边村1' or stop1 = '文边村1' and (xlm like '%506%') and stop2 = '中医院0' or stop1 = '中医院0' and (xlm like '%506%') and stop2 = '邮政局1' or stop1 = '邮政局1' and (xlm like '%506%') and stop2 = '中山桥1' or stop1 = '中山桥1' and (xlm like '%506%') and stop2 = '联通公司0' or stop1 = '联通公司0' and (xlm like '%506%') and stop2 = '电信广场0' or stop1 = '电信广场0' and (xlm like '%506%') and stop2 = '中东西牌坊0' or stop1 = '中东西牌坊0' and (xlm like '%506%') and stop2 = '鹤华中学0' or stop1 = '鹤华中学0' and (xlm like '%506%') and stop2 = '英皇数字影院0' or stop1 = '英皇数字影院0' and (xlm like '%506%') and (xlm like '%505%') and stop2 = '英皇数字影院1' or stop1 = '英皇数字影院1' and (xlm like '%505%') and stop2 = '鹤山广场'"*/
    
    query.whereClause = whereClause;
    [self.querytask executeWithQuery:query];
    self.querytask.delegate=self;
}




#pragma mark -AGSQueryTaskDelegate
-(void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didExecuteWithFeatureSetResult:(AGSFeatureSet *)featureSet{
    
    NSArray *features  = featureSet.features;
    if (self.success) {
        
        self.success(features);
    }
}

-(void)queryTask:(AGSQueryTask *)queryTask operation:(NSOperation *)op didFailQueryFeatureCountWithError:(NSError *)error{
    self.failed(error);
}

@end
