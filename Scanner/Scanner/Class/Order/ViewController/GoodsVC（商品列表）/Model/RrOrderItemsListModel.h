//
//  RrOrderItemsListModel.h
//  Scanner
//
//  Created by edz on 2020/7/17.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RrGoodsSKUModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface RrOrderItemsListModel : NSObject

@property (nonatomic, copy)   NSString *ID; // 主键
@property (nonatomic, copy)   NSString *name; // 商品名称
@property (nonatomic, copy)   NSString *productCode;// 产品编码
@property (nonatomic, strong) NSNumber *status;//产品状态：1：上架，0:下架
///产品价格-->最低
@property (nonatomic, copy)   NSString *productPrice;

@property (nonatomic, copy)   NSString *productAbstract;//适应病症-商品简介
@property (nonatomic, copy)   NSString *Description;//产品描述
@property (nonatomic, copy)   NSString *cover; // 图片cover的url
/// 图片Icon，List的url ,取第一个
@property (nonatomic, strong) NSArray<NSString *> *pictures;
/// 产品品名
@property (nonatomic, copy)   NSString *aliasName;

@property (nonatomic, strong) NSNumber *payType;//支付方式:0 全部 1在线支付，2线下支付
@property (nonatomic, strong) NSNumber *type;//支付方式:0 全部 1在线支付，2线下支付





//--------- 详情 ----------
///最低价
@property (nonatomic, copy)   NSString *minPrice;
///最高价
@property (nonatomic, copy)   NSString *maxPrice;

 /// sku 价格-->查询
@property (nonatomic, strong) NSArray<RrSkuPriceListModel *>  *skuList;
///商品sku
@property (nonatomic, strong) NSArray<RrGoodsSKUModel *> *specificationsList;

/// 获取suk 价格 skuKey
- (NSString *)getSKUPriceWithKey:(NSString *) skuKey;




///自定义属性
@property (nonatomic, copy)   NSString *productSkuPrice;//产品SKU价格
@property (nonatomic, copy)   NSNumber *maxNumber; // 最大商品数量
@property (nonatomic, copy)   NSNumber *productNum; // 商品数量
@property (nonatomic, copy)   NSString *skuString; // 商品属性
/// 用户选中的 skuid
@property (nonatomic, copy)   NSString *skuItemsID; // Sku id








@end

NS_ASSUME_NONNULL_END
