//
//  GDPath_ListModel.m
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import "GDPathListModel.h"

@implementation GDPathListModel

+ (nullable NSArray<id<SGSResponseObjectSerializable>> *)colletionSerializeWithResponseObject:(id)object{
    
    
    return [NSArray yy_modelArrayWithClass:self json:object];
}


+ (NSDictionary *)modelContainerPropertyGenericClass {
    // value should be Class or Class name.
    return @{@"path" : [GDPathModel class]};
}

@end
