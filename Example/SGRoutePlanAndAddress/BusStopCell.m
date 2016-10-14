//
//  BusStopCell.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/27.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "BusStopCell.h"

@implementation BusStopCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier: reuseIdentifier]) {
        
        self.searchImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.searchImageView];
        
        self.detailLb = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.detailLb];
        self.detailLb.textAlignment = NSTextAlignmentLeft;
        
        self.line = [[UIView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.line];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return  self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(10);
        make.width.equalTo(@(24));
        make.height.equalTo(@(24));
    }];
    
    [self.detailLb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.searchImageView.mas_right).offset(10);
        make.right.equalTo(self.contentView.mas_right).offset(-44);
        make.height.equalTo(@(20));
    }];
    
   // self.detailLb.textAlignment = NSTextAlignmentLeft;
    self.detailLb.textColor = [UIColor blackColor];
    self.detailLb.font = [UIFont systemFontOfSize:13.f];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@(1));
        make.left.equalTo(self.contentView.mas_left);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    self.line.backgroundColor = [[UIColor alloc]initWithRed:238.f/255 green:238.f/255 blue:238.f/255 alpha:1.f];
    
}
@end
