# SGRoutePlanAndAddress

[![CI Status](http://img.shields.io/travis/吴小星/SGRoutePlanAndAddress.svg?style=flat)](https://travis-ci.org/吴小星/SGRoutePlanAndAddress)
[![Version](https://img.shields.io/cocoapods/v/SGRoutePlanAndAddress.svg?style=flat)](http://cocoapods.org/pods/SGRoutePlanAndAddress)
[![License](https://img.shields.io/cocoapods/l/SGRoutePlanAndAddress.svg?style=flat)](http://cocoapods.org/pods/SGRoutePlanAndAddress)
[![Platform](https://img.shields.io/cocoapods/p/SGRoutePlanAndAddress.svg?style=flat)](http://cocoapods.org/pods/SGRoutePlanAndAddress)

## Describe
数码地名地址搜索，周边搜索，公交站点搜索，公交路线搜索，公交站点坐标搜索，公交路线坐标搜索，驾车路线搜索等功能

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

```
 #import<SGRoutePlanAndAddress/SGRoutePlanAndAddress.h>
```
### 地名地址查询类 SGAddressServiceHandler.h
搜索地名地址数据


```
/**
 *  @author crash         crash_wu@163.com   , 16-09-28 15:09:49
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 15:09:32
 *
 *  @brief  地名地址查询
 *
 *  @param searchModel 查询实体
 *  @param url         请求服务URL
 *  @param success     搜索成功block
 *  @param fail        搜索失败block
 */
-(void)changShaAddressService:(SGAddressSearchModel *_Nullable)searchModel
   andUrl:(NSString *_Nullable)url
  success:(nonnull void(^)(NSArray<SGAddressModel *> *_Nullable models))success
     fail:(nonnull void (^)(NSError *_Nullable error))fail;

```

### 公交路线查询类 SGBusLineServiceHandler
搜索公交路线信息

```
/**
 *  @author crash         crash_wu@163.com   , 16-09-27 15:09:55
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype)sharedInstance;

/**
 *  @author crash         crash_wu@163.com   , 16-09-28 09:09:57
 *
 *  @brief  公交路线搜索
 *
 *  @param start   起点地址
 *  @param end     终点地址
 *  @param url     公交路线搜索URL
 *  @param success 搜索成功block
 *  @param fail    搜索失败block
 */
-(void)busLineService:(NSString *_Nullable) start
               andEnd:(NSString *_Nullable) end
               andURL:(NSString *_Nullable)url
              success:(nonnull void(^)(NSArray<BusTravelsModel *> *_Nullable busLines))success
                 fail:(nonnull void(^)(NSError *_Nullable error))fail;


```

### 公交站点查询类 SGBusStopServiceHandler

查询公交站点数据

```
/**
 *  @author crash         crash_wu@163.com   , 16-09-27 15:09:55
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype)sharedInstance;

/**
 *  @author crash         crash_wu@163.com   , 16-09-27 15:09:21
 *
 *  @brief  查询公交站点名称
 *
 *  @param stopName 公交站点名称
 *  @param url      公交站点查询URL
 *  @param success  查询成功block
 *  @param fail     查询失败block
 */
-(void)busStopService:(NSString *_Nullable)stopName
               andURL:(NSString *_Nullable)url
              success:(nonnull void (^)(NSArray<NSString *> *_Nullable stopNames))success
                 fail:(nonnull void(^)(NSError *_Nullable error))fail;

```

### 公交路线服务查询类（查询该条路线的几何图形） SGGetBusLinePolylineHandler
查询该条路线的几何图形数据(AGSGraphic)，该查询类由 AGSQueryTask 类发起查询，查询的URL为 ArcGIS 服务

```

/**
 *  @author crash         crash_wu@163.com   , 16-09-06 15:09:48
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance;

/**
 *  @author crash         crash_wu@163.com   , 16-10-11 10:10:56
 *
 *  @brief  获取公交路线线路坐标
 *
 *  @param starStop     起点站点
 *  @param endStop      终点站点
 *  @param travelsModel 公交路线实体
 *  @param url          服务地址（ArcGIS 服务）
 *  @param success      成功block
 *  @param failed       失败block
 */
-(void)busStopLine:(NSString *_Nonnull)starStop
        andEndStop:(NSString *_Nonnull)endStop
       andBusTravles:(BusTravelsModel *_Nullable)travelsModel
       andURL:(NSString *_Nullable)url
       succes:
            (nonnull void (^)( NSArray<AGSGraphic *> *_Nullable graphics))success
       failed:
           (nonnull void(^)(NSError *_Nullable error))failed;

```

### 公交站点服务查询类(查询该条公交路线经过站点的位置坐标) SGGetBusStopLocationHandler
查询该条公交路线经过站点位置坐标，该查询类由 AGSQueryTask 类发起查询，查询的URL为 ArcGIS 服务

```
/**
 *  @author crash         crash_wu@163.com   , 16-09-06 15:09:48
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance;


/**
 *  @author crash         crash_wu@163.com   , 16-10-11 10:10:56
 *
 *  @brief  获取公交路线途径站点经纬度
 *
 *  @param starStop     起点站点
 *  @param endStop      终点站点
 *  @param travelsModel 公交路线实体
 *  @param url          获取公交路线途径站点经纬度服务URL(ArcGIS 服务)
 *  @param success      成功block
 *  @param failed       失败block
 */
-(void)busStopLocation:(NSString *_Nonnull)starStop
            andEndStop:(NSString *_Nonnull)endStop
            andBusTravles:(BusTravelsModel *_Nullable)
            travelsModel andURL:(NSString *_Nullable)url
            succes:
            (nonnull void (^)( NSArray<AGSGraphic *> *_Nullable graphics))success
            failed:
            (nonnull void(^)(NSError *_Nullable error))failed;

```

### 驾车路线规划查询类 SGRouteServiceHandler
查询驾车路线数据，提供一条合适的驾车路线，该查询类由 AGSRouteTask 类发起查询，查询的URL为 ArcGIS 服务

```
/**
 *  @author crash         crash_wu@163.com   , 16-09-22 16:09:47
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype)sharedInstance;




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
-(void)changShaRouteSearch:(NSArray<AGSPoint *> *_Nonnull)points
                    andURL:(NSString *_Nullable)url
                    success:(nullable void(^)(AGSRouteResult *_Nullable resut))success
                    fail:(nullable void(^) (NSError *_Nullable error) )fail;
```

### 周边地名地址查询类 SGSurroundAddressServiceHandler
查询某一个位置 周边地名地址数据，类同地名地址查询类 SGAddressServiceHandler

```
/**
 *  @author crash         crash_wu@163.com   , 16-09-28 15:09:32
 *
 *  @brief  地名地址查询
 *
 *  @param searchModel 周边查询实体
 *  @param url         请求URL
 *  @param success     搜索成功block
 *  @param fail        搜索失败block
 */
-(void)changShaSurroundAddressService:(SGSurroundAddressSearchModel *_Nullable)searchModel
   andURL:(NSString *_Nullable) url
  success:(nonnull void(^)(NSArray<SGAddressModel *> *_Nullable models))success
  fail:(nonnull void (^)(NSError *_Nullable error))fail;


/**
 *  @author crash         crash_wu@163.com   , 16-09-28 15:09:49
 *
 *  @brief  单例
 *
 *  @return
 */
+(nonnull instancetype) sharedInstance;
```

###SGAddressModel
地名地址查询结果／周边查询结果实体类

###SGAddressSearchModel
地名地址查询请求实体类

###  SGSurroundAddressSearchModel
地名地址周边查询请求实体类

### BusLineMessageModel
公交路线实体

### BusTravelsModel
公交路线方案信息实体（某一条公交路线方案，如： 503->502）

### BusLinesModel
公交线路信息详情实体(如：502公交详情)

## Requirements
ArcGIS-Runtime-SDK-iOS for version 10.2.5
## Installation

SGRoutePlanAndAddress is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SGRoutePlanAndAddress"
```

##Example
![](http://images.cnblogs.com/cnblogs_com/crash-wu/895993/o_bus.gif)


![](http://images.cnblogs.com/cnblogs_com/crash-wu/895993/o_car.gif)

## Author

吴小星, crash_wu@163.com

## License

SGRoutePlanAndAddress is available under the MIT license. See the LICENSE file for more info.
