//
//  RrMineOrderListVC.m
//  Scanner
//
//  Created by edz on 2020/7/27.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "RrMineOrderListVC.h"
#import "RrMineOrderListCell.h"
#import "RrMineOrderListModel.h"
#import "RrMineOrderListDetailVC.h" // 订单详情
#import "RrMineOrderListDetailEdittingVC.h" //修改信息
#import "OYCountDownManager.h"

@interface RrMineOrderListVC ()<UITableViewDelegate,UITableViewDataSource, DZNEmptyDataSetDelegate>

@property (nonatomic, strong) NSMutableArray *listArr;
@property (nonatomic, assign) NSInteger pageNum;
@property (nonatomic, assign) BOOL isHeadRefreshing; // 头部刷新
@property (nonatomic, strong) UILabel *emptyDataLabel;
@property (nonatomic, assign) BOOL isCacheEGO;//是否是缓存数据
@end

@implementation RrMineOrderListVC
- (void)dealloc{
    [kCountDownManager removeAllSource];
    [kCountDownManager invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableView = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        [self.tableView reloadData];
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrderListNotification:) name:KNotification_name_updateOrder_list object:nil];
    [self addTableView];
    [self.tableView.mj_header beginRefreshing];
    
}

- (void)addTableView{
    [self.view addSubview:self.tableView];
    [self.tableView registerNibString:NSStringFromClass([RrMineOrderListCell class]) cellIndentifier:KRrMineOrderListCell_ID];
    @weakify(self)
    self.pageNum = 1;
    self.isHeadRefreshing = YES;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        self.pageNum = 1;
        self.isHeadRefreshing =YES;
        [self postUserOrderListUrl];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        self.isHeadRefreshing = NO;
        [self postUserOrderListUrl];
    }];
    

}

- (void)updateOrderListNotification:(NSNotification *)notify{
    self.pageNum = 1;
    self.isHeadRefreshing =YES;
    [self postUserOrderListUrl];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return self.listArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 17;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 17)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    RrMineOrderListModel *model = self.listArr[indexPath.section];
  
    //已取消
    if([model.orderStatus intValue] == 0){
        return 294-77;
    }
    return 294;
  
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    @weakify(self)
    RrMineOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:KRrMineOrderListCell_ID forIndexPath:indexPath];
    RrMineOrderListModel *model = self.listArr[indexPath.section];
    cell.model = model;
    __weak RrMineOrderListCell *weakCell = cell;
    cell.backBlock = ^(NSString * _Nonnull currentTitle) {
        NSLog(@"%@",currentTitle);
        if ([currentTitle isEqualToString:KOrderDetail_cancelOrder]) {//取消订单
            [self AlertWithTitle:@"温馨提示" message:@"是否取消该订单" andOthers:@[@"取消",@"确认"]  animated:YES action:^(NSInteger index) {
                if(index == 1){
                    [self changeOrderStatusUrlWithModel:model SelectOrderStatus:@(0)];
                }
            }];
        }else if ([currentTitle isEqualToString:KOrderDetail_playNotif]) {//支付提醒
//            [weakCell startTime];
            [self showPayNotifiWithModel:model];
            
            
        }else if ([currentTitle isEqualToString:KOrderDetail_send]) {//提醒发货
//            [weakCell startTime];
            [self putOrderRemindNotifiWithModel:model];
        }else if ([currentTitle isEqualToString:KOrderDetail_logistics]) { //查看物流
            NSString *content = [NSString stringWithFormat:@"%@  %@",model.express,model.trackingNumber];
                [self AlertWithTitle:@"物流信息"  message:content andOthers:@[@"复制"] animated:YES action:^(NSInteger index) {
                    showMessage(@"复制成功!");
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = checkStrEmty(model.trackingNumber) ? @"":model.trackingNumber;
                }];
        }else if ([currentTitle isEqualToString:KOrderDetail_okGoods]) { //确认收货
            [self AlertWithTitle:@"温馨提示" message:@"确认已收到货物？" andOthers:@[@"取消",@"确认"] animated:YES action:^(NSInteger index) {
                if(index == 1){
                    [self changeOrderStatusUrlWithModel:model SelectOrderStatus:@(9)];
                }
            }];
        }else if ([currentTitle isEqualToString:KOrderDetail_complete]) { //待完善
            RrMineOrderListDetailEdittingVC *edtingVC = [RrMineOrderListDetailEdittingVC new];
            edtingVC.outTradeNo = model.outTradeNo;
            [self.navigationController pushViewController:edtingVC animated:YES];
        }
      
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RrMineOrderListModel *model = self.listArr[indexPath.section];
    if (checkStrEmty( model.outTradeNo)) {
        showMessage(@"订单号出错");
        return;
    }
    @weakify(self)
    RrMineOrderListDetailVC *detailVc = [RrMineOrderListDetailVC new];
    detailVc.outTradeNo = model.outTradeNo;
    [self.navigationController pushViewController:detailVc animated:YES];
}



//空数据显示
- (UILabel *)emptyDataLabel{
    if (!_emptyDataLabel) {
        _emptyDataLabel = [[UILabel alloc] init];
        _emptyDataLabel.frame = CGRectMake(0, 60, 200, 30);
        _emptyDataLabel.centerX = self.tableView.width/2.0f;
        _emptyDataLabel.textAlignment = NSTextAlignmentCenter;
        _emptyDataLabel.text = @"暂无此类订单";
        _emptyDataLabel.textColor = [UIColor c_GrayNotfiColor];
        _emptyDataLabel.font = KFont19;
        _emptyDataLabel.backgroundColor = [UIColor clearColor];
        _emptyDataLabel.hidden = YES;
        
    }
    return _emptyDataLabel;
}
- (UITableView *)tableView{
    
    if (!_tableView) {//UITableViewStyleGrouped
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KFrameWidth, (KFrameHeight-64-iPH(50))) style:UITableViewStylePlain];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 73;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor mian_BgColor];
        _tableView.tableHeaderView = [UIView new];
        _tableView.tableFooterView = [UIView new];
        [_tableView addSubview:self.emptyDataLabel];
        //        _tableView.separatorInset = UIEdgeInsetsMake(0, iPW(53), 0, iPW(72));
    }
    return _tableView;
}

#pragma mark --网络 Url
//付款提醒
- (void)showPayNotifiWithModel:(RrMineOrderListModel *)model{
    if (checkStrEmty(model.outTradeNo)) {
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [[RRNetWorkingManager sharedSessionManager]  putOrderPayNotifi:@{@"outTradeNo":model.outTradeNo} result:ResultBlockMake(^(NSDictionary * _Nonnull dict, RrResponseModel * _Nonnull responseModel, NSError * _Nonnull error) {
        if (!error) {
//            showMessage(@"发送成功");
            [self AlertWithTitle:@"提醒支付" message:@"已发送微信推送提醒用户支付，请耐心等待！" andOthers:@[@"确认"] animated:YES action:^(NSInteger index) {
            }];
            [self.tableView.mj_header beginRefreshing];
        }else{
            showMessage(responseModel.msg);
        }
        [SVProgressHUD dismiss];
    }, nil)];
}

///发货提醒
- (void)putOrderRemindNotifiWithModel:(RrMineOrderListModel *)model{
    if (checkStrEmty(model.outTradeNo)) {
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [[RRNetWorkingManager sharedSessionManager] putOrderRemindNotifi:@{@"outTradeNo":model.outTradeNo,@"checkRemind":@(1)} result:ResultBlockMake(^(NSDictionary * _Nonnull dict, RrResponseModel * _Nonnull responseModel, NSError * _Nonnull error) {
        if (!error) {
//            showMessage(@"发送成功");
            [self AlertWithTitle:@"提醒发货" message:@" 已催促厂商尽快发货，请耐心等待！" andOthers:@[@"确认"] animated:YES action:^(NSInteger index) {
            }];
            [self.tableView.mj_header beginRefreshing];
        }else{
            showMessage(responseModel.msg);
        }
        [SVProgressHUD dismiss];
    }, nil)];
    
}


/**
 orderStatus=0  取消订单
 orderStatus=2  完善测量数据
 orderStatus=9  确认收货
 */
- (void)changeOrderStatusUrlWithModel:(RrMineOrderListModel *)model SelectOrderStatus:(NSNumber *)orderStatus{
    @weakify(self)
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter setValue:model.outTradeNo forKey:@"outTradeNo"];
    [parameter setValue:orderStatus forKey:@"orderStatus"];
    [[RRNetWorkingManager sharedSessionManager] changeOrderStatus:parameter result:ResultBlockMake(^(NSDictionary * _Nonnull dict, RrResponseModel * _Nonnull responseModel, NSError * _Nonnull error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
                [self.tableView.mj_header beginRefreshing];
            });
        }
        showMessage(responseModel.msg);
        [SVProgressHUD dismiss];
    }, nil)];
    
}

- (void)postUserOrderListUrl{
    
    @weakify(self)
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter setValue:@(self.pageNum) forKey:@"pageNum"];
    [parameter setValue:@(20) forKey:@"pageSize"];
    [parameter setValue:self.orderStatus  forKey:@"orderStatus"];
    [parameter setValue:KisAddEGOCache_value forKey:KisAddEGOCache_Key];
    self.isCacheEGO = YES;
    [[RRNetWorkingManager sharedSessionManager] postUserOrderList:parameter result:ResultBlockMake(^(NSDictionary * _Nonnull dict, RrResponseModel * _Nonnull responseModel, NSError * _Nonnull error) {
        @strongify(self);
        if (!error) {
            
            if (self.isHeadRefreshing) {
                self.listArr = [NSMutableArray arrayWithArray:responseModel.list];
            }else{
                [self.listArr addObjectsFromArray:responseModel.list];
            }
            
            RrDataPageModel *pageModel =  responseModel.pageData;
            if ([pageModel.total integerValue] == self.listArr.count && self.listArr.count !=0) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [self.tableView.mj_footer resetNoMoreData];
            }
            if (responseModel.list.count >0) {
                self.pageNum ++;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.emptyDataLabel.hidden = self.listArr.count;
                [self.tableView reloadData];
                KPostNotification(KNotificationUpdataOrderNum, nil);
            });
        }
        if (!responseModel.isCashEQO) {
            self.isCacheEGO = NO;
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [SVProgressHUD dismiss];
        }
        
        
    }, [RrMineOrderListModel class])];
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
