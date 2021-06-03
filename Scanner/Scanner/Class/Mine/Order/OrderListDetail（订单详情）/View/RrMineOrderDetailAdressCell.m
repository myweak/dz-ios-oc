//
//  RrMineOrderDetailAdressCell.m
//  Scanner
//
//  Created by edz on 2020/7/28.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "RrMineOrderDetailAdressCell.h"
#import "OYCountDownManager.h"

@interface RrMineOrderDetailAdressCell()
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation RrMineOrderDetailAdressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.nameLabel.font =KFont20;
    self.phoneLabel.font =KFont20;
    self.adressLabel.font =KFont20;
    self.leftBtn.titleLabel.font =KFont20;
    self.rightBtn.titleLabel.font =KFont20;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.leftBtn.layer.borderWidth = 1.0f;
    self.leftBtn.layer.borderColor = [UIColor c_lineColor].CGColor;
    
    self.timeView.layer.borderWidth = 1.0f;
    self.timeView.layer.borderColor = [UIColor c_lineColor].CGColor;
    
    
    self.rightBtn.layer.borderWidth = 1.0f;
    self.rightBtn.layer.borderColor = [UIColor c_btn_Bg_Color].CGColor;
    //    [self.contenViewBg bezierPathWithRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadius:7.0f];
    [self.contenViewBg addCornerRadius:7.0f];
    
    [self.contenViewBg setBackgroundColor:[UIColor whiteColor]];
    
    self.topStautsView.hidden = YES;
    self.topStautsView_h.constant = 0;
}

- (void)setModel:(RrDidProductDeTailModel *)model{
    _model = model;
    self.nameLabel.text = model.doctorName;
    self.phoneLabel.text = model.doctorPhone;
    self.adressLabel.text = model.doctorAddr;
    self.topStautsLabel.text = model.orderStatus_Str;
    [self setBottomBtn];
}
/// 0 取消支付 1 待支付  3待完善  7 待发货 8 待收货 9 已完成
- (void)setBottomBtn{
    if (!self.model) {
        return;
    }
    NSString *leftStr = @"";
    NSString *rightStr = @"";
    self.timeView.hidden = YES;
    switch ([self.model.orderStatus intValue]) {
        case 0:// 已取消
            break;
        case 3://待完善
            rightStr = KOrderDetail_complete;// 待完善;
            break;
        case 1:// 待付款
//            if (self.model.timePut) {
//                self.timeView.hidden = NO;
//            }
            leftStr = KOrderDetail_cancelOrder;//@"取消订单";
            rightStr = KOrderDetail_playNotif;//@"支付提醒";
            if (self.model.remindPaySwitch) {
                self.rightBtn.layer.borderColor = [UIColor c_btn_Bg_Color].CGColor;
                [self.rightBtn setTitleColor:[UIColor c_btn_Bg_Color] forState:UIControlStateNormal];
            }else{
                self.rightBtn.userInteractionEnabled = NO;
                self.rightBtn.layer.borderColor = [UIColor c_lineColor].CGColor;
                [self.rightBtn setTitleColor:[UIColor c_lineColor] forState:UIControlStateNormal];
            };
            break;
        case 7:// 待发货
//            if (self.model.timePut) {
//                self.timeView.hidden = NO;
//            }
            rightStr =KOrderDetail_send;// @"提醒发货";
            if (self.model.remindShipSwitch) {
                self.rightBtn.layer.borderColor = [UIColor c_btn_Bg_Color].CGColor;
                [self.rightBtn setTitleColor:[UIColor c_btn_Bg_Color] forState:UIControlStateNormal];
            }else{
                self.rightBtn.userInteractionEnabled = NO;
                self.rightBtn.layer.borderColor = [UIColor c_lineColor].CGColor;
                [self.rightBtn setTitleColor:[UIColor c_lineColor] forState:UIControlStateNormal];
            };
            break;
        case 8://待收货
            leftStr = KOrderDetail_logistics;// @"查看物流";
            rightStr = KOrderDetail_okGoods;//@"确认收货";
            break;
        case 9://已完成
            rightStr =KOrderDetail_logistics;//@"查看物流";
            break;
            
        default:
            break;
    }
    
    
    
    self.bottomViewBg.hidden = checkStrEmty(leftStr) && checkStrEmty(rightStr);
    self.leftBtn.hidden = checkStrEmty(leftStr);
    self.rightBtn.hidden = checkStrEmty(rightStr);
    [self.leftBtn setTitle:leftStr forState:UIControlStateNormal];
    [self.rightBtn setTitle:rightStr forState:UIControlStateNormal];
}


- (IBAction)leftBtnAction:(UIButton *)sender {
    !self.backBlock ?:self.backBlock(sender.currentTitle);
}

- (IBAction)rightBtnAction:(UIButton *)sender {
    !self.backBlock ?:self.backBlock(sender.currentTitle);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark - 付款提醒 倒计时逻辑

// xib创建
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        // 监听通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countDownNotification:) name:OYCountDownNotification object:nil];
    }
    return self;
}

#pragma mark - 倒计时通知回调
- (void)startTime{
    [kCountDownManager start];
    [kCountDownManager addSourceWithIdentifier:self.model.outTradeNo];
    [kCountDownManager reloadSourceWithIdentifier:self.model.outTradeNo];
    self.model.timePut = YES;
    self.timeView.hidden = NO;
    
    [self countDownNotification:nil];
}
- (void)countDownNotification: (NSNotification *) notify{
    
    /// 判断是否需要倒计时 -- 可能有的cell不需要倒计时,根据真实需求来进行判断
    if (0) {
        return;
    }
    /// 计算倒计时
    NSInteger timeInterval = 0;
    if ([kCountDownManager getIdentifierObject:self.model.outTradeNo]) {
        NSLog(@"----%@",self.model.outTradeNo);
        timeInterval = [kCountDownManager timeIntervalWithIdentifier:self.model.outTradeNo];
        
        NSInteger countDown = KTimeInterval - timeInterval;
        self.model.timePut = YES;
        self.timeView.hidden = NO;
        
        /// 当倒计时到了进行回调
        if (countDown < 0) {
            [kCountDownManager removeSourceWithIdentifier:self.model.outTradeNo];
            self.model.timePut = NO;
            self.timeView.hidden = YES;
            // 回调给控制器
            if (self.countDownZero) {
                self.countDownZero(self.model);
            }
            return;
        }
        /// 重新赋值
        NSString *title = [NSString stringWithFormat:@"%ld",countDown];
        //        [self.rightBtn setTitle:title forState:UIControlStateNormal];
        self.timeLabel.text = title;
    }else{
        self.model.timePut = NO;
        self.timeView.hidden = YES;
    }
}



- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
