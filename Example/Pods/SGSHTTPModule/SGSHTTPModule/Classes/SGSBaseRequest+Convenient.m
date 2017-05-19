/*!
 @header SGSBaseRequest+Convenient.h
  
 @author Created by Lee on 16/12/12.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import "SGSBaseRequest+Convenient.h"
#import "SGSResponseSerializable.h"

@implementation SGSBaseRequest (Convenient)

+ (instancetype)GET:(NSString *)URLString
            success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
            failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    return [self requestWithURL:URLString httpMethod:SGSRequestMethodGet parameters:nil progress:nil responseFilter:nil forClass:nil success:success failure:failure];
}


+ (instancetype)GET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
            success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
            failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    return [self requestWithURL:URLString httpMethod:SGSRequestMethodGet parameters:parameters progress:nil responseFilter:nil forClass:nil success:success failure:failure];
}


+ (instancetype)GET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
     responseFilter:(void (^)(__kindof SGSBaseRequest * _Nonnull))filter
            success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
            failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    return [self requestWithURL:URLString httpMethod:SGSRequestMethodGet parameters:parameters progress:nil responseFilter:filter forClass:nil success:success failure:failure];
}


+ (instancetype)GET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
           forClass:(Class<SGSResponseSerializable>)cls
            success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
            failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    return [self requestWithURL:URLString httpMethod:SGSRequestMethodGet parameters:parameters progress:nil responseFilter:nil forClass:cls success:success failure:failure];
}


+ (instancetype)GET:(NSString *)URLString
         parameters:(NSDictionary *)parameters
           progress:(void (^)(__kindof SGSBaseRequest * _Nonnull, NSProgress * _Nonnull))progress
     responseFilter:(void (^)(__kindof SGSBaseRequest * _Nonnull))filter
           forClass:(Class<SGSResponseSerializable>)cls
            success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
            failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    return [self requestWithURL:URLString httpMethod:SGSRequestMethodGet parameters:parameters progress:progress responseFilter:filter forClass:cls success:success failure:failure];
}


+ (instancetype)POST:(NSString *)URLString
          parameters:(NSDictionary *)parameters
             success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
             failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    return [self requestWithURL:URLString httpMethod:SGSRequestMethodPost parameters:parameters progress:nil responseFilter:nil forClass:nil success:success failure:failure];
}


+ (instancetype)POST:(NSString *)URLString
          parameters:(NSDictionary *)parameters
      responseFilter:(void (^)(__kindof SGSBaseRequest * _Nonnull))filter
             success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
             failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    return [self requestWithURL:URLString httpMethod:SGSRequestMethodPost parameters:parameters progress:nil responseFilter:filter forClass:nil success:success failure:failure];
}


+ (instancetype)POST:(NSString *)URLString
          parameters:(NSDictionary *)parameters
            forClass:(Class<SGSResponseSerializable>)cls
             success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
             failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    return [self requestWithURL:URLString httpMethod:SGSRequestMethodPost parameters:parameters progress:nil responseFilter:nil forClass:cls success:success failure:failure];
}


+ (instancetype)POST:(NSString *)URLString
          parameters:(NSDictionary *)parameters
            progress:(void (^)(__kindof SGSBaseRequest * _Nonnull, NSProgress * _Nonnull))progress
      responseFilter:(void (^)(__kindof SGSBaseRequest * _Nonnull))filter
            forClass:(Class<SGSResponseSerializable>)cls
             success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
             failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    return [self requestWithURL:URLString httpMethod:SGSRequestMethodPost parameters:parameters progress:progress responseFilter:filter forClass:cls success:success failure:failure];
}


+ (instancetype)requestWithURL:(NSString *)URLString
                    httpMethod:(SGSRequestMethod)method
                    parameters:(NSDictionary *)parameters
                      progress:(void (^)(__kindof SGSBaseRequest * _Nonnull, NSProgress * _Nonnull))progress
                responseFilter:(void (^)(__kindof SGSBaseRequest * _Nonnull))filter
                      forClass:(Class<SGSResponseSerializable>)cls
                       success:(void (^)(__kindof SGSBaseRequest * _Nonnull))success
                       failure:(void (^)(__kindof SGSBaseRequest * _Nonnull))failure
{
    SGSBaseRequest *result = [[[self class] alloc] initWithURLString:URLString parameters:parameters];
    result.requestMethod = method;
    result.progressBlock = progress;
    result.requestWillStopBlock = filter;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    if ([cls conformsToProtocol:@protocol(SGSResponseObjectSerializable)]) {
        result.responseObjectClass = (Class<SGSResponseObjectSerializable>)cls;
    }

    if ([cls conformsToProtocol:@protocol(SGSResponseCollectionSerializable)]) {
        result.responseObjectArrayClass = (Class<SGSResponseCollectionSerializable>)cls;
    }
#pragma clang diagnostic pop
    
    [result startWithCompletionSuccess:success failure:failure];
    
    return result;
}

@end
