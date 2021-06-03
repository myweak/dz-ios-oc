//
//  GoodsSKUViewController.m
//  Scanner
//
//  Created by xiao on 2021/4/6.
//  Copyright © 2021 rrdkf. All rights reserved.
//

#import "GoodsSKUViewController.h"
#import "NSString+MyString.h"
#import "SKTagView.h"

@interface GoodsSKUViewController ()< UITextFieldDelegate,UIScrollViewDelegate>

/// 图片
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
///价格
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
///选择规格
@property (weak, nonatomic) IBOutlet UILabel *selectedTagLabel;

/// 存放规格tag View
@property (weak, nonatomic) IBOutlet UIView *retailCateView;
/// 存放规格 scrollerView
@property (weak, nonatomic) IBOutlet UIScrollView *scrollerView;
///scrollerView 。view 的高度 《规格+数量》View
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollerViewHeightConstraint;
/// 存放规格tag View height
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retailCateHeightConstaint;
///白色内容view，不包括灰色背景
@property (weak, nonatomic) IBOutlet UIView *containerView;
/// 确定 提交规格选择
@property (weak, nonatomic) IBOutlet UIButton *sureButton;

/**
 取消弹框
 */
- (IBAction)didHitClose:(id)sender;

/**
 确定 提交规格选择 事件
 */
- (IBAction)didHitConfirmBlock:(id)sender;

/// 选中item的模型ID
@property (nonatomic, strong) NSMutableArray *allIds;

@property (nonatomic, strong) NSMutableArray *allTagViews;

/// 数量textField
@property (weak, nonatomic) IBOutlet UITextField *textField;

///库存数量
@property (nonatomic, assign) NSInteger avaliableCount;

@property (nonatomic,weak)UIViewController * superVC;

@property (nonatomic,strong) NSString * selectedTagStr;

///减少数量 按钮 ----
@property (weak, nonatomic) IBOutlet UIButton *minorBtn;
///添加数量 按钮 +++
@property (weak, nonatomic) IBOutlet UIButton *majorBtn;

/// 选中的sku id
@property (nonatomic,copy) NSString *skuItemsID;


@end

@implementation GoodsSKUViewController

/// 默认SUK
+ (NSArray *)getDefaultSUK{
    NSArray *arr = @[@{
                         @"name":@" 规格",
                         @"id":@(-1),
                         @"items":@[@{@"name":KSUKDefaultItemName,@"id":@(-1)}],
    },
    ];
    return arr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollerView.showsVerticalScrollIndicator = NO;
    self.scrollerView.showsHorizontalScrollIndicator = NO;
    
    [self.sureButton setTitle:@"确定" forState:UIControlStateNormal];
    
    [self.sureButton setTitle:@"缺货中" forState:UIControlStateDisabled];
    [self.sureButton setBackgroundImage:[UIImage imageWithColor:[@"#E5E5E5" getColor]] forState:UIControlStateDisabled];
    
    
    //当没有规格时，均码规格的最大库存为该商品的最大库存
    self.avaliableCount = self.maxNumber;
    
    WEAKSELF
    [self.view handleTap:^(CGPoint loc, UIGestureRecognizer *tapGesture) {
        if (!CGRectContainsPoint(weakSelf.containerView.frame, loc)) {
            [weakSelf didHitClose:nil];
        }
    }];
    [self.containerView handleTap:^(CGPoint loc, UIGestureRecognizer *tapGesture) {
        [weakSelf.view endEditing:YES];
    }];
    
    self.productImageView.layer.cornerRadius = 6;
    self.productImageView.layer.masksToBounds = YES;
    [self.productImageView sd_setImageWithURL:self.imgUrl.url placeholderImage:KPlaceholderImage_product];
    [self.productImageView handleTap:^(CGPoint loc, UIGestureRecognizer *tapGesture) {
        
    }];
    
    
    self.selectedTagLabel.text = @"请选择规格";
    
    
    self.allIds = [NSMutableArray arrayWithCapacity:0];
    if (self.selectedNumber == 0) {
        self.selectedNumber = 1;
    }
    
    self.textField.delegate = self;
    self.textField.text = [NSString stringWithFormat:@"%zi",self.selectedNumber];
    
    if (self.allAttrIds.count) {
        self.allIds = [NSMutableArray arrayWithArray:self.allAttrIds];
    }
    [self addTags];
    
    self.minorBtn.enabled = self.selectedNumber > self.minNumber;
    self.majorBtn.enabled = self.selectedNumber < MIN(self.maxNumber, self.avaliableCount);
    
    
    ///键盘监听-----------------------
    　　 //将要显示键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    //将要隐藏键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}



- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/// 键盘将要显示键盘
- (void)willShowKeyboard:(NSNotification *)notify{
    self.view.top = -310;
    CGPoint bottomOffset = CGPointMake(0, self.scrollerView.contentSize.height - self.scrollerView.bounds.size.height);
    [self.scrollerView setContentOffset:bottomOffset animated:YES];
}
//将要隐藏键盘
- (void)willHideKeyboard:(NSNotification *)notify{
    self.view.top = 0;
    
}

#pragma  mark get

- (NSInteger)minNumber
{
    if(_minNumber<1) return 1;
    return  _minNumber;
}
- (NSInteger)maxNumber
{
    if(_maxNumber<2) return 2;
    return  _maxNumber;
}
- (NSInteger)selectedNumber
{
    if(_selectedNumber<=0) return 1;
    return  _selectedNumber;
}

-(NSString *)skuPrice{
    if(checkStrEmty(_skuPrice)) return @"0";
    return _skuPrice;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    return [self shouldChangeNumber];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    BOOL match = [text matchPattern:@"^[0-9]{0,9}$"];
    if (match) {
        self.minorBtn.enabled = text.integerValue > self.minNumber;
        self.majorBtn.enabled = text.integerValue < MIN(self.maxNumber, self.avaliableCount);
        return [self shouldMaxGoodsNumber:text.integerValue];
    }
    return match;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    NSString *text = textField.text;
    
    if (text.doubleValue <= 0) {///不存在
        [iToast showCenter_ToastWithText:@"购买数量必须是正整数" superview:self.view];
        self.selectedNumber = 1;
        self.textField.text = @(self.selectedNumber).stringValue;
    }
    self.selectedNumber = text.integerValue;
    self.minorBtn.enabled = self.selectedNumber > self.minNumber;
    self.majorBtn.enabled = self.selectedNumber <  MIN(self.maxNumber, self.avaliableCount);
    
    return YES;
}


- (BOOL)shouldMaxGoodsNumber:(NSInteger)selectedNumber{
    
    NSInteger maxNumber = self.maxNumber;
    if (selectedNumber <= 0 || maxNumber <=0) {
        return YES;
    }
    if (selectedNumber > maxNumber) {
        [iToast showCenter_ToastWithText:[NSString stringWithFormat:@"单次最大购买数量为%ld件",(long)maxNumber] superview:self.view];
        self.selectedNumber = maxNumber;
        self.textField.text = [NSString stringWithFormat:@"%ld",(long)maxNumber];
        self.majorBtn.enabled = NO;
        return NO;
    }
    return YES;
}

- (BOOL)shouldChangeNumber {
    
    NSMutableArray *keys = [self checkHaveUnsetedProperty];
    BOOL hasUnset = keys.count;
    if (hasUnset) {
        [iToast showCenter_ToastWithText:[NSString stringWithFormat:@"请选择%@",keys.firstObject] superview:self.view];
    }
    return !hasUnset;
}

#pragma mark - 更新商品价格
///更新商品价格
- (void)updateProductPrice{
    ///序列化 self.allIds 的顺序
    __autoreleasing NSMutableArray *orderAllIds = [NSMutableArray arrayWithCapacity:0];
    for (RrGoodsSKUModel *attrModel in self.productSKUModel.specificationsList) {
        for (RrGoodsSKUAttrModel *itemModel in attrModel.items) {///  SKU items
            for (NSString *attrId in self.allIds) {
                if ([itemModel.ID isEqualToString:attrId]) {
                    [orderAllIds addObject:attrId];
                    break;
                }
            }
        }
    }
    self.allIds = orderAllIds;
    //    self.skuPrice = self.productPrice;
    //    self.priceLabel.text = [NSString stringWithFormat:@"¥ %@",self.productPrice];
    NSString *key = [self.allIds componentsJoinedByString:@""];
    self.skuPrice = [self.productSKUModel getSKUPriceWithKey:key] ;
    self.priceLabel.text = [NSString stringWithFormat:@"¥ %@",self.skuPrice];
    
    
    
}


#pragma mark - Actions

///减少 --
- (IBAction)didHitMinor:(id)sender {
    
    if (![self shouldChangeNumber]) {
        return;
    }
    
    NSInteger number = MAX(1, self.textField.text.integerValue - 1);
    self.minorBtn.enabled = number > self.minNumber;
    self.majorBtn.enabled = number < MIN(self.maxNumber, self.avaliableCount);
    if (number > self.maxNumber) {
        [iToast showCenter_ToastWithText:@"库存不足" superview:self.view];
        self.selectedNumber = number;
        return;
    }
    
    if (number > self.avaliableCount) {
        self.selectedNumber = number;
        [iToast showCenter_ToastWithText:@"库存不足" superview:self.view];
        return;
    }
    
    number = MAX(self.minNumber, number);
    
    self.selectedNumber = number;
    
    self.textField.text = [NSString stringWithFormat:@"%zi",number];
    
}
/// 添加数量 ++
- (IBAction)didHitMajor:(id)sender {
    
    if (![self shouldChangeNumber]) {
        return;
    }
    
    NSInteger number = MAX(1, self.textField.text.integerValue + 1);
    self.minorBtn.enabled = number > self.minNumber;
    self.majorBtn.enabled = number < MIN(self.maxNumber, self.avaliableCount);
    if (number > self.maxNumber) {
        [iToast showCenter_ToastWithText:@"库存不足" superview:self.view];
        self.selectedNumber = MAX(1, self.textField.text.integerValue);
        return;
    }
    
    if (number > self.avaliableCount) {
        [iToast showCenter_ToastWithText:@"库存不足" superview:self.view];
        self.selectedNumber = MAX(1, self.textField.text.integerValue);
        return;
    }
    
    // 判断最大下单量
    if (![self shouldMaxGoodsNumber:number]) { // 超过最大
        return;
    };
    
    
    if (self.maxNumber > 0) {
        number = MIN(number, self.maxNumber);
    }
    
    self.selectedNumber = number;
    self.textField.text = [NSString stringWithFormat:@"%zi",number];
}

- (IBAction)didHitClose:(id)sender {
    
    [self.view endEditing:YES];
    
    if (self.closeBlock) {
        self.closeBlock();
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.view.top = KScreenHeight;
        UIView * backView = [self.superVC.view viewWithTag:84372];
        if (backView) {
            backView.backgroundColor = [@"000000" getColorWithAlpha:0];
        }
        
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        
        [self removeSelfFramSuperVC];
        
    }];
}
#pragma mark 确定按钮
- (IBAction)didHitConfirmBlock:(id)sender {
    
    NSMutableArray *keys = [self checkHaveUnsetedProperty];
    if (keys.count) {
        [iToast showCenter_ToastWithText:[NSString stringWithFormat:@"请选择%@",keys.firstObject] superview:self.view];
    } else {
        

        if (![self isHadProductNumber]) {
            showMessage(@"当前商品规格没有库存");
            return;
        }
        
        NSInteger number = self.textField.text.integerValue;
        if (number < self.minNumber || number > MIN(self.maxNumber, self.avaliableCount)){
            [iToast showCenter_ToastWithText:@"库存不足" superview:self.view];
            self.selectedNumber = self.minNumber;
            self.textField.text = [NSString stringWithFormat:@"%zi",self.selectedNumber];
            return;
        }
        
        [self didHitClose:nil];
        
        
        if (self.confirmBlock) {
            NSLog(@"allIds:%@,selectedNumber:%ld,selectedTagStr:%@",[self.allIds componentsJoinedByString:@","],(long)self.selectedNumber,self.selectedTagStr);
            self.confirmBlock(self.allIds, self.selectedNumber, self.selectedTagStr,self.skuPrice);
        }
    }
}

/**
 检查是否有未选择的属性
 
 @return Bool
 */
- (NSMutableArray *)checkHaveUnsetedProperty {
    
    NSMutableArray *unsetedCates = [NSMutableArray arrayWithCapacity:0];
    for (RrGoodsSKUModel *attrModel in self.productSKUModel.specificationsList) {
        BOOL hasId = NO;
        for (RrGoodsSKUAttrModel *itemModel in attrModel.items) {
            for (NSString *attrId in self.allIds) {
                if ([itemModel.ID isEqualToString:attrId ]) {
                    hasId = YES;
                    break;
                }
            }
        }
        if (!hasId) {
            [unsetedCates addObject:attrModel.name];
        }
        
    }
    
    return unsetedCates;
}


- (void)reloadTags {
    
    ///   价格
    [self updateProductPrice];
    
    //    //选中的规格文本
    NSMutableString * selectedTagStr = [NSMutableString string];
    NSMutableArray * selectedTagStrArr = [NSMutableArray array];
    for (SKTagView *tagView in self.allTagViews) {
        for (SKTag *tag in tagView.tags) {
            RrGoodsSKUAttrModel *itmeModel = tag.obj;
            if ([self.allIds containsObject:itmeModel.ID]) {
                
                tag.tagButton.selected = YES;
                //拼接选中的规格文本
                //                [selectedTagStr appendFormat:@"%@",tag.text];
                [selectedTagStrArr addObject:tag.text];
                [tag.tagButton addLindeBorderWithColor:[UIColor c_btn_Bg_Color] andRadius:3];
                
            } else {
                tag.tagButton.selected = NO;
                [tag.tagButton addLindeBorderWithColor:[@"#F0F0F0" getColor] andRadius:3];
                
            }
            
            /// 设置 无SUK时默认数据
            if([itmeModel.ID isEqualToString:@"-1"] && [itmeModel.name containsString:KSUKDefaultItemName]){
                tag.tagButton.selected = YES;
                //拼接选中的规格文本
                //                [selectedTagStr appendFormat:@"%@",tag.text];
                [selectedTagStrArr addObject:tag.text];
                [tag.tagButton addLindeBorderWithColor:[UIColor c_btn_Bg_Color] andRadius:3];
                
            }
        }
    }
 
    if (![self isHadProductNumber]) {
      
        showMessageWithDuration(@"当前商品规格没有库存",700);

    }
    
    if (selectedTagStrArr.count == 0) {
        if (self.allTagViews.count == 0) {
            [selectedTagStr appendString:[NSString stringWithFormat:@"%@%@",@"规格：",KSUKDefaultItemName]];
            _selectedTagStr = KSUKDefaultItemName;
        }else{
            [selectedTagStr appendString:@"请选择规格"];
            _selectedTagStr = @"";
        }
    }else{
        selectedTagStr = [NSMutableString stringWithString:[selectedTagStrArr componentsJoinedByString:@"/"]];
        //去除末尾的两个空格
        //        [selectedTagStr deleteCharactersInRange:NSMakeRange(selectedTagStr.length - 2, 2)];
        _selectedTagStr = selectedTagStr;
        selectedTagStr = [NSMutableString stringWithFormat:@"已选：“%@”",selectedTagStr];
    }
    
    NSInteger number = self.textField.text.integerValue;
    
    self.selectedTagLabel.text = selectedTagStr;
    
    
    
    
    //动画（self.commissionLabel高度变化）
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    self.minorBtn.enabled = number > self.minNumber;
    self.majorBtn.enabled = number < MIN(self.maxNumber, self.avaliableCount);
}


///判断该商品suk是否有 YES:有
- (BOOL) isHadProductNumber{
    BOOL isHadSkuKey = YES;
    if(self.productSKUModel.specificationsList.count == self.allIds.count && self.allIds.count>0){
        NSString *skuKey = [self.allIds componentsJoinedByString:@""];
        isHadSkuKey = NO;
        for (RrSkuPriceListModel *model in self.productSKUModel.skuList) {
            if ([model.skuKey isEqualToString:skuKey]) {
                isHadSkuKey = YES;
                break;
            }
        }
    }
    return isHadSkuKey;
}



/**
 默认选中第一个，
 */
- (void)defaultSelectedTag{
    NSLog(@"默认选择商品");
    [self reloadTags];
}
#pragma  mark -规格item布局
- (void)addTags {
    //
    self.allTagViews = [NSMutableArray arrayWithCapacity:0];
    //
    CGFloat cateHeight = 0.0;
    
    NSArray *  titleArr = self.productSKUModel.specificationsList;
    if(titleArr.count == 0){
        titleArr  = [RrGoodsSKUModel mj_objectArrayWithKeyValuesArray:[GoodsSKUViewController getDefaultSUK]];
    }
    
    for (NSInteger i = 0; i < titleArr.count; i ++) {
        RrGoodsSKUModel *itemModel = titleArr[i];
        NSArray *itmeArr = itemModel.items;
        
        /// 标题
        RrGoodsSKUModel *titleModel = titleArr[i];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, cateHeight, KScreenWidth - 20 * 2, 50)];
        titleLabel.text = titleModel.name;
        titleLabel.textColor = [@"#231816" getColor];
        titleLabel.font = KFont18;
        [self.retailCateView addSubview:titleLabel];
        [titleLabel addLine_top];
        //
        cateHeight = CGRectGetMaxY(titleLabel.frame) + 5;
        // 父类View
        SKTagView *tagView = [[SKTagView alloc]init];
        
        tagView.obj = itemModel;
        tagView.preferredMaxLayoutWidth = self.view.width - 20 * 2;
        tagView.padding = UIEdgeInsetsMake(0, 0, 0, 0);
        tagView.interitemSpacing = 15;
        tagView.lineSpacing = 14;
        //        tagView.backgroundColor = [UIColor redColor];
        [self.allTagViews addObject:tagView];
        
        WEAKSELF
        __weak typeof(tagView) weakTagView = tagView;
        
        tagView.didTapTagAtIndex = ^(NSUInteger index) {
            RrGoodsSKUAttrModel *attrModel = itmeArr[index];
            
            weakSelf.selectedNumber = 1;
            weakSelf.textField.text = @(1).stringValue;
            
            SKTag *tag = [weakTagView.tags objectAtIndex:index];
            
            BOOL selected = !tag.tagButton.selected;
            tag.tagButton.selected = selected;
            
            if (selected) {
                for (RrGoodsSKUAttrModel *attrM in itmeArr) {
                    [weakSelf.allIds removeObject: attrM.ID];
                }
                [weakSelf.allIds addObject: attrModel.ID];
                
            }else {
                [weakSelf.allIds removeObject: attrModel.ID];
            }
            [weakSelf reloadTags];
        };
        // 商品属性 itmes布局
        ///itmeArr--> RrGoodsSKUAttrModel
        [itmeArr enumerateObjectsUsingBlock:^(RrGoodsSKUAttrModel * obj, NSUInteger idx, BOOL *stop) {
            //
            ///值 name
            SKTag *tag = [SKTag tagWithText:obj.name];
            
            tag.obj = obj;
            tag.textColor =  [@"#231816" getColor];
            tag.fontSize = 14;
            tag.padding = UIEdgeInsetsMake(10, 20, 10, 20);
            tag.cornerRadius = 1;
            tag.bgImg = [UIImage imageWithColor:[UIColor clearColor]];
            tag.enable = YES;
            //
            
            // 布局 tagButton； tag ->tagButton 并将 SKTag 添加到tags
            [tagView addTag:tag];
            
            // non
            [tag.tagButton setBackgroundImage:[UIImage imageWithColor:[@"#F0F0F0" getColorWithAlpha:1]] forState: UIControlStateNormal];
            // 选择
            [tag.tagButton setTitleColor:[UIColor c_btn_Bg_Color] forState:UIControlStateSelected];
            [tag.tagButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState: UIControlStateSelected];
            tag.tagButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            tag.tagButton.imageView.clipsToBounds = YES;
            [tag.tagButton setTitleColor:[@"#A0A0A0" getColorWithAlpha:1] forState:UIControlStateDisabled];
            [tag.tagButton setBackgroundImage:[UIImage imageWithColor:[@"#F7F8F9" getColorWithAlpha:1]] forState: UIControlStateDisabled];
            
        }];
        tagView.frame = CGRectMake(0, cateHeight, self.view.width - 40 * 2, tagView.intrinsicContentSize.height);
        cateHeight = CGRectGetMaxY(tagView.frame) + 20;
        [self.retailCateView addSubview:tagView];
    }
    self.retailCateHeightConstaint.constant = cateHeight;
    
    //containerView最大高度400
    CGFloat scrollerViewHeightMax = iPH(400);
    if (cateHeight > 0) {
        //        CGFloat scrollerViewHeight = cateHeight + 145 + 10;
        //        if (scrollerViewHeight > scrollerViewHeightMax) {
        //            scrollerViewHeight = scrollerViewHeightMax;
        //        }
        self.scrollerView.scrollEnabled = YES;
        self.scrollerViewHeightConstraint.constant = scrollerViewHeightMax;
    }
    
    [self reloadTags];
    
    //设置默认选中第一个
    //    [self defaultSelectedTag];
    
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)showViewWithSuperVC:(UIViewController *)superVC{
    _superVC = superVC;
    
    UIView * backView = [[UIView alloc] initWithFrame:superVC.view.bounds];
    backView.backgroundColor = [@"000000" getColorWithAlpha:0];
    backView.tag = 84372;
    [superVC.view addSubview:backView];
    [backView addSubview:self.view];
    [superVC addChildViewController:self];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.frame = backView.frame;
    self.view.top = KScreenHeight;
    
    WEAKSELF
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.view.top = 0;
        backView.backgroundColor = [@"000000" getColorWithAlpha:0.6];
    }];
    
}

- (void)removeSelfFramSuperVC{
    if (!_superVC) {
        return;
    }
    
    UIView * backView = [_superVC.view viewWithTag:84372];
    if (backView) {
        [backView removeFromSuperview];
    }
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

