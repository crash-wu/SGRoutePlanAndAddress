//
//  BusLineShowInMapViewController.m
//  ChangSha
//
//  Created by 吴小星 on 16/10/10.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "BusLineShowInMapViewController.h"

@interface BusLineShowInMapViewController ()<UIScrollViewDelegate>

@property(nonatomic,strong,nullable) SGGetBusLinePolylineHandler *busLineHandler;

@property(nonatomic,strong,nullable) SGGetBusStopLocationHandler *busStopHandler;

/**
 *  @author crash         crash_wu@163.com   , 16-10-11 17:10:01
 *
 *  @brief  公交站点图层
 */
@property(nonatomic,strong,nullable)     AGSGraphicsLayer *busStopLayer;

/**
 *  @author crash         crash_wu@163.com   , 16-10-11 17:10:26
 *
 *  @brief  公交线路图层
 */
@property(nonatomic,strong,nullable) AGSGraphicsLayer *busLineLayer;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 11:09:27
 *
 *  @brief  滚动视图
 */
@property(nonatomic,strong,nullable) UIScrollView *scrollView;

/**
 *  @author crash         crash_wu@163.com   , 16-10-10 18:10:04
 *
 *  @brief  公交路线数组
 */
@property(nonatomic,strong,nullable) NSArray<BusTravelsModel *> *buslines;

/**
 *  @author crash         crash_wu@163.com   , 16-10-10 18:10:34
 *
 *  @brief  公交路线起点
 */
@property(nonatomic,strong,nullable) NSString *starStop;

/**
 *  @author crash         crash_wu@163.com   , 16-10-10 18:10:00
 *
 *  @brief  公交路线终点
 */
@property(nonatomic,strong,nullable) NSString *endStop;


/**
 *  @author crash         crash_wu@163.com   , 16-09-26 14:09:08
 *
 *  @brief 公交路线下标
 */
@property(nonatomic,assign) NSInteger row;

@end

@implementation BusLineShowInMapViewController

/**
 *  @author crash         crash_wu@163.com   , 16-10-11 08:10:36
 *
 *  @brief  初始化函数
 *
 *  @param busLines 公交路线数组
 *  @param starStop 公交起点站点
 *  @param endStop  公交终点站点
 *  @param row      公交路线下标
 *
 *  @return
 */
-(nonnull instancetype)initWithBusLineModes:(NSArray<BusTravelsModel *> *_Nullable) busLines andStarStop:(NSString *_Nullable)starStop andEndStop:(NSString *_Nullable)endStop andRow:(NSInteger)row{
    if (self = [super init]) {
        
        self.buslines = busLines;
        self.starStop = starStop;
        self.endStop = endStop;
        self.row = row;

        self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        self.scrollView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.scrollView];
        self.scrollView.delegate = self;
        self.scrollView.pagingEnabled = true;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.view.mas_left).offset(10);
            make.right.equalTo(self.view.mas_right).offset(-10);
            make.bottom.equalTo(self.view.mas_bottom);
            make.height.equalTo(@(70));
        }];
        

        
        [self searchBusLineAndStop:starStop andEndStop:endStop andTravles:busLines[row]];
        
        self.scrollView.contentSize = CGSizeMake(self.buslines.count*self.scrollView.frame.size.width, 0);
        
        BusTravelsContentView *fristLb = nil;
        
        NSInteger tag = 0;
        
        for (BusTravelsModel * busLineMode in self.buslines) {
            
            BusTravelsContentView *busTravelsView = [[BusTravelsContentView alloc]initWithFrame:CGRectZero];
            [self.scrollView addSubview:busTravelsView];
            [busTravelsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.scrollView.mas_top);
                make.height.equalTo(self.scrollView.mas_height);
                make.width.equalTo(self.scrollView.mas_width);
                if (fristLb ) {
                    make.left.equalTo(fristLb.mas_right);
                }else{
                    make.left.equalTo(self.scrollView.mas_left);
                }
            }];
            
            fristLb = busTravelsView;
            [self rendBusTravelsDate:busLineMode andTravelsView:busTravelsView];
            busTravelsView.tag = tag;
        }
        

        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setTitle:@"公交路线"];
        

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    CGPoint offSet = CGPointMake(self.scrollView.frame.size.width * self.row, 0);
    self.scrollView.contentOffset = offSet;
    
}


-(void)dealloc{
    
}

/**
 *  @author crash         crash_wu@163.com   , 16-10-11 11:10:52
 *
 *  @brief  搜索路线，站点
 *
 *  @param starStop    公交站点起点
 *  @param endStop     公交站点终点
 *  @param travelModel 公交路线
 */
-(void)searchBusLineAndStop:(NSString *_Nullable) starStop andEndStop:(NSString *_Nullable) endStop andTravles:(BusTravelsModel *_Nullable)travelModel{
    
    __weak typeof(&*self) weak = self;

    [SVProgressHUD showWithStatus:@"正在获取公交路线数据...."];
    
    if (!self.busLineHandler ) {
        
        self.busLineHandler = [[SGGetBusLinePolylineHandler alloc]init];

    }
    
    if (!self.busStopHandler ) {
        self.busStopHandler = [[SGGetBusStopLocationHandler alloc]init];
    }
    
    //获取公交路线线路
    NSString *lineUrl = @"http://59.37.169.186:6080/arcgis/rest/services/hsgongjiao/MapServer/1";
    NSString *stopUrl = @"http://59.37.169.186:6080/arcgis/rest/services/hsgongjiao/MapServer/0";
    
    [self.busLineHandler busStopLine:starStop andEndStop:endStop andBusTravles:travelModel andURL:lineUrl succes:^(NSArray<AGSGraphic *> * _Nullable graphics) {
        
        [weak showBusLineInMapView:graphics];
        
        [weak.busStopHandler busStopLocation:starStop andEndStop:endStop andBusTravles:travelModel andURL:stopUrl succes:^(NSArray<AGSGraphic *> * _Nullable graphics) {
            
            //获取公交站点位置
            [SVProgressHUD dismiss];
            [weak showBusStopInMapView:graphics];
            
        } failed:^(NSError * _Nullable error) {
                [SVProgressHUD showErrorWithStatus:@"获取公交路线数据失败!"];
        }];
        
    } failed:^(NSError * _Nullable error) {
        
        [SVProgressHUD showErrorWithStatus:@"获取公交路线数据失败!"];
    }];
//    [self.busLineHandler busStopLine:starStop andEndStop:endStop andBusTravles:travelModel succes:^(NSArray<AGSGraphic *> * _Nullable graphics) {
//        
//        [weak showBusLineInMapView:graphics];
//        
//        //获取公交站点位置
//        [weak.busStopHandler busStopLocation:self.starStop andEndStop:self.endStop andBusTravles:travelModel succes:^(NSArray<AGSGraphic *> * _Nullable graphics) {
//
//            [SVProgressHUD dismiss];
//            [weak showBusStopInMapView:graphics];
//            
//        } failed:^(NSError * _Nullable error) {
//
//            [SVProgressHUD showErrorWithStatus:@"获取公交路线数据失败!"];
//            
//        }];
//        
//        
//    } failed:^(NSError * _Nullable error) {
//
//        [SVProgressHUD showErrorWithStatus:@"获取公交路线数据失败!"];
//    }];
    
}



/**
 *  @author crash         crash_wu@163.com   , 16-10-10 18:10:35
 *
 *  @brief  公交路线信息页面数据渲染
 *
 *  @param travelsModel  公交路线信息实体
 *  @param busTravesView 需要渲染数据的公交路线信息页面
 */
-(void)rendBusTravelsDate:(BusTravelsModel *_Nullable)travelsModel andTravelsView:(BusTravelsContentView *_Nonnull) busTravesView{
    
    NSString *lineName = @"";
    for (BusLinesModel *lineModel in travelsModel.lines) {
        
        lineName = [NSString stringWithFormat:@"%@ -> %@",lineName,lineModel.lineName];
    }
    
    busTravesView.lineNameLb.text = [lineName substringFromIndex:3];
    
    if (travelsModel.lines.count == 1) {
        busTravesView.changNumLb.text = @"无需换乘";
        
    }else{
        busTravesView.changNumLb.text = [NSString stringWithFormat:@"换乘:%lu次",travelsModel.lines.count -1];
    }
    
    busTravesView.stopNameLb.text = [NSString stringWithFormat:@"经过站点:%ld 个",travelsModel.stopTotal];
}



#pragma mark -UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    if (page < 0 || page > self.buslines.count)
        return ;
    
    [self searchBusLineAndStop:self.starStop andEndStop:self.endStop andTravles:self.buslines[page]];

}



/**
 *  @author crash         crash_wu@163.com   , 16-10-11 10:10:10
 *
 *  @brief  在地图上显示公交站点
 *
 *  @param graphics 公交站台图层
 */
-(void)showBusStopInMapView:(NSArray<AGSGraphic *> *_Nullable)graphics{

    if (self.busStopLayer) {
        [self.busStopLayer removeAllGraphics];
        [self.busStopLayer refresh];
        [self.mapView removeMapLayer:self.busStopLayer];
    }else{
        
         self.busStopLayer = [[AGSGraphicsLayer alloc]init];
    }

    //途径站点图标
    AGSPictureMarkerSymbol *stopSymbol = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"icon_busroute_change_bus_marker"];
    
    //起点站点图标
    AGSPictureMarkerSymbol *starSymbol =[[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"start_popo"];
    
    //终点站点图标
    AGSPictureMarkerSymbol *endSymbol = [[AGSPictureMarkerSymbol alloc]initWithImageNamed:@"end_popo"];
    
    NSDictionary *attributes = @{@"type":@"BUSSTOP"};
    
    for (AGSGraphic *graphic in graphics) {

        NSString *ZDM = [graphic attributeForKey:@"ZDM"];
        if ([ZDM isEqualToString:self.starStop]) {
            graphic.symbol = starSymbol;
        }else if([ZDM isEqualToString:self.endStop]){
            graphic.symbol = endSymbol;
        }else{
            graphic.symbol = stopSymbol;
        }

        [graphic setAttributes:attributes];
        [self.busStopLayer addGraphic:graphic];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.busStopLayer refresh];
        [self.mapView addMapLayer:self.busStopLayer withName:@"busStopLayer"];

        
    });

}


/**
 *  @author crash         crash_wu@163.com   , 16-10-11 11:10:21
 *
 *  @brief  显示公交路线
 *
 *  @param graphic 公交路线图层
 */
-(void)showBusLineInMapView:(NSArray<AGSGraphic *> *_Nullable)graphics{
    
    if (self.busLineLayer) {
        [self.busLineLayer removeAllGraphics];
        [self.busLineLayer refresh];
        [self.mapView removeMapLayer:self.busLineLayer];

        
    }else{
        
        self.busLineLayer = [[AGSGraphicsLayer alloc]init];
    }
    

    
   AGSSimpleLineSymbol  *lineSymbol = [[AGSSimpleLineSymbol alloc]init];
    lineSymbol.color = [UIColor blueColor];
    lineSymbol.width = 3.0;
    

    for (AGSGraphic *graphic in graphics) {
        
        graphic.symbol = lineSymbol;
        [self.busLineLayer addGraphic:graphic];

    }

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.busLineLayer refresh];
        [self.mapView addMapLayer:self.busLineLayer withName:@"busLineLayer"];
        if (graphics.count > 0) {
            [self.mapView zoomToGeometry:graphics[0].geometry withPadding:0 animated:true];
        }
        
    });

}

@end
