//
//  RrMineOrderMianListVC.m
//  Scanner
//
//  Created by edz on 2020/7/27.
//  Copyright © 2020 rrdkf. All rights reserved.
//

#import "RrMineOrderMianListVC.h"
#import "LXScrollView.h"
#import "RrMineOrderListVC.h" // 订单列表
#import "RrOrderSearchVC.h"
#import "JSBadgeView.h"
@interface RrMineOrderMianListVC ()<LXScrollViewDelegate,LXScrollViewDataSource>
@property (nonatomic, strong) LXScrollView *sortView;
@property (nonatomic, strong) NSMutableArray *listVC;
@property (nonatomic, strong) NSArray<NSString *> *titleArr;
@property (nonatomic, strong) NSMutableArray *badgeArr;
@property (nonatomic, strong) NSArray<NSString *> *orderStatusArr;

@end

@implementation RrMineOrderMianListVC

- (void)dealloc{
    self.sortView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.hidenLeftTaBar = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];    
    self.title = @"订单";
   
   self.badgeArr = [NSMutableArray arrayWithArray:@[
       @"0",
       @"0",
       @"0",
       @"0",
       @"0",
       @"0",
   ]];
    self.titleArr = @[
        @"全部",
        @"待付款",
        @"待完善",
        @"待发货",
        @"待收货",
        @"已完成"
    ];
    // titleArr  item 对应的状态id
    ///全部：不传值  1 待支付  3待完善   7 待发货  8待收货  9 已完成
   self.orderStatusArr = @[
        @"-111",
        @"1",
        @"3",
        @"7",
        @"8",
        @"9",
    ];
    @weakify(self)
    [self.titleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        RrMineOrderListVC *listVc = [[RrMineOrderListVC alloc]init];
        [self addChildViewController:listVc];
        if (idx != 0) {
            listVc.orderStatus = self.orderStatusArr[idx];
        }
        [self.listVC addObject:listVc];
    }];
    
    [self.view addSubview:self.sortView];
    self.sortView.selectItemIndex = 0;
    [self updateSortViewNumUrl];
    [self.sortView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSortViewNumUrl) name:KNotificationUpdataOrderNum object:nil];
    
    //搜索
     [self addNavigationButtonImageRight:@"navi_search_icon" RightActionBlock:^{
         @strongify(self);
         RrOrderSearchVC *searVc =[RrOrderSearchVC new];
         searVc.type = RrSearchVCType_order;
         searVc.showPayNotifiBlock = ^(RrMineOrderListModel * model) {
             
         };
         [self.navigationController pushViewController:searVc animated:YES];
     }];


}
- (void)addBackButton{
}

- (NSMutableArray *)listVC{
    if (!_listVC) {
        _listVC = [NSMutableArray array];
    }
    return _listVC;
}

- (LXScrollView *)sortView{
    if (!_sortView) {
        _sortView = [[LXScrollView alloc]initWithFrame:CGRectMake(0, 0, KFrameWidth, KScreenHeight) andBarWidth:KFrameWidth];
        _sortView.delegate = self;
        _sortView.dataSource = self;
        _sortView.type = LXScrollViewItemWidthType_equalAll;
    }
    return _sortView;
}
-(UIView *)gsSortViewTitlesView:(UIView *)titleView viewForIndex:(NSInteger)index
{
    NSString *title = self.titleArr[index];
    JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:titleView alignment:JSBadgeViewAlignmentTopCenter];
    badgeView.badgeText = self.badgeArr[index];
    CGFloat x =  title.length * 12;
    badgeView.badgePositionAdjustment = CGPointMake(x, 13);
    badgeView.badgeBackgroundColor = [UIColor whiteColor];
    badgeView.badgeTextColor = [UIColor redColor];
    badgeView.badgeStrokeColor= [UIColor redColor];
    badgeView.badgeStrokeWidth =1;
    badgeView.hidden = [self.badgeArr[index] intValue ]<=0;
    return  badgeView;
}
- (NSArray <NSString *>*)gsSortViewTitles{
    return self.titleArr;
}
- (UIView *)gsSortView:(LXScrollView *)sortView viewForIndex:(NSInteger)index{
    RrMineOrderListVC *listVc = self.listVC[index];
    return listVc.view;
}
/** 点击分选框标题
*  index 0~titles.count-1
*/
- (void)gsSortViewDidScroll:(NSInteger)index{
    NSLog(@"click ======== %ld",index);
   
    RrMineOrderListVC *listVc = self.listVC[index];
    [listVc.tableView.mj_header beginRefreshing];
    
}

-(void)updateSortViewNumUrl{
    @weakify(self);
    [[RRNetWorkingManager sharedSessionManager] getOrderStatasNumber:nil result:ResultBlockMake(^(NSDictionary * _Nonnull dict, RrResponseModel * _Nonnull responseModel, NSError * _Nonnull error) {
        @strongify(self);
        NSDictionary *dataDict =  responseModel.data;
//        if (dataDict == nil) {
            self.badgeArr = [NSMutableArray arrayWithArray:@[
                @"0",
                @"0",
                @"0",
                @"0",
                @"0",
                @"0",
            ]];
//            [self.sortView reloadData];
//            return;
//        }
        NSArray *allKeys = dataDict.allKeys;
        allKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSComparisonResult result = [obj1 compare:obj2];
        return result==NSOrderedDescending;
        }];
       
        for (int i = 0; i<self.orderStatusArr.count; i++) {
           NSString * obj = self.orderStatusArr[i];
            for (NSString *key in allKeys) {
                if ([key isEqualToString:obj]) {
                    NSString *badge = [NSString stringWithFormat:@"%@",[dataDict valueForKey:key]];
                    if ([badge intValue]>99) {
                        badge = @"99+";
                    }
                    [self.badgeArr replaceObjectAtIndex:i withObject:badge];
                }
            }
        }
     
        [self.sortView reloadData];
        
    }, nil)];
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
