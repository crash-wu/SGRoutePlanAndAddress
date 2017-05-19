//
//  GDRouteHandler.h
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SGSHTTPModule/SGSHTTPModule.h>
#import <ArcGIS/ArcGIS.h>
#import "GDRouteAnalysisManager.h"

/**
 
 */
@interface GDRouteHandler : SGSBaseRequest


/**
 单例
 */
+(nonnull instancetype )sharedManager;

/**
 高德地图路线规划
 
 @param from 起点
 @param to 终点
 @param success 搜索成功
 @param fail 搜索失败
 */
-(void)gdRoute:(AGSPoint *_Nonnull)from andTo:(AGSPoint *_Nonnull)to andSuccess:(nonnull void(^) (AGSMutablePolyline *_Nonnull polyline)  ) success andFail:(nonnull void(^) (NSError *_Nullable error)) fail;

@end
