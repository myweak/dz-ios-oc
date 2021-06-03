//
//  RrDidProductDeTailModel.m
//  Scanner
//
//  Created by edz on 2020/7/20.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "RrDidProductDeTailModel.h"
@implementation RrDidProductDeTailModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"AactualReceipts":@"actualReceipts"};
}

/// get方法
- (NSString *)aliasName{
    if (checkStrEmty(_aliasName)) {
        return @"";
    }
    return  _aliasName;
}

- (NSString *)skuString{
    if(!checkStrEmty(_specifications)){
        NSArray * arr = [self  toArrayOrNSDictionary:[_specifications dataUsingEncoding:NSUTF8StringEncoding]];
        if (arr.count >0) {
            return [arr componentsJoinedByString:@"/"];
        }
    }
    return @"默认";
}

// 将JSON串转化为字典或者数组
- (id)toArrayOrNSDictionary:(NSData *)jsonData{
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}

/// set 方法

-(void)setTotalFee:(NSString *)totalFee{
    _totalFee = [NSString stringWithFormat:@"%.2f",[totalFee floatValue]];
}

-(void)setPayType:(NSNumber *)payType{ //支付方式:1在线支付，2线下支付
    _payType = payType;
    if ([payType intValue] == 1) {
        self.payTypeStr = @"线上支付";
    }else if ([payType intValue] == 2){
        self.payTypeStr = @"线下支付";
    }
}

/// 0 取消支付 1 待支付 3待完善  7 待发货 8待收货 9 已完成 《已废除： 2 待审核 4 加工分配 5 制作中 6 制作完成》
- (void)setOrderStatus:(NSNumber *)orderStatus{
    _orderStatus = orderStatus;
    
    switch ([orderStatus intValue]) {
        case 0:
            self.orderStatus_Str = @"已取消";
            break;
        case 1:
            self.orderStatus_Str = @"待付款";
            break;
        case 3:
            self.orderStatus_Str = @"待完善";
            break;
       
        case 7:
            self.orderStatus_Str = @"待发货";
            break;
            
        case 8:
            self.orderStatus_Str = @"待收货";
            break;
            
        case 9:
            self.orderStatus_Str = @"已完成";
            break;
            
        default:
            break;
    }
    
}



@end
