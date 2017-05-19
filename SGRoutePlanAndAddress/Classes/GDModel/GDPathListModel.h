//
//  GDPath_ListModel.h
//  IndoorLocationDemo
//
//  Created by 吴小星 on 2017/5/15.
//  Copyright © 2017年 crash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDPathModel.h"
#import <YYModel/YYModel.h>
#import <SGSHTTPModule/SGSHTTPModule.h>

@interface GDPathListModel : NSObject<SGSResponseCollectionSerializable>

@property(nonatomic,strong,nonnull) NSArray<GDPathModel*> *path;

@end
