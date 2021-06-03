//
//  GoodsSKUViewController.h
//  Scanner
//
//  Created by xiao on 2021/4/6.
//  Copyright © 2021 rrdkf. All rights reserved.
//

#define KSUKDefaultItemName @"默认"

#import "MainViewController.h"
#import "RrOrderItemsListModel.h"
#import "RrOrderItemsListModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^RetailCloseBlock)(void);


/**
 <#Description#>

 @param arrId 下单选中的规格id
 @param number 下单数量
 @param selectedSkuStr 选中的规格描述
 */
typedef void (^RetailConfirmBlock)(NSArray<NSString*> *arrId, NSInteger number,NSString * selectedSkuStr,NSString *price);


@interface GoodsSKUViewController : MainViewController


@property (nonatomic, copy) RetailCloseBlock closeBlock;

@property (nonatomic, copy) RetailConfirmBlock confirmBlock;

@property (nonatomic, strong) RrOrderItemsListModel  *productSKUModel;


///最小购买数量
@property (nonatomic, assign) NSInteger minNumber;

/// 最大购买数量
@property (nonatomic, assign) NSInteger maxNumber;

//选择 id
@property (nonatomic, strong) NSArray *allAttrIds;

/// 选择数量
@property (nonatomic, assign) NSInteger selectedNumber;

/// 图片
@property (nonatomic, copy) NSString * imgUrl;
/// sku价格
@property (nonatomic, copy) NSString * skuPrice;

/// 商品默认价格
@property (nonatomic, copy) NSString *  productPrice;

- (void)showViewWithSuperVC:(UIViewController *)superVC;

/// 测试数据
+ (NSDictionary *)getData;
@end


NS_ASSUME_NONNULL_END
