//
//  RrGoodsSKUModel.h
//  Scanner
//
//  Created by xiao on 2021/4/7.
//  Copyright © 2021 rrdkf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/// SKU 价格 model
@interface RrSkuPriceListModel : NSObject
@property (nonatomic, copy)   NSString *price; // 价格
@property (nonatomic, copy)   NSString *skuId; // 主键Id
@property (nonatomic, copy)   NSString *skuKey; // 查询 key
/// 自定义


@end

///3
@interface RrGoodsSKUAttrModel : NSObject
@property (nonatomic, copy)   NSString *ID; // 主键Id
@property (nonatomic, copy)   NSString *name; // 分类名称
@end

///2
@interface RrGoodsSKUModel : NSObject
@property (nonatomic, copy)   NSString *ID; // 主键Id
@property (nonatomic, copy)   NSString *name; // 分类名称
@property (nonatomic, strong) NSArray<RrGoodsSKUAttrModel *> *items;
@end


NS_ASSUME_NONNULL_END
