//
//  RrMineOrderListCell.m
//  Scanner
//
//  Created by edz on 2020/7/27.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "RrMineOrderListCell.h"
#import "SDWebImageDownloader.h"
#import "OYCountDownManager.h"

@interface RrMineOrderListCell()
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftBtn_xr;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) OYCountDownManager *timeObjct;
@end

@implementation RrMineOrderListCell

- (void)awakeFromNib {
    [kCountDownManager removeAllSource];
    [kCountDownManager invalidate];
    
    self.outRradeNoLabel.font = KFont20;
    self.orderStatusLabel.font = KFont20;
    self.nameLabel.font = KFont20;
    self.feeLabel.font = KFont20;
    self.createTiemLabel.font = KFont17;
    self.userNamePhoneLabel.font = KFont20;
    self.leftBtn.titleLabel.font = KFont20;
    self.rightBtn.titleLabel.font = KFont20;


    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.leftBtn.layer.borderWidth = 1.0f;
    self.leftBtn.layer.borderColor = [UIColor c_lineColor].CGColor;
    
    self.timeView.layer.borderWidth = 1.0f;
    self.timeView.layer.borderColor = [UIColor c_lineColor].CGColor;
    
    self.rightBtn.layer.borderColor = [UIColor c_btn_Bg_Color].CGColor;
    [self.rightBtn setTitleColor:[UIColor c_btn_Bg_Color] forState:UIControlStateNormal];
    self.rightBtn.layer.borderWidth = 1.0f;
    
    
}



- (void)setModel:(RrMineOrderListModel *)model{
    _model = model;
    @weakify(self)
    self.outRradeNoLabel.text = [NSString stringWithFormat:@"%@%@",@"订单编号：",model.outTradeNo];
    self.orderStatusLabel.text = model.orderStatus_Str;
    [self.iconImageView sd_setImageWithURL:model.productIcon.url placeholderImage:KPlaceholderImage_product];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@  %@",model.productName,model.productCode];
    self.createTiemLabel.text = [NSString stringWithFormat:@"%@%@",@"下单时间：",[model.createTime dateStringFromTimeYMDHMS]];
    self.userNamePhoneLabel.text = [NSString stringWithFormat:@"%@%@ %@",@"用户：",model.patientName,model.patientPhone];
    self.feeLabel.text = [NSString stringWithFormat:@"%@%@",@"￥",[model.actualReceipts reviseStringMoney]];
    
    if ([kCountDownManager getIdentifierObject:self.model.outTradeNo]) {
        [kCountDownManager start];
        self.model.timePut = YES;
        self.timeView.hidden = NO;
    }
    
    [self setBottomBtn];
    
    
    [self.nameLabel handleTap:^(CGPoint loc, UIGestureRecognizer *tapGesture) {
        showMessage(@"复制成功");
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = model.productName;
    }];
    [self.outRradeNoLabel handleTap:^(CGPoint loc, UIGestureRecognizer *tapGesture) {
        showMessage(@"复制成功");
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = model.outTradeNo;
    }];
    
}
/// 1 待支付  3待完善   7 待发货  8待收货  9 已完成
- (void)setBottomBtn{
    if (!self.model) {
        return;
    }

    self.timeView.hidden = YES;
    self.showStautsLabel.hidden = YES;
    NSString *leftStr = @"";
    NSString *rightStr = @"";
    self.rightBtn.userInteractionEnabled = YES;
    switch ([self.model.orderStatus intValue]) {
        case 0:// 已取消
            break;
        case 1:// 待付款
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

//            if (self.model.timePut) {
//                self.timeView.hidden = NO;
//            }
            break;
        case 3://待完善
            rightStr = KOrderList_complete; //@"去完善";
            self.showStautsLabel.hidden = NO;
            self.rightBtn.userInteractionEnabled = NO;
            break;
        case 7:// 待发货
//            if (self.model.timePut) {
//                self.timeView.hidden = NO;
//            }
            rightStr = KOrderDetail_send; //@"提醒发货";
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
            rightStr =KOrderDetail_okGoods;// @"确认收货";
            break;
        case 9://已完成
            rightStr =  KOrderDetail_logistics;//@"查看物流";
            break;
       
        default:
            break;
    }

    self.bottomView.hidden = checkStrEmty(leftStr) && checkStrEmty(rightStr);
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
    //    self.model.timePut = NO;
    if ([kCountDownManager getIdentifierObject:self.model.outTradeNo]) {
        //        NSLog(@"----%@",self.model.outTradeNo);
        timeInterval = [kCountDownManager timeIntervalWithIdentifier:self.model.outTradeNo];
        //    NSInteger timeInterval = kCountDownManager.timeInterval;
        
        NSInteger countDown = KTimeInterval - timeInterval;
        self.model.timePut = YES;
        
        /// 当倒计时到了进行回调
        if (countDown < 0) {
            self.model.timePut = NO;
            self.timeView.hidden = YES;
            [kCountDownManager removeSourceWithIdentifier:self.model.outTradeNo];
            
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
