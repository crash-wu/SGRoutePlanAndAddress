//
//  ChangShaSurroundAddressSearchModel.m
//  ChangSha
//
//  Created by 吴小星 on 16/10/9.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGSurroundAddressSearchModel.h"

@implementation SGSurroundAddressSearchModel


-(instancetype) init{
    if (self= [super init]) {
        
        self.inSR = 4490;
        self.outSR = 4490;
        self.distance = 500;
        self.page = 1;
        self.size = 10;
    }
    
    return self;
}

@end
