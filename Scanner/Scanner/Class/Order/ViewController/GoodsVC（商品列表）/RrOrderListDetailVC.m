//
//  RrOrderListDetailVC.m
//  Scanner
//
//  Created by edz on 2020/7/20.
//  Copyright © 2020 rrdkf. All rights reserved.
//
#define KDefaultSelectedSkuStr @"请选择规格"
#import "RrOrderListDetailVC.h"
#import "RrPostOrderListDetailVC.h"
#import "RrOrderListDetailCell.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "GoodsSKUViewController.h"
#import "RrGoodsSKUModel.h"
@interface RrOrderListDetailVC ()<UITableViewDelegate,UITableViewDataSource,WKNavigationDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat webView_height;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIButton *bottomBtn;
@property (nonatomic, strong) NSArray *allAttrIds;
@property (nonatomic, assign) NSInteger number;
@property (nonatomic, copy)   NSString *selectedSkuStr;
@property (nonatomic, copy)   NSString *price;

///产品适用范围
@property (nonatomic, strong) UILabel *productAbstractLabel;

@end

@implementation RrOrderListDetailVC

- (void)viewDidAppear:(BOOL)animated{
    [MobClick beginLogPageView:@"商品详情"]; //("Pagename"为页面名称，可自定义)
}


- (void)viewDidDisappear:(BOOL)animated{
    [MobClick endLogPageView:@"商品详情"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView_height  = 20;
    self.number = 1;
    self.selectedSkuStr = KDefaultSelectedSkuStr;
    self.price = self.productModel.productPrice;
    
    [self.view addSubview:self.tableView];
    [self.tableView registerNibString:NSStringFromClass([RrOrderListDetailCell class]) cellIndentifier:KRrOrderListDetailCell_ID];
    [self getProductDetailUrl];
    @weakify(self);
    if (self.type == RrOrderListDetailVCType_nomal) {
        self.tableView.hidden = YES;
        self.bottomBtn = [self addBottomBtnWithTitle:@"立即定制" actionBlock:^(UIButton * _Nonnull btn) {
            @strongify(self)
            if([self.selectedSkuStr isEqualToString:KDefaultSelectedSkuStr]){
//                showMessage(KDefaultSelectedSkuStr);
                [self showBuyProductSKUView];
                return;
            }
            [self pushToRrPostOrderListDetailVC];
        }];
        self.tableView.height = self.bottomBtn.top;
        self.bottomBtn.hidden = YES;
    }
    [self.notNetWorkView.tapViewBg handleTap:^(CGPoint loc, UIGestureRecognizer *tapGesture) {
        @strongify(self)
        [self getProductDetailUrl];
    }];
    
}

/// 下单页面
-(void)pushToRrPostOrderListDetailVC{
    self.productModel.productNum = @(self.number);
    self.productModel.productSkuPrice =self.price ;
    self.productModel.skuString = self.selectedSkuStr;
    RrPostOrderListDetailVC *detailVc =[RrPostOrderListDetailVC new];
    detailVc.productModel = self.productModel;
    detailVc.title = self.productModel.name;
    
    [self.navigationController pushViewController:detailVc animated:YES];
}


#pragma  mark - UITableViewDelegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.productModel ? 1:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    return 355 + (KFrameHeight - 64-82-50);
    return 355 + self.webView_height +  self.productAbstractLabel.height;
    //    return 356 + [RrOrderListDetailCell getDetailLabelHightWithStr:self.productModel.Description];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    @weakify(self);
    RrOrderListDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:KRrOrderListDetailCell_ID forIndexPath:indexPath];
    if (self.productModel.pictures.count >0) {
        [cell.imageViews sd_setImageWithURL:[self.productModel.pictures.firstObject url] placeholderImage:KPlaceholderImage_product];
        [cell.imageViews handleTap:^(CGPoint loc, UIGestureRecognizer *tapGesture) {
            @strongify(self);
            [LXObjectTools selectedImageView:cell.imageViews ImageArray:self.productModel.pictures Index:0];
        }];
    }else{
        [cell.imageViews sd_setImageWithURL:self.productModel.cover.url placeholderImage:KPlaceholderImage_product];
    }
    
    cell.titleLabels.text = [NSString stringWithFormat:@"%@  %@",self.productModel.name,self.productModel.aliasName];
    cell.subLabel.text = self.productModel.productCode;
    cell.skuLabel.text = [NSString stringWithFormat:@"选择     %@ >",self.selectedSkuStr];
    cell.skuLabel.textColor = [UIColor blackColor];
    cell.skuLabel.keywords_arr = @[@"选择",@">"];
    cell.skuLabel.keywordsColor_arr = @[[UIColor c_GrayColor],[UIColor c_GrayColor]];
    [cell.skuLabel reloadUIConfig];
    cell.productAbstractLabel.hidden = checkStrEmty(self.productModel.productAbstract);
    cell.productAbstractLabel.text = [NSString stringWithFormat:@"%@%@",@"适应范围：",self.productModel.productAbstract];
    cell.productAbstractLabel.height = [cell.productAbstractLabel getLableHeightWithMaxWidth:cell.productAbstractLabel.width].size.height;
    self.productAbstractLabel = cell.productAbstractLabel;
    cell.priceLabel.text = self.productModel.productAbstract;
  
    [cell.skuLabel handleTap:^(CGPoint loc, UIGestureRecognizer *tapGesture) {
        @strongify(self);
        [self showBuyProductSKUView];
    }];
    
    cell.priceLabel.text = [NSString stringWithFormat:@"¥%@",self.price];
    cell.priceLabel.textColor = [@"#FF2A00" getColor];
    if (!self.webView && self.productModel.Description != nil) {
        cell.webView.top = cell.productAbstractLabel.bottom;
        self.webView = cell.webView;
        [cell.webView loadHTMLString:self.productModel.Description baseURL:nil];
        cell.webView.navigationDelegate = self;
    }
    
    return cell;
}
- (void)showBuyProductSKUView{
    
    
    @weakify(self)
    GoodsSKUViewController *cate = [[GoodsSKUViewController alloc]init];
    cate.productSKUModel = self.productModel;
    cate.minNumber = 1;
    cate.maxNumber = 9999;
    cate.imgUrl = self.productModel.cover;
    cate.allAttrIds = self.allAttrIds;
    cate.selectedNumber = self.number;
    cate.skuPrice = self.price;
    cate.productPrice = self.productModel.productPrice ;
    cate.confirmBlock = ^(NSArray<NSString*> *arrId, NSInteger number, NSString * selectedSkuStr,NSString *price) {
        @strongify(self)
        self.allAttrIds = arrId;
        self.number = number;
        self.selectedSkuStr = selectedSkuStr;
        self.price = price;
        [self.tableView reloadData];
        [self pushToRrPostOrderListDetailVC];
    };
    
    
    [cate showViewWithSuperVC:self];
}



- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    @weakify(self)
    [webView evaluateJavaScript:@"Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight)"
              completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        @strongify(self)
        if (!error) {
            NSNumber *height = result;
            webView.height = [height floatValue];
            self.webView_height = webView.height;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.tableView reloadData];
            });
            
        }
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark UI
- (UITableView *)tableView{
    if (!_tableView) {//UITableViewStyleGrouped
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KFrameWidth, KScreenHeight-64) style:UITableViewStylePlain];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 51;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [UIView new];
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor whiteColor];
        [_tableView addLine_left];
        [_tableView addLine_right];
    }
    return _tableView;
}

///产品详情
- (void)getProductDetailUrl{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    [[RRNetWorkingManager sharedSessionManager] getProductDetail:@{KKey_1:self.productModel.ID} result:ResultBlockMake(^(NSDictionary * _Nonnull dict, RrResponseModel * _Nonnull responseModel, NSError * _Nonnull error) {
        [SVProgressHUD dismiss];
        
        if (!error) {
            self.tableView.hidden = NO;
            self.bottomBtn.hidden = NO;
            self.notNetWorkView.hidden = YES;
            self.productModel = (RrOrderItemsListModel*)responseModel.item;
            if(checkStrEmty(self.productModel.minPrice) || checkStrEmty(self.productModel.maxPrice)){
                self.price = self.productModel.productPrice;
            }else{
                self.price = [NSString stringWithFormat:@"%@-%@",self.productModel.minPrice,self.productModel.maxPrice];
            }
            if(self.productModel.specificationsList.count == 0){
                self.selectedSkuStr = KSUKDefaultItemName;
            }
            [self.tableView reloadData];
        }else{
            [SVProgressHUD dismiss];
            self.bottomBtn.hidden = YES;
            self.tableView.hidden = YES;
            self.notNetWorkView.hidden = NO;
            showMessage(responseModel.msg);
        }
    }, [RrOrderItemsListModel class])];
}
- (void)dealloc
{
    [SVProgressHUD dismiss];
}

@end
