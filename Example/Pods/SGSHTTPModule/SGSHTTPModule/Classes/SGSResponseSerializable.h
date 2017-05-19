/*!
 @header SGSResponseObjectSerializable.h
 
 @abstract 请求结果序列化对象协议
 
 @author Created by Lee on 16/5/5.
 
 @copyright 2016年 SouthGIS. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @protocol SGSResponseSerializable
 *
 *  @abstract 响应结果序列化基础协议
 *
 *  @discussion 该协议仅用于定义基础协议，请使用具体的 `SGSResponseObjectSerializable` 或 `SGSResponseCollectionSerializable`
 */
@protocol SGSResponseSerializable <NSObject>
@end



/*!
 *  @protocol SGSResponseObjectSerializable
 *
 *  @abstract 可将响应结果序列化为模型对象的协议，提供转换方法
 */
@protocol SGSResponseObjectSerializable <SGSResponseSerializable>

/*!
 *  @abstract 将响应结果转换为模型对象
 *
 *  @param object 响应结果
 *
 *  @return 转换成功返回模型对象，否则返回 `nil`
 */
+ (nullable id<SGSResponseObjectSerializable>)objectSerializeWithResponseObject:(id)object;

@end

/*!
 *  @protocol SGSResponseCollectionSerializable
 *
 *  @abstract 可将响应结果序列化为模型对象的协议，提供转换方法
 */
@protocol SGSResponseCollectionSerializable <SGSResponseSerializable>

/*!
 *  @abstract 将响应结果转换为内容全部是模型对象的数组
 *
 *  @param object 响应结果
 *
 *  @return 转换成功返回 `NSArray` ，否则返回 `nil`
 */
+ (nullable NSArray<id<SGSResponseObjectSerializable>> *)colletionSerializeWithResponseObject:(id)object;

@end

NS_ASSUME_NONNULL_END
