//
//  ChangShaRouteServiceHandler.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/22.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGRouteServiceHandler.h"

typedef void(^Success)( AGSRouteResult *_Nullable routeResult);

typedef void(^Fail)(NSError *_Nullable error);

@interface SGRouteServiceHandler ()<AGSRouteTaskDelegate>

/**
 *  @author crash         crash_wu@163.com   , 16-09-22 15:09:08
 *
 *  @brief  路线规划请求
 */
@property (nonatomic, strong ,nonnull) AGSRouteTask *routeTask;

/**
 *  @author crash         crash_wu@163.com   , 16-09-22 15:09:40
 *
 *  @brief  路线规划请求对象
 */
@property (nonatomic, strong,nonnull) AGSRouteTaskParameters *routeTaskParams;

/**
 *  @author crash         crash_wu@163.com   , 16-09-22 15:09:14
 *
 *  @brief  路线规划结果
 */
@property(nonatomic,strong,nullable)  AGSRouteResult *routeResult;


/**
 *  @author crash         crash_wu@163.com   , 16-09-22 17:09:13
 *
 *  @brief  路线规划经过的站点
 */
@property(nonatomic,strong,nullable) NSMutableArray<AGSStopGraphic *> *stops;

@property(nonatomic,strong,nullable) Success success;

@property(nonatomic,strong,nullable) Fail fail;

/**
 *  @author crash         crash_wu@163.com   , 16-10-14 17:10:48
 *
 *  @brief  请求服务url
 */
@property(nonatomic,strong,nullable) NSString *url;

@end

@implementation SGRouteServiceHandler

/**
 *  @author crash         crash_wu@163.com   , 16-09-22 16:09:47
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype)sharedInstance{
    
    static SGRouteServiceHandler *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc]init];
    });
    
    return instance;
}


-(instancetype) init{
    if (self = [super init]) {
        
        self.stops = [NSMutableArray array];
    }
    
    return self ;
}

/**
 *  @author crash         crash_wu@163.com   , 16-09-22 16:09:21
 *
 *  @brief  路线规划请求对象懒加载
 *
 *  @return 路线规划请求对象
 */
-(AGSRouteTask *)routeTask{
    
    if (_routeTask == nil) {
        
      //  NSURL *routeTaskUrl = [NSURL URLWithString:@"http://www.dzmap.cn/OneMapServer/rest/services/HUNAN_ROAD/NAServer/road_analyst"];
       NSURL *routeTaskUrl = [NSURL URLWithString:self.url];
        self.routeTask = [AGSRouteTask routeTaskWithURL:routeTaskUrl];
        self.routeTask.delegate = self;

    }
    
    return _routeTask;
}

/**
 *  @author crash         crash_wu@163.com   , 16-09-22 17:09:11
 *
 *  @brief  请求参数懒加载
 *
 *  @return 请求参数
 */
-(AGSRouteTaskParameters *)routeTaskParams{
    if (_routeTaskParams == nil) {
        _routeTaskParams = [[AGSRouteTaskParameters alloc ]init];
        _routeTaskParams.outputGeometryPrecision = 5.0;
        _routeTaskParams.outputGeometryPrecisionUnits = AGSUnitsMeters;
        
        _routeTaskParams.returnRouteGraphics = YES;
        
        _routeTaskParams.returnDirections = YES;
        
        // the next 3 lines will cause the task to find the
        // best route regardless of the stop input order
        _routeTaskParams.findBestSequence = YES;
        _routeTaskParams.preserveFirstStop = YES;
        _routeTaskParams.preserveLastStop = YES;
        
        // since we used "findBestSequence" we need to
        // get the newly reordered stops
        _routeTaskParams.returnStopGraphics = YES;
        
        // ensure the graphics are returned in our map's spatial reference
        _routeTaskParams.outSpatialReference = [[AGSSpatialReference alloc] initWithWKID:4490];
        
        // let's ignore invalid locations
        _routeTaskParams.ignoreInvalidLocations = YES;
        
    }
    
    return _routeTaskParams;
}




/**
 *  @author crash         crash_wu@163.com   , 16-09-22 17:09:46
 *
 *  @brief  驾车路线规划
 *
 *  @param points  路线经过点
 *  @param url     驾车路线规划请求服务(ArcGIS 服务)
 *  @param success 请求成功
 *  @param fail    请求失败
 */
-(void)changShaRouteSearch:(NSArray<AGSPoint *> *_Nonnull)points andURL:(NSString *_Nullable)url success:(nullable void(^)(AGSRouteResult *_Nullable resut))success fail:(nullable void(^) (NSError *_Nullable error) )fail{
    
    self.url = url;
    
    [self.stops removeAllObjects];
    
    NSInteger numStops = 0;
    for (AGSPoint *point in points) {
        
        numStops ++;
        AGSStopGraphic *stopGraphic = [ AGSStopGraphic graphicWithGeometry:point symbol:nil attributes:nil];
        //stopGraphic.sequence = numStops;
        
        [self.stops addObject:stopGraphic];
    }
    
    
    // set the stop and polygon barriers on the parameters object
    if (self.stops.count > 0) {
        [self.routeTaskParams setStopsWithFeatures:self.stops];
    }
    
    // execute the route task
    [self.routeTask solveWithParameters:self.routeTaskParams];
    
    self.success = success;
    self.fail = fail;

}

#pragma mark AGSRouteTaskDelegate

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didRetrieveDefaultRouteTaskParameters:(AGSRouteTaskParameters *)routeParams {
    self.routeTaskParams = routeParams;
}

- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailToRetrieveDefaultRouteTaskParametersWithError:(NSError *)error {
    
    self.fail(error);
}


//
// route was solved
//
- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didSolveWithResult:(AGSRouteTaskResult *)routeTaskResult {
    
    self.routeResult = [routeTaskResult.routeResults lastObject];
    if (self.routeResult) {
        self.success(self.routeResult);

        
    }else{
        self.fail(nil);
    }

}


- (void)routeTask:(AGSRouteTask *)routeTask operation:(NSOperation *)op didFailSolveWithError:(NSError *)error {
    self.fail(error);
}



@end
