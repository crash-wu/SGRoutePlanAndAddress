/*!
 @header AFHTTPSessionManager+SGS.m
  
 @author Created by Lee on 16/9/9.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 
 */

#import "AFHTTPSessionManager+SGS.h"

static NSString *const kResponseSerializeErrorDomain = @"com.southgis.iMobile.responseSerialize.error";

@implementation AFHTTPSessionManager (SGS)

+ (id (^)(id _Nullable))defaultResponseJSONFilter; {
    return ^id(id json) {
        // 不是指定格式
        if ((json == nil) || ![json isKindOfClass:[NSDictionary class]]) {
            return [NSError errorWithDomain:kResponseSerializeErrorDomain code:-8000 userInfo:@{NSLocalizedDescriptionKey: @"非法格式数据"}];
        }
        
        // 返回的状态码不合法
        NSInteger code = [[json objectForKey:@"code"] integerValue];
        
        if (code != 200) {
            NSString *desc = [json objectForKey:@"description"];
            return [NSError errorWithDomain:kResponseSerializeErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey: desc ?: @"系统错误"}];
        }
        
        // 获取结果
        return [json objectForKey:@"results"];
    };
}

/// GET
- (NSURLSessionDataTask *)GET:(NSString *)URLString
                   parameters:(id)parameters
                     progress:(void (^)(NSProgress * _Nonnull))downloadProgress
               responseFilter:(id (^)(id _Nullable))filter
                     forClass:(Class<SGSResponseSerializable>)cls
                      success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    return [self GET:URLString
          parameters:parameters
            progress:downloadProgress
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 
                 [self p_handleResponseObject:responseObject
                              taskOrReseponse:task
                               responseFilter:filter
                                     forClass:cls
                                      success:success
                                      failure:failure];
                 
             } failure:failure];
}

/// POST
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                      progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                      forClass:(Class<SGSResponseSerializable>)cls
                       success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                       failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    return [self POST:URLString
           parameters:parameters
             progress:uploadProgress
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  [self p_handleResponseObject:responseObject
                               taskOrReseponse:task
                                responseFilter:filter
                                      forClass:cls
                                       success:success
                                       failure:failure];
                  
              } failure:failure];
}

/// POST
- (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
     constructingBodyWithBlock:(void (^)(id<AFMultipartFormData> _Nonnull))block
                      progress:(void (^)(NSProgress * _Nonnull))uploadProgress
                responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                      forClass:(Class<SGSResponseSerializable>)cls
                       success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                       failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    return [self POST:URLString
           parameters:parameters
constructingBodyWithBlock:block progress:uploadProgress
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  
                  [self p_handleResponseObject:responseObject
                               taskOrReseponse:task
                                responseFilter:filter
                                      forClass:cls
                                       success:success
                                       failure:failure];
              } failure:failure];
}

/// PUT
- (NSURLSessionDataTask *)PUT:(NSString *)URLString
                   parameters:(id)parameters
               responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                     forClass:(Class<SGSResponseSerializable>)cls
                      success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                      failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    return [self PUT:URLString
          parameters:parameters
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 
                 [self p_handleResponseObject:responseObject
                              taskOrReseponse:task
                               responseFilter:filter
                                     forClass:cls
                                      success:success
                                      failure:failure];
                 
             } failure:failure];
}

/// PATCH
- (NSURLSessionDataTask *)PATCH:(NSString *)URLString
                     parameters:(id)parameters
                 responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                       forClass:(Class<SGSResponseSerializable>)cls
                        success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                        failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    return [self PATCH:URLString
            parameters:parameters
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                   
                   [self p_handleResponseObject:responseObject
                                taskOrReseponse:task
                                 responseFilter:filter
                                       forClass:cls
                                        success:success
                                        failure:failure];
                   
               } failure:failure];
}

/// DELETE
- (NSURLSessionDataTask *)DELETE:(NSString *)URLString
                      parameters:(id)parameters
                  responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                        forClass:(Class<SGSResponseSerializable>)cls
                         success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                         failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure
{
    return [self DELETE:URLString
             parameters:parameters
                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    [self p_handleResponseObject:responseObject
                                 taskOrReseponse:task
                                  responseFilter:filter
                                        forClass:cls
                                         success:success
                                         failure:failure];
                    
                } failure:failure];
}

/// data task
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                                     forClass:(Class<SGSResponseSerializable>)cls
                                      success:(void (^)(NSURLResponse * _Nonnull, id _Nullable))success
                                      failure:(void (^)(NSURLResponse * _Nonnull, NSError * _Nonnull))failure
{
    return [self dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (error != nil) {
            
            if (failure != nil) failure(response, error);
            
        } else {
            
            [self p_handleResponseObject:responseObject
                         taskOrReseponse:response
                          responseFilter:filter
                                forClass:cls
                                 success:success
                                 failure:failure];
        }
    }];
}

/// data task
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
                             downloadProgress:(void (^)(NSProgress * _Nonnull))downloadProgressBlock
                               responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                                     forClass:(Class<SGSResponseSerializable>)cls
                                      success:(void (^)(NSURLResponse * _Nonnull, id _Nullable))success
                                      failure:(void (^)(NSURLResponse * _Nonnull, NSError * _Nonnull))failure
{
    return [self dataTaskWithRequest:request
                      uploadProgress:uploadProgressBlock
                    downloadProgress:downloadProgressBlock
                   completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                       
                       if (error != nil) {
                           
                           if (failure != nil) failure(response, error);
                           
                       } else {
                           
                           [self p_handleResponseObject:responseObject
                                        taskOrReseponse:response
                                         responseFilter:filter
                                               forClass:cls
                                                success:success
                                                failure:failure];
                       }
                   }];
}

/// 上传文件
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromFile:(NSURL *)fileURL
                                         progress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
                                   responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                                         forClass:(Class<SGSResponseSerializable>)cls
                                          success:(void (^)(NSURLResponse * _Nonnull, id _Nullable))success
                                          failure:(void (^)(NSURLResponse * _Nonnull, NSError * _Nonnull))failure
{
    return [self uploadTaskWithRequest:request
                              fromFile:fileURL
                              progress:uploadProgressBlock
                     completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                         
                         if (error != nil) {
                             
                             if (failure != nil) failure(response, error);
                             
                         } else {
                             
                             [self p_handleResponseObject:responseObject
                                          taskOrReseponse:response
                                           responseFilter:filter
                                                 forClass:cls
                                                  success:success
                                                  failure:failure];
                         }
                     }];
}

/// 上传数据
- (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                         fromData:(NSData *)bodyData
                                         progress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
                                   responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                                         forClass:(Class<SGSResponseSerializable>)cls
                                          success:(void (^)(NSURLResponse * _Nonnull, id _Nullable))success
                                          failure:(void (^)(NSURLResponse * _Nonnull, NSError * _Nonnull))failure
{
    return [self uploadTaskWithRequest:request
                              fromData:bodyData
                              progress:uploadProgressBlock
                     completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                         
                         if (error != nil) {
                             
                             if (failure != nil) failure(response, error);
                             
                         } else {
                             
                             [self p_handleResponseObject:responseObject
                                          taskOrReseponse:response
                                           responseFilter:filter
                                                 forClass:cls
                                                  success:success
                                                  failure:failure];
                         }
                     }];
}

/// 上传数据流
- (NSURLSessionUploadTask *)uploadTaskWithStreamedRequest:(NSURLRequest *)request
                                                 progress:(void (^)(NSProgress * _Nonnull))uploadProgressBlock
                                           responseFilter:(id  _Nonnull (^)(id _Nullable))filter
                                                 forClass:(Class<SGSResponseSerializable>)cls
                                                  success:(void (^)(NSURLResponse * _Nonnull, id _Nullable))success
                                                  failure:(void (^)(NSURLResponse * _Nonnull, NSError * _Nonnull))failure
{
    return [self uploadTaskWithStreamedRequest:request
                                      progress:uploadProgressBlock
                             completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                 
                                 if (error != nil) {
                                     
                                     if (failure != nil) failure(response, error);
                                     
                                 } else {
                                     
                                     [self p_handleResponseObject:responseObject
                                                  taskOrReseponse:response
                                                   responseFilter:filter
                                                         forClass:cls
                                                          success:success
                                                          failure:failure];
                                 }
                             }];
}

/// 处理返回结果
- (void)p_handleResponseObject:(id _Nullable)responseObject
               taskOrReseponse:(id _Nonnull)task
                responseFilter:(id (^)(id _Nullable))filter
                      forClass:(Class<SGSResponseSerializable>)cls
                       success:(void (^)(id, id _Nullable))success
                       failure:(void (^)(id, NSError * _Nonnull))failure
{
    if (filter != nil) {
        id obj = filter(responseObject);
        if ([obj isKindOfClass:[NSError class]]) {
            if (failure) failure(task, obj);
            return ;
        } else {
            responseObject = obj;
        }
    }
    
    if (cls != nil) {
        if ([cls conformsToProtocol:@protocol(SGSResponseCollectionSerializable)] &&
            [cls respondsToSelector:@selector(colletionSerializeWithResponseObject:)]) {
            // 序列化为模型数组
            id obj = [cls performSelector:@selector(colletionSerializeWithResponseObject:) withObject:responseObject];
            
            if (obj == nil) {
                NSError *error = [NSError errorWithDomain:kResponseSerializeErrorDomain code:-8001 userInfo:@{NSLocalizedDescriptionKey: @"序列化为模型数组失败"}];
                if (failure) failure(task, error);
                return ;
                
            } else {
                responseObject = obj;
            }
            
        } else if ([cls conformsToProtocol:@protocol(SGSResponseObjectSerializable)] &&
                   [cls respondsToSelector:@selector(objectSerializeWithResponseObject:)]) {
            // 序列化为模型对象
            id obj = [cls performSelector:@selector(objectSerializeWithResponseObject:) withObject:responseObject];
            if (obj == nil) {
                NSError *error = [NSError errorWithDomain:kResponseSerializeErrorDomain code:-8002 userInfo:@{NSLocalizedDescriptionKey: @"序列化为模型对象失败"}];
                if (failure) failure(task, error);
                return ;
                
            } else {
                responseObject = obj;
            }
        }
    }
    
    if (success != nil) {
        success(task, responseObject);
    }
}
@end
