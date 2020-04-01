/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXUserCenterViewController.h"
#import "AUXAboutViewController.h"
#import "AUXSceneViewController.h"
#import "AUXMessageManagerViewController.h"
#import "AUXNotificationComponentPromptViewController.h"
#import "AUXComponentsViewController.h"
#import "AUXScanCodeViewController.h"
#import "AUXHomepageTabBarController.h"
#import "AUXOTAViewController.h"
#import "AUXUserCenterAfterSaleViewController.h"
#import "AUXUserSetViewController.h"
#import "AUXFeedbackViewController.h"
#import "AUXStoreDetailViewController.h"
#import "AUXUserWebViewController.h"
#import "AUXBindAccountViewController.h"
#import "AUXUserCenterAfterSaleViewController.h"
#import "AUXDeviceControlViewController.h"
#import "AUXUserCenterDeviceShareViewController.h"
#import "AUXUserCollectionFooterView.h"

#import "AUXUser.h"
#import "AUXArchiveTool.h"
#import "AUXConstant.h"
#import "AUXNetworkManager.h"
#import "AUXSoapManager.h"
#import "AUXStoreDomainModel.h"

#import "AUXVersionTool.h"

#import "AppDelegate.h"

#import "UIColor+AUXCustom.h"

#import "AUXMyCenterCollectionViewCell.h"
#import "AUXMyCenterTableViewCell.h"
#import "AUXMyInfomationViewController.h"
#import "AUXProductGuideViewController.h"



@interface AUXUserCenterViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong)NSArray *colllectionDataarray;
@property (nonatomic,strong)NSArray *tableviewDataarray;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *edtButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *messageItem;
@property (weak, nonatomic) IBOutlet UIView *headerImgView;
@property (nonatomic,strong) AUXStoreDomainModel *storeDomainModel;
@property (nonatomic,strong) UICollectionViewFlowLayout *listFlowLayout;


@property (nonatomic,assign)BOOL isShowdian;
@end

@implementation AUXUserCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AUXMyCenterCollectionViewCell" bundle:nil]  forCellWithReuseIdentifier:@"AUXMyCenterCollectionViewCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXMyCenterTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXMyCenterTableViewCell"];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableview.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.headerImgView.layer.masksToBounds= YES;
    self.headerImgView.layer.cornerRadius = self.headerImgView.bounds.size.height/2;
    
    self.colllectionDataarray = @[@{@"image":@"mine_icon_share",@"description":@"设备共享"},
                                  @{@"image":@"mine_icon_experience",@"description":@"虚拟体验"},
                                  @{@"image":@"mine_icon_widget",@"description":@"小组件"},
                                  @{@"image":@"mine_icon_knowledge",@"description":@"产品指南"},
                                  ];
    self.tableviewDataarray = @[@{@"image":@"mine_icon_shop",@"description":@"我的商城"},
                                @{@"image":@"mine_icon_service",@"description":@"售后服务"},
                                @{@"image":@"mine_icon_help",@"description":@"帮助与反馈"},
                                @{@"image":@"mine_icon_set",@"description":@"设置"},
                                ];
    self.messageItem.image = [[UIImage imageNamed:@"mine_nav_message"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.headerImageView.layer.masksToBounds = YES;
    self.headerImageView.layer.cornerRadius = self.headerImageView.frame.size.height/2;
    [self.headerImageView layoutIfNeeded];
    self.headerImageView.backgroundColor = [UIColor redColor];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:24];
    //这样写的目的是：根据屏幕判断机型 小于等于568 的屏幕 为5s 5 se 4 4s （也就是小屏手机 让其滑动）大屏之所以不让滑动是因为上面的vie和tableview不在一起 滑动影响美观
    if (kScreenHeight>568) {
        self.tableview.scrollEnabled  = NO;
    }else{
       self.tableview.scrollEnabled  = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.tabBarController.tabBar.hidden = NO;
    UIImage *image = [UIImage qmui_imageWithColor:[UIColor clearColor]];;
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self requestUserInfo];
    self.storeDomainModel = [AUXStoreDomainModel sharedInstance];
    [self getData];
}


- (void)pushViewController:(UIViewController *)viewController {
    
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark atcion

- (IBAction)messageAtcion:(id)sender {
    AUXMessageManagerViewController *messageManagerViewController = [AUXMessageManagerViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    [self pushViewController:messageManagerViewController];
}

#pragma mark - 网络请求

- (void)requestUserInfo {
    [[AUXNetworkManager manager] getUserInfoWithCompletion:^(AUXUser * _Nullable user, NSError * _Nonnull error) {
        
        NSString *nickName = user.nickName;
        self.nameLabel.text = nickName && nickName.length > 0 ? nickName : [AUXArchiveTool getArchiveAccount];;
        UIImage *portrait = [UIImage imageWithData:user.portrait];
        self.headerImageView.image = portrait ? portrait : [UIImage imageNamed:@"mine_img_user_initial"];
    }];
}


#pragma mark  collectview每个分区显示对少个item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colllectionDataarray.count;
}

#pragma mark  修改个人信息按钮的点击事件
- (IBAction)changeMyinfoButtonAction:(UIButton *)sender {
    AUXMyInfomationViewController *myInfomationViewController = [AUXMyInfomationViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
    [self pushViewController:myInfomationViewController];
}

#pragma mark  collectview 定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark  collectview item展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.colllectionDataarray[indexPath.row];
    static NSString * CellIdentifier = @"AUXMyCenterCollectionViewCell";
    AUXMyCenterCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.iconImageview.image = [UIImage imageNamed:dic[@"image"]];
    cell.descriptionLabel.text = dic[@"description"];
    return cell;
}

#pragma mark  collectview item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, 88);
}




#pragma mark 每个item之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return (self.collectionView.bounds.size.width-240)/5;
}


#pragma mark UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            AUXUserCenterDeviceShareViewController *deviceShareViewController = [AUXUserCenterDeviceShareViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
            [self pushViewController:deviceShareViewController];
        }
            break;
        case 1: {
            
            AUXDeviceControlViewController *deviceControllerViewController = [AUXDeviceControlViewController instantiateFromStoryboard:kAUXStoryboardNameDeviceControl];
            [self pushViewController:deviceControllerViewController];
            
        }
            break;
        case 2: {
            if ([AUXArchiveTool shouldShowNotificationControlGuidePage]) {
                AUXNotificationComponentPromptViewController *notificationViewController = [AUXNotificationComponentPromptViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
                [self pushViewController:notificationViewController];
            } else {
                AUXComponentsViewController *componentsViewController = [AUXComponentsViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
                [self pushViewController:componentsViewController];
            }
        }
            break;
        case 3: {
            
         AUXProductGuideViewController *productGuideViewController =[AUXProductGuideViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
            [self pushViewController:productGuideViewController];
        }
            break;
            
        default:
            break;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *dic = self.tableviewDataarray[indexPath.row];
    AUXMyCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXMyCenterTableViewCell" forIndexPath:indexPath];
    cell.iconImageview.image = [UIImage imageNamed:dic[@"image"]];
    cell.descriptionLabel.text = dic[@"description"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.dianLabel.layer.masksToBounds = YES;
    cell.dianLabel.layer.cornerRadius = 3;
    cell.dianLabel.hidden = YES;
    if (indexPath.row==2) {
        if (self.isShowdian) {
            cell.dianLabel.hidden = NO;
        }else{
            cell.dianLabel.hidden = YES;
        }
    }
    if (indexPath.row == self.tableviewDataarray.count-1) {
        cell.lineView.hidden = YES;
    }else{
        cell.lineView.hidden = NO;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableviewDataarray.count;
}

#pragma mark - 每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56;
}

#pragma mark  cell的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AUXBaseViewController *viewController = nil;
    switch (indexPath.row) {
        case 0:
        {
            if ([AUXUser isBindAccount]) {
                AUXStoreDetailViewController *storeDetailViewController = [AUXStoreDetailViewController instantiateFromStoryboard:kAUXStoryboardNameStore];
                viewController = storeDetailViewController;
                storeDetailViewController.loadURL = self.storeDomainModel.ucenter;
                storeDetailViewController.needURL = self.storeDomainModel.ucenter;
            } else {
                
                AUXBindAccountViewController *bindAccountVC = [AUXBindAccountViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
                bindAccountVC.bindAccountType = AUXBindAccountTypeOfUserCenter;
                viewController = bindAccountVC;
            }
        }
            break;
        case 1:
        {
            AUXUserCenterAfterSaleViewController *afterSaleViewController = [AUXUserCenterAfterSaleViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
            viewController = afterSaleViewController;
            
        }
            break;
        case 2:
        {
            AUXUserWebViewController *userWebViewController = [AUXUserWebViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
            userWebViewController.isformFeaceback = YES;
            userWebViewController.loadUrl = kAUXHelpURL;
            [self pushViewController:userWebViewController];
        }
            break;
        case 3:
        {
            AUXUserSetViewController *setUserViewController = [AUXUserSetViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
            viewController = setUserViewController;
        }
            break;
            
        default:
            break;
    }
    
    if (viewController) {
        [self pushViewController:viewController];
    }
}

#pragma mark  分区头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}



#pragma mark  获取列表
- (void)getData{
    [[AUXNetworkManager manager]getFeedbackcompltion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        if (error ==nil) {
            if ([dic[@"code"] integerValue]==200) {
                for (NSDictionary *dict in dic[@"data"]) {
                    AUXFeedbackListModel *feedbackListModel = [[AUXFeedbackListModel alloc]init];
                    [feedbackListModel yy_modelSetWithDictionary:dict];
                    if (feedbackListModel.unreadNum !=0) {
                        self.isShowdian = YES;
                         [self.tableview reloadData];
                        return ;
                    }else{
                        self.isShowdian = NO;
                    }
                }
                 [self.tableview reloadData];
            }
        }
    }];
}

- (void)showComponentViewController {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        AUXComponentsViewController *componentViewController = [AUXComponentsViewController instantiateFromStoryboard:kAUXStoryboardNameUserCenter];
        [self pushViewController:componentViewController];
    });
    
}

#pragma mark 跳转到售后页面
- (void)pushToAfterSaleWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}



@end

