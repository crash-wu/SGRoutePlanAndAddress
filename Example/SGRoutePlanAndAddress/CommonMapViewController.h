//
//  CommonMapViewController.h
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//


#import <ArcGIS/ArcGIS.h>
#import <SGTileLayer/SGTileLayerHeader.h>



/**
 *  @author crash         crash_wu@163.com   , 16-09-23 10:09:44
 *
 *  @brief  公用地图页面
 */
@interface CommonMapViewController : UIViewController

@property(nonatomic,strong,nullable) AGSMapView *mapView;

@end
