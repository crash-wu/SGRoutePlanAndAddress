/*!
 @header SGSRequestDelegate.h
 
 @abstract 网络请求代理协议
 
 @author Created by Lee on 16/8/15.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SGSBaseRequest;

/*!
 *  @protocol SGSRequestDelegate
 *
 *  @abstract 请求代理协议
 */
@protocol SGSRequestDelegate <NSObject>

@optional

/*!
 *  @abstract 请求成功
 *
 *  @param request HTTP请求
 */
- (void)requestSuccess:(__kindof SGSBaseRequest *)request;

/*!
 *  @abstract 请求失败
 *
 *  @param request HTTP请求
 */
- (void)requestFailed:(__kindof SGSBaseRequest *)request;

/*!
 *  @abstract 请求进度（包括上传和下载）
 *
 *  @param request  HTTP请求
 *  @param progress 进度闭包
 */
- (void)request:(__kindof SGSBaseRequest *)request progress:(NSProgress *)progress;

/*!
 *  @abstract 请求即将开始
 *
 *  @param request HTTP请求
 */
- (void)requestWillStart:(__kindof SGSBaseRequest *)request;

/*!
 *  @abstract 请求即将暂停
 *
 *  @param request HTTP请求
 */
- (void)requestWillSuspend:(__kindof SGSBaseRequest *)request;

/*!
 *  @abstract 请求已经暂停
 *
 *  @param request HTTP请求
 */
- (void)requestDidSuspend:(__kindof SGSBaseRequest *)request;

/*!
 *  @abstract 请求即将停止，包括请求完毕
 *
 *  @param request HTTP请求
 */
- (void)requestWillStop:(__kindof SGSBaseRequest *)request;

/*!
 *  @abstract 请求已经停止，包括请求完毕
 *
 *  @param request HTTP请求
 */
- (void)requestDidStop:(__kindof SGSBaseRequest *)request;

@end

NS_ASSUME_NONNULL_END
