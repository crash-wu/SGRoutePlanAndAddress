//
//  GDSegmentModel.m
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import "GDSegmentModel.h"

@implementation GDSegmentModel

+ (nullable id<SGSResponseObjectSerializable>)objectSerializeWithResponseObject:(id)object{
    
    return [self yy_modelWithJSON:object];
}



@end
