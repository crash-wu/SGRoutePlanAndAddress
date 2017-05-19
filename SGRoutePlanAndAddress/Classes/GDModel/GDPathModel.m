//
//  GDPathModel.m
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import "GDPathModel.h"

@implementation GDPathModel

+ (nullable NSArray<id<SGSResponseObjectSerializable>> *)colletionSerializeWithResponseObject:(id)object{
    
    
    return [NSArray yy_modelArrayWithClass:self json:object];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"segments" : [GDSegmentModel class]};
}


@end
