//
//  GDSegmentModel.h
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
#import <SGSHTTPModule/SGSHTTPModule.h>

@interface GDSegmentModel : NSObject<SGSResponseObjectSerializable>


@property(nonnull,strong,nonatomic) NSString *coor;

@end
