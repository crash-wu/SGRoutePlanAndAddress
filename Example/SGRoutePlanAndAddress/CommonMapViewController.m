//
//  CommonMapViewController.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CommonMapViewController.h"


@interface CommonMapViewController ()



@end

@implementation CommonMapViewController

-(instancetype)init{
    if (self= [super init]) {
        
        
        self.mapView = [[AGSMapView alloc]initWithFrame:self.view.frame];
        [self.view addSubview:self.mapView];

        [[SGTileLayerUtil sharedInstance] loadTdtTileLayer:WMTS_VECTOR_2000 andMapView:self.mapView];
        [self zoomToChangShaCGCS2000];
    }
    
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];


}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}




/**
 *  @author crash         crash_wu@163.com   , 16-10-13 18:10:06
 *
 *  @brief  将地图移动到长沙市
 */
-(void)zoomToChangShaCGCS2000{
    
    [self.mapView zoomToEnvelope:[[AGSEnvelope alloc] initWithXmin:112.34000000 ymin:27.73000000 xmax:114.25000000 ymax:28.81000000 spatialReference:self.mapView.spatialReference] animated:true];
}





@end
