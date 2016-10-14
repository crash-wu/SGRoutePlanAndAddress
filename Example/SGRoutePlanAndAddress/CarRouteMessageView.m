//
//  CarRouteMessageView.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CarRouteMessageView.h"

@implementation CarRouteMessageView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.addressLb = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:self.addressLb];
        self.addressLb.numberOfLines = 0;
        
        self.placeholderLb = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:self.placeholderLb];
        
        self.distancLb = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:self.distancLb];
        
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.addressLb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top).offset(5);
        make.left.equalTo(self.mas_left).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
        make.bottom.equalTo(self.mas_centerY).offset(-10);
    }];
    
    self.addressLb.textColor = [UIColor blackColor];
    self.addressLb.textAlignment = NSTextAlignmentLeft  ;
    self.addressLb.font = [UIFont systemFontOfSize:14.f];
    
    [self.placeholderLb mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.addressLb.mas_bottom).offset(5);
        make.left.equalTo(self.mas_left).offset(10);
        make.width.equalTo(@(40));
        make.bottom.equalTo(self.mas_bottom).offset(-5);
    }];
    self.placeholderLb.textColor = [[UIColor alloc]initWithRed:206.f/255 green:206.f/255 blue:206.f/255 alpha:1.f];
    self.placeholderLb.textAlignment = NSTextAlignmentLeft;
    self.placeholderLb.text = @"里程:";
    self.placeholderLb.font = [UIFont systemFontOfSize:13.f];
    
    [self.distancLb mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.placeholderLb.mas_top);
        make.left.equalTo(self.placeholderLb.mas_right).offset(5);
        make.right.equalTo(self.mas_right).offset(-10);
        make.bottom.equalTo(self.mas_bottom).offset(-5);
    }];
    
    self.distancLb.textAlignment = NSTextAlignmentLeft;
    self.distancLb.textColor = [[UIColor alloc]initWithRed:253.f/255 green:108.f/255 blue:16.f/255 alpha:1.f];
    self.distancLb.font = [UIFont systemFontOfSize:13.f];
    
}

@end
