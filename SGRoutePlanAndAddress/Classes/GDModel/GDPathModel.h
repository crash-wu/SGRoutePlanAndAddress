//
//  GDPathModel.h
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDSegmentModel.h"
#import <YYModel/YYModel.h>
#import <SGSHTTPModule/SGSHTTPModule.h>

@interface GDPathModel : NSObject<SGSResponseCollectionSerializable>

@property(nonnull,strong,nonatomic) NSArray<GDSegmentModel*> *segments;

@end
