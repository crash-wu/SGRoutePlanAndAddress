//
//  CarRouteResultDetailView.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/23.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CarRouteResultDetailView.h"

@implementation CarRouteResultDetailView


-(instancetype) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.addressLb = [[UILabel alloc]initWithFrame:CGRectZero];
        [self addSubview:self.addressLb];
        self.addressLb.textAlignment = NSTextAlignmentCenter;
        self.addressLb.textColor = [UIColor blackColor];
        self.addressLb.font = [UIFont systemFontOfSize:13.f];
        self.addressLb.backgroundColor = [[UIColor alloc]initWithRed:245.f/255 green:245.f/255 blue:245.f/255 alpha:1.f];
        
        self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        [self addSubview:self.tableView];
        self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        
        
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.addressLb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.mas_top);
        make.height.equalTo(@(50));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.addressLb.mas_bottom).offset(10);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        
    }];
}

@end
