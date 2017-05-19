/*!
 @header SGSHTTPModule.h
 
 @abstract 网络请求
 
 @author Created by Lee on 16/8/16.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#ifndef SGSHTTPModule_h
#define SGSHTTPModule_h

#if defined(__has_include) && __has_include(<SGSHTTPModule/SGSHTTPModule.h>)
#import <SGSHTTPModule/SGSHTTPConfig.h>
#import <SGSHTTPModule/SGSBaseRequest.h>
#import <SGSHTTPModule/SGSBatchRequest.h>
#import <SGSHTTPModule/SGSChainRequest.h>
#import <SGSHTTPModule/SGSRequestDelegate.h>
#import <SGSHTTPModule/SGSResponseSerializable.h>
#import <SGSHTTPModule/SGSBaseRequest+Convenient.h>
#import <SGSHTTPModule/AFURLSessionManager+SGS.h>
#else
#import "SGSHTTPConfig.h"
#import "SGSBaseRequest.h"
#import "SGSBatchRequest.h"
#import "SGSChainRequest.h"
#import "SGSRequestDelegate.h"
#import "SGSResponseSerializable.h"
#import "SGSBaseRequest+Convenient.h"
#import "AFURLSessionManager+SGS.h"
#endif

#endif /* SGSHTTPModule_h */
