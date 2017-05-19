//
//  GDRouteAnalysisManager.m
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import "GDRouteAnalysisManager.h"

@implementation GDRouteAnalysisManager


/**
 单例
 */
+(nonnull instancetype) sharedManager{
    
    static GDRouteAnalysisManager *shared = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc]init];
    });
    
    return shared;
    
}


/**
 高德路线规划数据解析

 @param pathListModel 高德路线规划
 @return 路线数据
 */
-(AGSMutablePolyline *_Nonnull)analysisGDRoute:(GDPathListModel *_Nonnull) pathListModel {
    
    AGSMutablePolyline *polyline = [[AGSMutablePolyline alloc]init];
    [polyline addPathToPolyline];
    
    //遍历高德路线数据，解析出路线规划途径坐标点
    for (GDPathModel * pathModel in pathListModel.path) {
        
        for (GDSegmentModel *segmentModel in pathModel.segments ) {
            
         NSString *coor = segmentModel.coor;

         //去掉[字符
          coor =  [coor stringByReplacingOccurrencesOfString:@"["withString:@""];
            
        //去掉]字符
          coor = [coor stringByReplacingOccurrencesOfString:@"]" withString:@""];
            
          NSArray *latLot = [coor componentsSeparatedByString:@","];

            
            if (latLot.count  && (latLot.count % 2 == 0)) {
                
                for(int i = 0 ; i < latLot.count ; i = i +2){

                    AGSPoint *point = [[AGSPoint alloc]initWithX:[latLot[i] floatValue] y:[latLot[i+1] floatValue]spatialReference:[[AGSSpatialReference alloc]initWithWKID:4490]];
                    [polyline addPointToPath:point];
                }
            }
            
        }
    }
    
    return polyline;
}

@end
