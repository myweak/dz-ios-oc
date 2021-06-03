//
//  RrMineOrderListVC.h
//  Scanner
//
//  Created by edz on 2020/7/27.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "MainViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RrMineOrderListVC : MainViewController
///全部：不传值  1 待支付  3待完善   7 待发货  8待收货  9 已完成
@property (nonatomic, copy) NSString *orderStatus;
@property (nonatomic, strong) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
