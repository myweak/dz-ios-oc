//
//  RrDidProductDeTailModel.h
//  Scanner
//
//  Created by edz on 2020/7/20.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//下单后的商品订单详情模型
@interface RrDidProductDeTailModel : NSObject
//订单前
@property (nonatomic, strong) NSNumber *payType;//支付方式:0 全部 1在线支付，2线下支付
@property (nonatomic, strong) NSNumber *productPayType;//支付方式:0 全部 1在线支付，2线下支付
@property (nonatomic, copy)   NSString *patientPhone;//用户手机
@property (nonatomic, copy)   NSString *patientName;//用户姓名
@property (nonatomic, copy)   NSString *addrId;//工作人员地址 id
@property (nonatomic, copy)   NSString *attachment;//附件,逗号分割
//3d打印附件（用‘，’隔开）格式@"imageUrl1,zipUrl1,imageUrl2,zipUrl2,……"
@property (nonatomic, copy)   NSString *otherAttachment; //3d打印附件
@property (nonatomic, copy)   NSString *productId;//产品主键
@property (nonatomic, copy)   NSString *remark;//订单备注
@property (nonatomic, copy)   NSString *payImg;//支付凭证，多个逗号分隔
///用户实际需要支付的金额
@property (nonatomic, copy)   NSString *AactualReceipts;

///单个商品SKU 的价格
@property (nonatomic, copy)   NSString *productPrice;

@property (nonatomic, assign) BOOL remindShipSwitch;///提醒发货按钮是否可按 true 可以 false 不可以
@property (nonatomic, assign) BOOL remindPaySwitch;///提醒支付按钮是否可按 true 可以 false 不可以
@property (nonatomic, strong) NSNumber *productType; ///我的订单详情 产品属性  1 定制  2普通 默认1
@property (nonatomic, strong) NSNumber *type; ///产品属性  1 定制  2普通 默认1


////订单后
@property (nonatomic, copy)   NSString *outTradeNo;//订单编号
@property (nonatomic, copy)   NSString *expressRemark;//快递备注
///订单总金额
@property (nonatomic, copy)   NSString *totalFee;
///    0 取消支付 1 待支付 2 待审核 3待完善 4 加工分配 5 制作中 6 制作完成 7 待发货 8待收货 9 已完成
@property (nonatomic, copy)   NSNumber *orderStatus;//订单状态
@property (nonatomic, copy)   NSString *doctorUserId;//医生ID
@property (nonatomic, copy)   NSString *trackingNumber;//快递单号
@property (nonatomic, copy)   NSString *express;//快递公司
@property (nonatomic, copy)   NSString *paymentType;//快递备注
@property (nonatomic, copy)   NSString *doctorName;//工作人员名字
@property (nonatomic, copy)   NSString *doctorPhone;//工作人员号码
@property (nonatomic, copy)   NSString *agentId;//经销商id
@property (nonatomic, copy)   NSString *partnerId;//加工商id
@property (nonatomic, copy)   NSString *transactionId;//交易编号
@property (nonatomic, copy)   NSString *createTime;//订单创建时间
@property (nonatomic, copy)   NSString *partnerName;//加工商名字
@property (nonatomic, copy)   NSString *agentName;//经销商名字
@property (nonatomic, copy)   NSString *agentPhone;//经销商手机号

@property (nonatomic, copy)   NSString *productName;//商品名称
@property (nonatomic, copy)   NSString *productIcon;//商品图片
@property (nonatomic, copy)   NSString *productCode;//商品代号
@property (nonatomic, copy)   NSString *expressTime;//发货时间
@property (nonatomic, copy)   NSString *rejectReason;//驳回原因
@property (nonatomic, copy)   NSString *doctorAddr;//收货地址
@property (nonatomic, copy)   NSString *payTime; //支付时间
@property (nonatomic, copy)   NSString *productAbstract;//适应病症
@property (nonatomic, copy)   NSString *completeTime; //收货时间
@property (nonatomic, copy)   NSString *reviewTime; //待审核---》审核时间


///商品别名
@property (nonatomic, copy)   NSString *aliasName;


///商品 数量
@property (nonatomic, copy)   NSString *productNum;
///商品SKU List
@property (nonatomic, copy) NSString *specifications;




// ----
///商品SKU String
@property (nonatomic, copy)   NSString *skuString;
@property (nonatomic, copy)   NSString *orderStatus_Str;//订单状态 str
@property (nonatomic, copy) NSString *payTypeStr;

/// 提醒支付 进入倒计时
@property (nonatomic, assign) BOOL timePut;


/// 计算 高度 RrOrderDetailEditCell reMarkLabel
@property (nonatomic, assign) CGFloat reMarkLabel_H;

@end

NS_ASSUME_NONNULL_END
