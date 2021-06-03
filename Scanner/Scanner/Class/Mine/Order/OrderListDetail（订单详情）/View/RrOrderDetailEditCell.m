//
//  RrOrderDetailEditCell.m
//  Scanner
//
//  Created by xiao on 2021/5/27.
//  Copyright © 2021 rrdkf. All rights reserved.
//

#import "RrOrderDetailEditCell.h"

@implementation RrOrderDetailEditCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentViewBg addCornerRadius:7.0];
    self.button.layer.borderWidth = 1.0f;
    self.button.layer.borderColor = [UIColor c_btn_Bg_Color].CGColor;
    
}

- (void)setModel:(RrDidProductDeTailModel *)model{
    _model = model;
    self.timeLabel.text =  model.reviewTime;
    self.reMarkLabel.text = model.rejectReason;
    CGFloat height = [self.reMarkLabel getLableHeightWithMaxWidth:KScreenWidth - 195 - 190].size.height;
    self.model.reMarkLabel_H = height;
}
- (IBAction)onTapBotton:(UIButton *)sender {
    !self.onTapBotton ?:self.onTapBotton();
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
