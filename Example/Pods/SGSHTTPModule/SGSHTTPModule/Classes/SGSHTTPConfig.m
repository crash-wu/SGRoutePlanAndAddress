/*!
 @header SGSHTTPConfig.m
  
 @author Created by Lee on 16/8/12.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSHTTPConfig.h"
#import "AFURLSessionManager+SGS.h"

static NSString * const kDownloadDataFolderName = @"com.southgis.iMobile.HTTPModule.downloads";

static SGSHTTPConfig *sharedConfig;

@implementation SGSHTTPConfig

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfig = [[self alloc] init];
        
        sharedConfig.baseURL = @"";
        
        NSString *cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        sharedConfig.defaultDownloadsDirectory = [cachesDir stringByAppendingPathComponent:kDownloadDataFolderName];
    });
    return sharedConfig;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfig = [super allocWithZone:zone];
    });
    return sharedConfig;
}

- (void)setSecurityPolicy:(AFSecurityPolicy *)securityPolicy {
    [AFURLSessionManager defaultSessionManager].securityPolicy = securityPolicy;
}

- (AFSecurityPolicy *)securityPolicy {
    return [AFURLSessionManager defaultSessionManager].securityPolicy;
}

@end
