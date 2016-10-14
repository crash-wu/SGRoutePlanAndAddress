//
//  BusTravelLineModel.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/29.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "BusTravelsModel.h"

@implementation BusTravelsModel


+ (NSDictionary *)modelContainerPropertyGenericClass {

    return @{@"lines" : [BusLinesModel class]};
}

+ (id<SGSResponseObjectSerializable>)objectSerializeWithResponseObject:(id)object {
    
    return [self yy_modelWithJSON:object];
}

@end
