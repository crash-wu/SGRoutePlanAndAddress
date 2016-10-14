//
//  BusTravelsLineCell.m
//  ChangSha
//
//  Created by 吴小星 on 16/9/29.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "BusTravelsLineCell.h"

@implementation BusTravelsLineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype )initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.busLineDetailContentView = [[BusTravelsContentView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.busLineDetailContentView];
        
    }
    
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.busLineDetailContentView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
        make.left.equalTo(self.contentView.mas_left).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
    }];
}

@end
