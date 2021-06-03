//
//  RrMineOrderListDetailVC.h
//  Scanner
//
//  Created by edz on 2020/7/28.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "MainViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^OrderStatusChangeBlock)(NSNumber *orderStatus,NSNumber *payType);

@interface RrMineOrderListDetailVC : MainViewController
@property (nonatomic, copy)   NSString *outTradeNo; // 订单号
@property (nonatomic, assign) OrderStatusChangeBlock orderStatusChangeBlock;
@end

NS_ASSUME_NONNULL_END
