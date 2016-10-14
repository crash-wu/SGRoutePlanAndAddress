//
//  BusTravelsContentView.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/30.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "BusTravelsContentView.h"

@implementation BusTravelsContentView


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.lineNameLb = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:self.lineNameLb];
        
        self.stopNameLb = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:self.stopNameLb];
        
        self.changNumLb = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:self.changNumLb];
        
        self.arrowImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self addSubview:self.arrowImageView];
        self.arrowImageView.image = [UIImage imageNamed:@"next_icon"];
        
        self.separate = [[UIView alloc]initWithFrame:CGRectZero];
        [self addSubview:self.separate];
        
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.lineNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left).offset(10);
        make.height.equalTo(self.mas_height).dividedBy(2);
        make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
        
    }];
    
    self.lineNameLb.textColor = [UIColor blackColor];
    self.lineNameLb.font = [UIFont systemFontOfSize:13.f];
    self.lineNameLb.textAlignment = NSTextAlignmentLeft;
    
    [self.changNumLb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.lineNameLb.mas_left);
        make.top.equalTo(self.lineNameLb.mas_bottom);
        make.height.equalTo(self.mas_height).dividedBy(3);
        make.width.equalTo(self.stopNameLb.mas_width);
    }];
    
    self.changNumLb.textAlignment = NSTextAlignmentLeft;
    self.changNumLb.font = [UIFont systemFontOfSize:12.f];
    self.changNumLb.textColor = [[UIColor alloc]initWithRed:202.f/255 green:202.f/255 blue:202.f/255 alpha:1.f];
    
    [self.stopNameLb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.changNumLb.mas_right);
        make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
        make.top.equalTo(self.changNumLb.mas_top);
        make.height.equalTo(self.changNumLb.mas_height);
    }];
    
    self.stopNameLb.textAlignment = NSTextAlignmentLeft;
    self.stopNameLb.font = [UIFont systemFontOfSize:12.f];
    self.stopNameLb.textColor = [[UIColor alloc]initWithRed:202.f/255 green:202.f/255 blue:202.f/255 alpha:1.f];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@(24));
        make.height.equalTo(@(24));
        make.right.equalTo(self.mas_right).offset(-10);
        
    }];
    
    
    [self.separate mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@(0.5));
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
    }];
    
    self.separate.backgroundColor =[[UIColor alloc]initWithRed:202.f/255 green:202.f/255 blue:202.f/255 alpha:1.f];
}



@end
