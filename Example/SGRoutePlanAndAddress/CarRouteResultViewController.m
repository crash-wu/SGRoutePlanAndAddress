//
//  CarRouteResultViewController.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CarRouteResultViewController.h"

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 09:09:05
 *
 *  @brief  路线图层
 */
static NSString *ROUTELINELAYER = @"routeLineLayer";

@interface CarRouteResultViewController ()


/**
 *  @author crash         crash_wu@163.com   , 16-09-22 15:09:14
 *
 *  @brief  路线规划结果
 */
@property(nonatomic,strong,nullable)  AGSRouteResult *routeResult;

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 09:09:40
 *
 *  @brief  路线图层
 */
@property(nonatomic,strong,nullable) AGSGraphicsLayer *graphicsLayer;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 09:09:31
 *
 *  @brief  起点地址
 */
@property(nonatomic,strong,nullable) NSString *startAddress;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 09:09:40
 *
 *  @brief  终点地址
 */
@property(nonatomic,strong,nullable) NSString *stopAddress;

@end

@implementation CarRouteResultViewController


/**
*  @author crash         crash_wu@163.com   , 16-09-23 15:09:49
*
*  @brief  驾车搜索结果页面
*
*  @param routeResult  驾车搜索结果
*  @param startAddress 起点地址
*  @param stopAddress  终点地址
*
*  @return 
*/
-(nonnull instancetype) initWithRouteResult:(AGSRouteResult *_Nullable)routeResult andStartAddress:(NSString *_Nullable) startAddress andStopAddress:(NSString *_Nullable)stopAddress{
    if (self = [super init]) {
        
        self.routeResult = routeResult;
        self.routeResult.routeGraphic.symbol = [self routeSymbol];
        
        self.routeMessageView = [[CarRouteMessageView alloc]initWithFrame:CGRectZero];
        [self.view addSubview:self.routeMessageView];
    
        [self.routeMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.view.mas_left).offset(10);
            make.right.equalTo(self.view.mas_right).offset(-10);
            make.bottom.equalTo(self.view.mas_bottom);
            make.height.equalTo(@(70));
        }];
        

        self.routeMessageView.addressLb.text = [NSString stringWithFormat:@"%@ -> %@",startAddress,stopAddress];
        self.routeMessageView.distancLb.text = [NSString stringWithFormat:@"%lf 公里",routeResult.directions.totalLength / 1000];
        
        self.startAddress = startAddress;
        self.stopAddress = stopAddress;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showRouteDetail:)];
        [self.routeMessageView addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"驾车路线"];

}

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 16:09:47
 *
 *  @brief  查看详情
 *
 *  @param recognizer
 */
-(void)showRouteDetail:(UITapGestureRecognizer *)recognizer{
    
    [self.navigationController pushViewController:[[CarRouteResultDetailViewController alloc] initWithRouteResult:self.routeResult andStartAddress:self.startAddress andStopAddress:self.stopAddress] animated:true];
}

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 09:09:04
 *
 *  @brief  路线图层懒加载
 *
 *  @return 返回路线图层
 */
-(AGSGraphicsLayer *)graphicsLayer{
    if (_graphicsLayer == nil) {
        
        _graphicsLayer = [[AGSGraphicsLayer alloc]init];

    }
    
    return _graphicsLayer;
}

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 09:09:53
 *
 *  @brief  路线样式
 *
 *  @return
 */
- (AGSCompositeSymbol*)routeSymbol {
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
    AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls1.color = [UIColor yellowColor];
    sls1.style = AGSSimpleLineSymbolStyleSolid;
    sls1.width = 8;
    [cs addSymbol:sls1];
    
    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls2.color = [UIColor blueColor];
    sls2.style = AGSSimpleLineSymbolStyleSolid;
    sls2.width = 4;
    [cs addSymbol:sls2];
    
    return cs;
}

/**
 *  @author crash         crash_wu@163.com   , 16-09-23 11:09:45
 *
 *  @brief  驾车路线规划经过点样式
 *
 *  @return
 */
- (AGSCompositeSymbol*)stopSymbolWithNumber{
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
    // create outline
    AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbol];
    sls.color = [UIColor blackColor];
    sls.width = 2;
    sls.style = AGSSimpleLineSymbolStyleSolid;
    
    // create main circle
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms.color = [UIColor greenColor];
    sms.outline = sls;
    sms.size = CGSizeMake(20, 20);
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    [cs addSymbol:sms];
 
    
    return cs;
}


/**
 *  @author crash         crash_wu@163.com   , 16-09-23 10:09:52
 *
 *  @brief  驾车路线起点/终点地址样式
 *
 *  @param imageName 图标名称
 *
 *  @return 驾车路线起点/终点地址样式
 */
-(AGSCompositeSymbol *)startOrStopSymbol:(NSString *)imageName {
    
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
    AGSPictureMarkerSymbol *picture = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:imageName];
    

    [cs addSymbol:picture];
    
    return cs;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.graphicsLayer addGraphic:self.routeResult.routeGraphic];
    [self.mapView zoomToEnvelope:self.routeResult.routeGraphic.geometry.envelope animated:true];
    NSInteger stopsNumber = 0;
    for (AGSStopGraphic *sg in self.routeResult.stopGraphics) {
        
        if (stopsNumber == 0) {
            //起点
            sg.symbol =[self startOrStopSymbol:@"start_popo"];
        }else if (stopsNumber == self.routeResult.stopGraphics.count -1){
            //终点
            
            sg.symbol = [self startOrStopSymbol:@"end_popo"];
        }else{
            sg.symbol = [self stopSymbolWithNumber];
        }
        
        
        [self.graphicsLayer addGraphic:sg];
        stopsNumber ++;
    }
    
    [self.mapView addMapLayer:self.graphicsLayer withName:ROUTELINELAYER];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
}

@end
