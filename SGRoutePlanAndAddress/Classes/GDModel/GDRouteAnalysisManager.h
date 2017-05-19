//
//  GDRouteAnalysisManager.h
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDPathListModel.h"
#import <ArcGIS/ArcGIS.h>


/**
 高德地图路线规划结果分析
 */
@interface GDRouteAnalysisManager : NSObject

/**
 高德路线规划数据解析
 
 @param pathListModel 高德路线规划
 @return 路线数据
 */
-(AGSMutablePolyline *_Nonnull)analysisGDRoute:(GDPathListModel *_Nonnull) pathListModel;


/**
 单例
 */
+(nonnull instancetype) sharedManager;

@end
