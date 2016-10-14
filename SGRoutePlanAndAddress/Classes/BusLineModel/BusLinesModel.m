//
//  BusLinesModel.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/29.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "BusLinesModel.h"

@implementation BusLinesModel


+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"stopName" : [NSString class]};
}


+ (nullable NSArray<id<SGSResponseObjectSerializable>> *)colletionSerializeWithResponseObject:(id)object{
    
    
    return [NSArray yy_modelArrayWithClass:self json:object];
}

@end
