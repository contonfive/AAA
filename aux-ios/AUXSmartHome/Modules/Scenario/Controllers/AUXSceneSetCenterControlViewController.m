//
//  AUXSceneSetCenterControlViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/15.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneSetCenterControlViewController.h"
#import "AUXSceneCenterSetTableViewCell.h"
//#import "AUXDeviceInfoAlertView.h"
#import "AUXSceneExecuteDeviceViewController.h"
#import "AUXSceneCommonModel.h"
#import "AUXNetworkManager.h"
#import "UIColor+AUXCustom.h"
#import "AUXAlertCustomView.h"
#import "AUXScenePlaceInstructionsViewController.h"
#import "AUXCommonAlertView.h"


@interface AUXSceneSetCenterControlViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic,strong)NSArray *dateArray;
@property (nonatomic,strong)NSString *sceneName;
@property (nonatomic,strong)NSArray *tmpdateArray;
@property (nonatomic,strong)NSString *sceneId;
@end

@implementation AUXSceneSetCenterControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.form isEqualToString:@"sceneMy"]) {
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        self.sceneName = commonModel.sceneName;
        if (commonModel.sceneType != 1) {
            self.dateArray = @[@[@{@"name1":@"场景名称",@"name2":self.sceneName}],
                               @[@{@"name1":@"删除场景",@"name2":@""}],
                               ];
        }else{
            self.dateArray = @[@[@{@"name1":@"场景名称",@"name2":self.sceneName},
                                 @{@"name1":@"场景须知",@"name2":@""}],
                               @[@{@"name1":@"删除场景",@"name2":@""}],
                               ];
        }          
    }else{
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        self.sceneName = commonModel.sceneName;
        self.dateArray = @[@[@{@"name1":@"场景名称",@"name2":self.sceneName},
                             @{@"name1":@"执行设备",@"name2":@""}],
                           @[@{@"name1":@"删除场景",@"name2":@""}],
                           ];
    }
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXSceneCenterSetTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXSceneCenterSetTableViewCell"];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableview.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    
    self.customBackAtcion = YES;
    
}

- (void)backAtcion{
    if (self.backBlock) {
        self.backBlock(self.tmpdateArray);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    if (self.sceneId.length==0) {
        NSString *tmpStr = self.tmpDict[@"data"][@"sceneId"];
        if (tmpStr.length!=0) {
            self.sceneId = self.tmpDict[@"data"][@"sceneId"];
        }
    }
    if (self.sceneName==0) {
        NSString *tmpStr = self.tmpDict[@"data"][@"sceneName"];
        if (tmpStr.length!=0) {
            self.sceneName = tmpStr;
        }
    }
   
    [super viewWillAppear:YES];
}

#pragma mark  tableview 每个cell显示什么内容
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    AUXSceneCenterSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXSceneCenterSetTableViewCell" forIndexPath:indexPath];
    if (indexPath.section==0) {
        if (indexPath.row !=0) {
            cell.sceneNameLabel2.hidden = YES;
          
        }
        
        NSArray *tmpArray = self.dateArray[indexPath.section];
        if (tmpArray.count==1) {
              cell.underLineView.hidden = YES;
        }else{
            if (indexPath.row==0) {
                  cell.underLineView.hidden = NO;
            }else{
                  cell.underLineView.hidden = YES;
            }
        }
        cell.backImageview.hidden = NO;
        
    }else{
        cell.backImageview.hidden = YES;
        cell.sceneNameLabel2.hidden = YES;
        cell.underLineView.hidden = YES;
    }
    cell.sceneNameLabel1.text = self.dateArray[indexPath.section][indexPath.row][@"name1"];
    cell.sceneNameLabel2.text = self.sceneName;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark  tableview 每个分区显示多少cell
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *temarray = self.dateArray[section];
    return temarray.count;
}

#pragma mark - 每个cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark  每个分区头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 12)];
    view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    return view;
}

#pragma mark  cell的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (indexPath.row ==0) {
            AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
            if (commonModel.whetherInitFlag !=0) {
                [self showToastshortWithmessageinCenter:@"默认场景不能修改"];
                return;
            }
            
            @weakify(self);
            [AUXCommonAlertView alertViewWithnameType:AUXNamingTypeSceneName nameLabelText:@"场景名称" detailLabelText:self.sceneName confirm:^(NSString *name) {
                @strongify(self);
                if ([name isEqualToString:commonModel.sceneName]) {
                }else{
                    self.sceneName = name;
                    commonModel.sceneName = name;
                    [self reStesceneName];
                    
                    [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
                }
               
            } close:^{
                NSLog(@"点击了取消按钮");
            }];
            
            
        }else{
            if ([self.dateArray[indexPath.section][indexPath.row][@"name1"] isEqualToString:@"场景须知"]) {
                AUXScenePlaceInstructionsViewController *instructionsViewController = [AUXScenePlaceInstructionsViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
                [self.navigationController pushViewController:instructionsViewController animated:YES];
                
            }else{
                AUXSceneExecuteDeviceViewController *sceneExecuteDeviceViewController = [AUXSceneExecuteDeviceViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
                sceneExecuteDeviceViewController.tmpDict = self.tmpDict;
                
                sceneExecuteDeviceViewController.backBlock = ^(NSArray * _Nonnull tmpArray) {
                    NSLog(@"%@",tmpArray);
                    self.tmpdateArray = tmpArray;
                };
                sceneExecuteDeviceViewController.form = @"sceneMy";
                [self.navigationController pushViewController:sceneExecuteDeviceViewController animated:YES];
            }
        }
    }else{
        [self requestDeleteScene];
    }
}

#pragma mark  返回的分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dateArray.count;
}

#pragma mark  修改场景名称
- (void)reStesceneName{
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
   
    if (self.sceneId.length==0) {
        self.sceneId = commonModel.sceneId;
    }
    
    [self showLoadingHUD];
    [[AUXNetworkManager manager] renameSceneWithSceneId:self.sceneId sceneName:self.sceneName completion:^(AUXSceneDetailModel * _Nonnull detailModel, NSError * _Nonnull error) {
        [self hideLoadingHUD];
        if ([error.localizedDescription isEqualToString:@"OPERATE RETRIEVE SUCCESS"]) {
            commonModel.isEdit = YES;
            [MyDefaults setObject:@"0" forKey:kIsSceneEdit];
            [self showToastshortWithmessageinCenter:@"修改成功"];

            [self.tableview reloadData];
        }else{
            [self showToastshortWitherror:error];
        }
    }];
}

#pragma mark  删除场景
- (void)requestDeleteScene {
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    
    if (commonModel.whetherInitFlag !=0) {
        [self showToastshortWithmessageinCenter:@"默认场景不允许删除"];
        return;
    }
    
    if (self.sceneId.length==0) {
        self.sceneId = commonModel.sceneId;
    }
    if (self.sceneName.length==0) {
        self.sceneName= commonModel.sceneName;
    }
    
    NSString *alertMessage = [NSString stringWithFormat:@"是否确认删除'%@'?",self.sceneName];

    [AUXAlertCustomView alertViewWithMessage:alertMessage confirmAtcion:^{
        [self showLoadingHUD];
        
        [[AUXNetworkManager manager] deleteSceneWithSceneId:self.sceneId  completion:^(BOOL result, NSError * _Nonnull error) {
            [self hideLoadingHUD];
            if (result) {
                [self showToastshortWithmessageinCenter:@"删除成功"];
                [commonModel reSetValue];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else {
                [self showToastshortWithmessageinCenter:@"删除失败"];
            }
        }];
    } cancleAtcion:^{
        
    }];
    
    
}

@end





