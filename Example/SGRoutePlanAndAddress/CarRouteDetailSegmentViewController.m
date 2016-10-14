//
//  CarRouteDetailSegmentViewController.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/26.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CarRouteDetailSegmentViewController.h"

static NSString *CARROUTETOTALLAYER = @"carRouteTotalLayer";

static NSString *CURRENTLAYER = @"currentLayer";

@interface CarRouteDetailSegmentViewController ()<UIScrollViewDelegate>


/**
 *  @author crash         crash_wu@163.com   , 16-09-23 09:09:40
 *
 *  @brief  路线图层
 */
@property(nonatomic,strong,nullable) AGSGraphicsLayer *graphicsLayer;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 14:09:53
 *
 *  @brief 当前展示的路线线段图层
 */
@property(nonatomic,strong,nullable ) AGSDirectionGraphic *currentLayer;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 11:09:59
 *
 *  @brief  驾车路线
 */
@property(nonatomic,strong,nullable) AGSRouteResult *carRoute;


/**
 *  @author crash         crash_wu@163.com   , 16-09-26 11:09:27
 *
 *  @brief  滚动视图
 */
@property(nonatomic,strong,nullable) UIScrollView *scrollView;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 14:09:08
 *
 *  @brief 起始展示路线段
 */
@property(nonatomic,assign) NSInteger row;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 14:09:30
 *
 *  @brief  驾车路线线段数组
 */
@property(nonatomic,strong,nullable) NSArray<AGSDirectionGraphic *> *directions;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 18:09:23
 *
 *  @brief  起点地址
 */
@property(nonatomic,strong,nullable) NSString *startAddress;

/**
 *  @author crash         crash_wu@163.com   , 16-09-26 18:09:36
 *
 *  @brief  终点地址
 */
@property(nonatomic,strong,nullable) NSString *stopAddress;

@end

@implementation CarRouteDetailSegmentViewController

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

-(nonnull instancetype)initWithCarRoute:(AGSRouteResult *_Nullable) carRoute andShowRow:(NSInteger )row andStarAddress:(NSString *_Nullable) starAddress andStopAddress:(NSString *_Nullable) stopAddress{
    if (self = [super init]) {
        self.carRoute = carRoute;
        self.directions = carRoute.directions.graphics;
        

        
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
        

        
        self.row = row;
        
        self.startAddress = starAddress;
        self.stopAddress = stopAddress;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"驾车详情"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
 *  @author crash         crash_wu@163.com   , 16-09-26 14:09:40
 *
 *  @brief  当前展示的路线线段图层
 *
 *  @return
 */
-(AGSDirectionGraphic *)currentLayer{
    if (_currentLayer) {
        
        _currentLayer = [[AGSDirectionGraphic alloc]init];
    }
    
    return _currentLayer;
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
 *  @author crash         crash_wu@163.com   , 16-09-26 14:09:40
 *
 *  @brief  当前展示的路线线段样式
 *
 *  @return
 */
- (AGSCompositeSymbol*)currentDirectionSymbol {
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    
    AGSSimpleLineSymbol *sls1 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls1.color = [UIColor whiteColor];
    sls1.style = AGSSimpleLineSymbolStyleSolid;
    sls1.width = 8;
    [cs addSymbol:sls1];
    
    AGSSimpleLineSymbol *sls2 = [AGSSimpleLineSymbol simpleLineSymbol];
    sls2.color = [UIColor redColor];
    sls2.style = AGSSimpleLineSymbolStyleDash;
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



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.graphicsLayer addGraphic:self.carRoute.routeGraphic];
    [self.mapView zoomToEnvelope:self.carRoute.routeGraphic.geometry.envelope animated:true];
    NSInteger stopsNumber = 0;
    for (AGSStopGraphic *sg in self.carRoute.stopGraphics) {
        
        if (stopsNumber == 0) {
            //起点
            sg.symbol =[self startOrStopSymbol:@"start_popo"];
        }else if (stopsNumber == self.carRoute.stopGraphics.count -1){
            //终点
            sg.symbol = [self startOrStopSymbol:@"end_popo"];
            
        }else{
            
            sg.symbol = [self stopSymbolWithNumber];
        }
        
        [self.graphicsLayer addGraphic:sg];
        stopsNumber ++;
    }
    
    [self.mapView addMapLayer:self.graphicsLayer withName:CARROUTETOTALLAYER];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.scrollView.contentSize = CGSizeMake(self.directions.count*self.scrollView.frame.size.width, 0);
    NSInteger numbers = 0;
    UILabel *fristLb = nil;
    
    for (AGSDirectionGraphic * graphic in self.directions) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.scrollView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.scrollView.mas_top);
            make.height.equalTo(self.scrollView.mas_height);
            make.width.equalTo(self.scrollView.mas_width);
            if (fristLb ) {
                make.left.equalTo(fristLb.mas_right);
            }else{
                make.left.equalTo(self.scrollView.mas_left);
            }
        }];
        
        fristLb = label;
        if (numbers == 0) {
            label.text = self.startAddress;
            
        }else if(numbers == self.directions.count - 1){
            label.text = self.stopAddress;
        }
        else{
            label.text = graphic.text;
        }

        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:13.f];
        label.textColor = [UIColor blackColor];
        numbers ++;
    }
    
    CGPoint offSet = CGPointMake(self.scrollView.frame.size.width * self.row, 0);
    self.scrollView.contentOffset = offSet;

    [self showCurrentSegmentLayer:self.directions[self.row]];
}


#pragma mark -UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int page = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    if (page < 0 || page > self.directions.count)
        return ;
    [self showCurrentSegmentLayer:self.directions[page]];
}


/**
 *  @author crash         crash_wu@163.com   , 16-09-26 14:09:51
 *
 *  @brief  展示当前线段图层样式
 *
 *  @param graphic
 */
-(void)showCurrentSegmentLayer:(AGSDirectionGraphic *)graphic{
    
    [self.graphicsLayer removeGraphic:self.currentLayer];
    graphic.symbol = [self currentDirectionSymbol];
    [self.graphicsLayer addGraphic:graphic];

    [self.graphicsLayer refresh];
    [self.mapView zoomToEnvelope:graphic.geometry.envelope animated:true];
    self.currentLayer = graphic;
}

@end
