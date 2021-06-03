//
//  RrGoodsSKUModel.m
//  Scanner
//
//  Created by xiao on 2021/4/7.
//  Copyright © 2021 rrdkf. All rights reserved.
//

#import "RrGoodsSKUModel.h"

@implementation RrGoodsSKUModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id"};
}
+ (NSDictionary *)mj_objectClassInArray{
    return @{ @"items" : [RrGoodsSKUAttrModel class]};
}
@end

@implementation RrGoodsSKUAttrModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id"};
}

@end


@implementation RrSkuPriceListModel

@end
