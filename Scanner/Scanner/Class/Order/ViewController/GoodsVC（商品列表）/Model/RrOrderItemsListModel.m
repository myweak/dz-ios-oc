//
//  RrOrderItemsListModel.m
//  Scanner
//
//  Created by edz on 2020/7/17.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "RrOrderItemsListModel.h"


@implementation RrOrderItemsListModel
@synthesize skuItemsID = _skuItemsID,productNum=_productNum,productPrice = _productPrice,cover = _cover,aliasName=_aliasName;
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
        @"ID":@"id",
        @"Description":@"description",
    };
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{
        @"skuList" : [RrSkuPriceListModel class],
        @"specificationsList" : [RrGoodsSKUModel class]
    };
}
- (NSString *)aliasName{
    if (checkStrEmty(_aliasName)) {
        _aliasName = @"";
    }
    return _aliasName;
}
- (NSNumber *)productNum{
    if(!_productNum || _productNum<0){
        return 0;
    }
    return _productNum;
}

//
- (NSString *)productPrice{
    
    return [NSString stringWithFormat:@"%.2f",[_productPrice floatValue]];
}

- (NSString *)cover{
    if (checkStrEmty(_cover)) {
        if(_pictures.count >0){
            _cover =  _pictures.firstObject;
        };
    }
    return  _cover;
}

/// 获取suk 价格 skuKey
- (NSString *)getSKUPriceWithKey:(NSString *) skuKey{
    NSString  *price = @"0";
    self.skuItemsID = nil;
    if(checkStrEmty(self.minPrice) || checkStrEmty(self.maxPrice)){
        price = self.productPrice;
    }else{
        price = [NSString stringWithFormat:@"%@-%@",[self.minPrice reviseStringMoney],[self.maxPrice reviseStringMoney]];
    }
    for (RrSkuPriceListModel *model in self.skuList) {
        if ([model.skuKey isEqualToString:skuKey]) {
            price = [model.price reviseStringMoney];
            self.skuItemsID = model.skuId;
            break;
        }
    }
    return price;
}

- (NSString *)skuItemsID{
    if (_specificationsList.count == 0 && _skuList.count >0) {
        RrSkuPriceListModel *model =  [_skuList firstObject];
        return model.skuId;
    }
    return _skuItemsID;
}


@end
