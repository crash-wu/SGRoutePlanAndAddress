//
//  BusLineMessageModel.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/28.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "BusLineMessageModel.h"

@implementation BusLineMessageModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"travels" : [BusTravelsModel class]};
}



+ (id<SGSResponseObjectSerializable>)objectSerializeWithResponseObject:(id)object {
    
    return [self yy_modelWithJSON:object];
}

@end
