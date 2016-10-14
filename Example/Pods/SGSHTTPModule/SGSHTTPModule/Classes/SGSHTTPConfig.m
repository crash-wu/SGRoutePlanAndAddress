/*!
 @header SGSHTTPConfig.m
 
 @abstract 网络请求配置
 
 @author Created by Lee on 16/8/12.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 
 */


#import "SGSHTTPConfig.h"

static NSString * const kDownloadDataFolderName = @"com.southgis.iMobile.HTTPModule.downloads";

@implementation SGSHTTPConfig

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _baseURL = @"";
        
        NSString *cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _defaultDownloadsDirectory = [cachesDir stringByAppendingPathComponent:kDownloadDataFolderName];
    }
    return self;
}

@end
