//
//  CarRouteDetailCell.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/26.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "CarRouteDetailCell.h"

@implementation CarRouteDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self= [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.upLine = [[UIView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.upLine];
        self.upLine.backgroundColor = [[UIColor alloc]initWithRed:245.f/255 green:245.f/255 blue:245.f/255 alpha:1.f];
        
        self.plottingImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.plottingImageView];
        
        self.downLine = [[UIView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.downLine];
        self.downLine.backgroundColor = [[UIColor alloc]initWithRed:245.f/255 green:245.f/255 blue:245.f/255 alpha:1.f];
        
        self.detailLb = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.detailLb];
        self.detailLb.textColor = [[UIColor alloc]initWithRed:102.f/255 green:102.f/255 blue:102.f/255 alpha:1.f];
        self.detailLb.font = [UIFont systemFontOfSize:13.f];
        
        self.separateLine = [[UIView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.separateLine];
        self.separateLine.backgroundColor =[[UIColor alloc]initWithRed:245.f/255 green:245.f/255 blue:245.f/255 alpha:1.f];
        
        self.arrowImagView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.arrowImagView];
        self.arrowImagView.image = [UIImage imageNamed:@"next_icon"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.upLine mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.contentView.mas_top);
        make.left.equalTo(self.contentView.mas_left).offset(20);
        make.width.equalTo(@(5));
        make.bottom.equalTo(self.plottingImageView.mas_top);
        
    }];
    
    [self.plottingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.upLine.mas_centerX);
        make.width.equalTo(@(21));
        make.height.equalTo(@(21));
        make.bottom.equalTo(self.downLine.mas_top);
    }];
    
    [self.downLine mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.upLine.mas_centerX);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.width.equalTo(@(5));
        make.height.equalTo(self.upLine.mas_height);
    }];
    
    [self.detailLb mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.upLine.mas_right).offset(20);
        make.height.equalTo(@(25));
        make.right.equalTo(self.arrowImagView.mas_left).offset(-10);
        
    }];
    
    [self.arrowImagView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(self.detailLb.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.width.equalTo(@(24));
        make.height.equalTo(@(24));
    }];
    
    [self.separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.detailLb.mas_left);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-1);
        make.height.equalTo(@(1));
        make.right.equalTo(self.contentView.mas_right).offset(-5);
    }];
    
}

@end
