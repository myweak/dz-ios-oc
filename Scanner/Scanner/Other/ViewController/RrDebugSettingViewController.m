//
//  RrDebugSettingViewController.m
//  Scanner
//
//  Created by xiao on 2021/4/29.
//  Copyright © 2021 rrdkf. All rights reserved.
//
#define KDevOpen      @"调试模式"

#define KDevBaseUrl   @"更改域名"

#import "RrDebugSettingViewController.h"

@interface RrDebugSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation RrDebugSettingViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [SVProgressHUD dismiss];
    NSString *url = [RrUserDefaults getStrValueInUDWithKey:SRrDBaseUrl_release];
    if (checkStrEmty(url)) {
        [RrUserDefaults saveStrValueInUD:RrDBaseUrl forKey:SRrDBaseUrl_release];
    }
    [super viewDidLoad];
    self.dataArr = @[KDevOpen,KCell_Space,KDevBaseUrl];
    [self.view addSubview:self.tableView];
    
    
    
}


- (void)openSystemSetting{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:nil completionHandler:^(BOOL success) {
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = self.dataArr[indexPath.row];
    if ([title isEqualToString:KCell_Space]) {
        return iPH(17);
    }
    return KCell_H;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 17;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KFrameWidth, 17)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KFrameWidth, 60)];
    view.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, KFrameWidth - 17*2, 60)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor c_iconNorColor];
    label.font = KFont18;
    label.numberOfLines = 0;
    label.text = @"在开发模式配置完成后，app可能会闪退，只需重新启动即可更新配置";
    [view addSubview:label];
    return view;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    SRrOpen_release_dev
    NSString *title = self.dataArr[indexPath.row];
    BOOL opne = [RrUserDefaults getBoolValueInUDWithKey:SRrOpen_release_dev];

    if ([title isEqualToString:KDevOpen]){

        NSArray *arr = @[@"",@"开启",@"关闭"];
        [self ActionSheetWithTitle:@"调试模式" message:@"debug状态" destructive:@"取消" destructiveAction:^(NSInteger index) {
            
        } andOthers:arr animated:YES action:^(NSInteger index) {
            
            if (index != 0) {
                [RrUserDefaults saveBoolValueInUD:index == 1?YES:NO forKey:SRrOpen_release_dev];
                [self.tableView reloadData];
            }
        }];
        return;
    }
    if (!opne) {
        showMessage(@"请先开启调试模式");
        return;
    }
    if ([title isEqualToString:KDevBaseUrl]){
        NSString *url = [RrUserDefaults getStrValueInUDWithKey:SRrDBaseUrl_release];
        NSArray *arr = [LXObjectTools getRrDBaseUrlArrByRelese];
        MZActionSheetView *sheet =[[MZActionSheetView alloc] initWithActionSheetWithTitle:@"更换域名" ListArray:arr completeSelctBlock:^(NSInteger selectIndex) {
            if (selectIndex>=0) {
            [RrUserDefaults saveStrValueInUD:arr[selectIndex] forKey:SRrDBaseUrl_release];
             exit(0);
            }
        }];
        if ([arr containsObject:url] ) {
            [sheet didSelectRowAtIndex: [arr indexOfObject:url]];
        }
        sheet.tapEnadle = NO;
        [sheet show];
    }
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *title = self.dataArr[indexPath.row];
    
    RrCommonRowCell *cell = [tableView dequeueReusableCellWithIdentifier:RrCommonRowCell_ID];
    cell.mainTitleLabel.text = title;
    cell.rightLabel.hidden = NO;
    cell.pushImageView.hidden = NO;
    [cell.contenViewBg addCornerRadius:7];
    
    BOOL opne = [RrUserDefaults getBoolValueInUDWithKey:SRrOpen_release_dev];

    if ([title isEqualToString:KCell_Space]) {
        return [MZCommonCell blankSpaceCell];
    }else if ([title isEqualToString:KDevOpen]){
        cell.rightLabel.text =  opne ? @"已开启":@"未开启";
    }else if ([title isEqualToString:KDevBaseUrl]){
        if (opne) {
            NSString *url = [RrUserDefaults getStrValueInUDWithKey:SRrDBaseUrl_release];
            cell.rightLabel.text = checkStrEmty(url) ? RrDBaseUrl:url;
        }
       
    }
    return cell;
    
}


- (UITableView *)tableView{
    
    if (!_tableView) {//UITableViewStyleGrouped
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KFrameWidth, (KFrameHeight-64)) style:UITableViewStylePlain];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 73;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor mian_BgColor];
        _tableView.tableHeaderView = [UIView new];
        _tableView.tableFooterView = [UIView new];
        
        [_tableView registerNibString:NSStringFromClass([RrCommonRowCell class]) cellIndentifier:RrCommonRowCell_ID];
        
    }
    return _tableView;
}




@end
