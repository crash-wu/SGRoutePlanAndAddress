//
//  CarRouteDetailSegmentViewController.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/26.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CommonMapViewController.h"
#import <ArcGIS/ArcGIS.h>
#import <SGRoutePlanAndAddress/SGRoutePlanAndAddress.h>
#import <Masonry/Masonry.h>


/**
 *  @author crash         crash_wu@163.com   , 16-09-26 10:09:32
 *
 *  @brief  驾车路线分段显示
 */
@interface CarRouteDetailSegmentViewController : CommonMapViewController


/**
 *  @author crash         crash_wu@163.com   , 16-09-26 11:09:47
 *
 *  @brief  页面初始化函数
 *
 *  @param directions 驾车路线分段数组
 *
 *  @param row 展示路线段下标
 *
 *  @param startAddress 起点地址
 *
 *  @param stopAddress 终点地址
 *
 *  @return
 */

-(nonnull instancetype)initWithCarRoute:(AGSRouteResult *_Nullable) carRoute andShowRow:(NSInteger )row andStarAddress:(NSString *_Nullable) starAddress andStopAddress:(NSString *_Nullable) stopAddress;

@end
