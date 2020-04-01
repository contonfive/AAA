//
//  AUXMyInfomationViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/27.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXMyInfomationViewController.h"
#import "AUXMyInformationTableViewCell.h"
#import "UIColor+AUXCustom.h"
#import "AUXUser.h"
#import "AUXArchiveTool.h"
#import "AUXLocalNetworkTool.h"
#import "AUXDeviceInfoAlertView.h"
#import "AUXSelectGenderView.h"
#import "AUXDatePickerPopupViewController.h"
#import "AUXAddressAlert.h"
#import "AUXNetworkManager.h"
#import "AUXBindAccountViewController.h"
#import "AUXCommonAlertView.h"



@interface AUXMyInfomationViewController ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *realName;
@property (copy, nonatomic) NSString *genderValue;
@property (copy, nonatomic) NSString *birthday;
@property (copy, nonatomic) NSString *province;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) UIImage *headImg;
@property (copy, nonatomic) NSString *imgpath;

@property (retain, nonatomic) NSMutableArray *regionArray;
@property (retain, nonatomic) NSMutableDictionary *regionDictionary;
@end

@implementation AUXMyInfomationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableview registerNib:[UINib nibWithNibName:@"AUXMyInformationTableViewCell" bundle:nil] forCellReuseIdentifier:@"AUXMyInformationTableViewCell"];
    self.tableview.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableview.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self initialValue];
}



- (void)initialValue {
    AUXUser *user = [AUXUser defaultUser];
    self.nickName = user.nickName && [user.nickName length] ? user.nickName : [AUXArchiveTool getArchiveAccount];
    self.realName = user.realName && [user.realName length] ? user.realName : [AUXArchiveTool getArchiveAccount];
    self.realName = AUXWhtherNullString(self.realName)?@"待完善":self.realName;
    self.genderValue = AUXWhtherNullString(user.gender)?@"待完善":user.gender;
    self.imgpath = user.headImg ;
    if ([self.genderValue isEqualToString:@"N"] ||[self.genderValue isEqualToString:@"待完善"]) {
        self.genderValue = @"待完善";
    }else if ([self.genderValue isEqualToString:@"M"]||[self.genderValue isEqualToString:@"男"]){
        self.genderValue = @"男";
    }else{
        self.genderValue = @"女";
    }
    self.birthday = AUXWhtherNullString(user.birthday)?@"待完善":user.birthday;
    self.province = AUXWhtherNullString(user.region) ? @"待完善" : user.region;
    self.city = AUXWhtherNullString(user.city) ? @"" : user.city;
    self.phone = user.phone;
    UIImage *portrait = [UIImage imageWithData:user.portrait];
    self.headImg =  portrait ? portrait : [UIImage imageNamed:@"mine_img_user_initial"];
    [self reStData];
    
    self.regionArray = [[NSMutableArray alloc] init];
    self.regionDictionary = [[NSMutableDictionary alloc] init];
    @weakify(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @strongify(self)
        self.regionDictionary = [[NSMutableDictionary alloc] init];
        NSArray *regionArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"region.plist" ofType:nil]];
        for (NSDictionary *region in regionArray) {
            NSMutableArray *cities = [[NSMutableArray alloc] init];
            NSArray *cites = [region objectForKey:@"children"];
            for (NSDictionary *city in cites) {
                [cities addObject:[city objectForKey:@"shortName"]];
            }
            NSString *regionName = [region objectForKey:@"shortName"];
            [self.regionArray addObject:regionName];
            [self.regionDictionary setObject:cities forKey:regionName];
        }
    });
}

- (void)reStData{
    self.phone = self.phone.length ==0?@"去绑定":self.phone;
    self.headImg =  self.headImg?self.headImg : [UIImage imageNamed:@"mine_img_user_initial"];
    AUXUser *user = [AUXUser defaultUser];
    
    if (self.nickName==nil) {
        self.nickName = user.nickName && [user.nickName length] ? user.nickName : [AUXArchiveTool getArchiveAccount];
    }
    if (self.realName == nil) {
        self.realName = user.realName && [user.realName length] ? user.realName : [AUXArchiveTool getArchiveAccount];
        self.realName = AUXWhtherNullString(self.realName)?@"待完善":self.realName;
    }
    
    if (self.genderValue == nil) {
        self.genderValue = AUXWhtherNullString(user.gender)?@"待完善":user.gender;
        if ([self.genderValue isEqualToString:@"N"] ||[self.genderValue isEqualToString:@"待完善"]) {
            self.genderValue = @"待完善";
        }else if ([self.genderValue isEqualToString:@"M"]||[self.genderValue isEqualToString:@"男"]){
            self.genderValue = @"男";
        }else{
            self.genderValue = @"女";
        }
    }
    if (self.birthday == nil) {
        self.birthday = AUXWhtherNullString(user.birthday)?@"待完善":user.birthday;
    }
    if (self.province == nil) {
        self.province = AUXWhtherNullString(user.region) ? @"待完善" : user.region;
    }
    self.itemArray = [NSMutableArray arrayWithArray:@[@[@{@"title":@"头像",@"detail":self.headImg}],
                                                      @[@{@"title":@"登录手机号",@"detail":self.phone},
                                                        @{@"title":@"昵称",@"detail":self.nickName},],
                                                      @[@{@"title":@"姓名",@"detail":self.realName },
                                                        @{@"title":@"性别",@"detail": self.genderValue},
                                                        @{@"title":@"出生日期",@"detail":self.birthday},
                                                        @{@"title":@"所在地区",@"detail":[NSString stringWithFormat:@"%@ %@",self.province,self.city]}]
                                                      ]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *tmpDic = self.itemArray[indexPath.section][indexPath.row];
    AUXMyInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AUXMyInformationTableViewCell" forIndexPath:indexPath];
    if (indexPath.section==0 && indexPath.row==0) {
        [cell layoutIfNeeded];
        cell.headerImageview.hidden = NO;
        cell.secondLanel.hidden = YES;
        cell.headerImageview.image = self.headImg;
        cell.headerImageview.layer.masksToBounds = YES;
        cell.headerImageview.layer.cornerRadius = cell.headerImageview.bounds.size.height/2;
        cell.firstLabel.text = tmpDic[@"title"];
        cell.backImageview.hidden = NO;
    }else{
        if (indexPath.section==1 && indexPath.row==0) {
            if (![self.phone isEqualToString:@"去绑定"]) {
                 cell.backImageview.hidden = YES;
            }else{
                   cell.backImageview.hidden = NO;
            }
        }else{
               cell.backImageview.hidden = NO;

        }
        
        cell.headerImageview.hidden = YES;
        cell.secondLanel.hidden = NO;
        cell.firstLabel.text = tmpDic[@"title"];
        cell.secondLanel.text = tmpDic[@"detail"];
    }
    
    if ((indexPath.section==0 && indexPath.row==0)||(indexPath.section==1 && indexPath.row==1)||(indexPath.section==2 && indexPath.row==3)) {
        cell.underLine.hidden = YES;
    }else{
        cell.underLine.hidden = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section==2&&indexPath.row==2) {
        NSArray  *array = [tmpDic[@"detail"] componentsSeparatedByString:@"-"];
        if (array.count ==3) {
             cell.secondLanel.text = [NSString stringWithFormat:@"%@年%@月%@日",array[0],array[1],array[2]];
        }
    }
    
    

    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.itemArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0 && indexPath.row==0) {
        return 98;
    }
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *tempArray = self.itemArray[section];
    return tempArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        [self selectHeaderImage];
    }else if (indexPath.section==1){
        if (indexPath.row==1) {
            @weakify(self);
            [AUXCommonAlertView alertViewWithnameType:AUXNamingTypeUserNickName nameLabelText:@"昵称" detailLabelText:self.nickName confirm:^(NSString *name) {
                @strongify(self);
                self.nickName = name;
                [self reStData];
                [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
                [self saveInfon];
            } close:^{
                NSLog(@"点击了取消按钮");
            }];
        }else{
            if (AUXWhtherNullString([AUXUser defaultUser].phone)) {
                AUXBindAccountViewController *bindAccountViewController = [AUXBindAccountViewController instantiateFromStoryboard:kAUXStoryboardNameLogin];
                bindAccountViewController.bindAccountType = AUXBindAccountTypeOfUserCenter;
                [self.navigationController pushViewController:bindAccountViewController animated:YES];            }
        }
        
    }else if (indexPath.section==2){
        switch (indexPath.row) {
            case 0:{
                @weakify(self);
                [AUXCommonAlertView alertViewWithnameType:AUXNamingTypeUserName nameLabelText:@"姓名" detailLabelText:self.realName confirm:^(NSString *name) {
                    @strongify(self);
                    self.realName = name;
                    [self reStData];
                    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
                    [self saveInfon];
                } close:^{
                    NSLog(@"点击了取消按钮");
                }];
                
            }
                break;
            case 1:
            {
                [AUXSelectGenderView alertViewWithMessage:self.genderValue mGenderAtcion:^{
                    self.genderValue = @"男";
                    [self reStData];
                    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
                    [self saveInfon];
                } fGenderAction:^{
                    self.genderValue = @"女";
                    [self reStData];
                    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
                    [self saveInfon];
                }];
            }
                break;
            case 2:
            {
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
                NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
                
                AUXDatePickerPopupViewController *datePickerPopupViewController = [[AUXDatePickerPopupViewController alloc] initWithDateType:AUXElectricityCurveDateTypeDay minYear:1917];
                datePickerPopupViewController.pickerTitle = @"出生日期";
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd"];
                if (self.birthday && self.birthday.length == 10) {
                    dateComponents = [calendar components:unitFlags fromDate:[formatter dateFromString:self.birthday]];
                }
                [datePickerPopupViewController selectYear:dateComponents.year animated:NO];
                [datePickerPopupViewController selectMonth:dateComponents.month animated:NO];
                [datePickerPopupViewController selectDay:dateComponents.day animated:NO];
                @weakify(self)
                datePickerPopupViewController.didSelectDateBlock = ^(NSInteger year, NSInteger month, NSInteger day) {
                    @strongify(self);
                    self.birthday = [NSString stringWithFormat:@"%d-%02d-%02d", (int)year, (int)month, (int)day];
                    [self reStData];
                    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
                    [self saveInfon];
                };
                [datePickerPopupViewController showWithAnimated:YES completion:nil];
            }
                break;
            case 3:{
                [AUXAddressAlert alertViewWithregionArray:self.regionArray regionDictionary:self.regionDictionary addressBlock:^(NSString *provinceStr, NSString *cityStr) {
                    self.city = cityStr;
                    self.province = provinceStr;
                    [self reStData];
                    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
                    [self saveInfon];
                }];
            }
                break;
            default:
                break;
        }
        
    }
}

- (void)selectHeaderImage{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    @weakify(self);
    [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self selectPhotoFrom:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
#if TARGET_IPHONE_SIMULATOR
#else
        @strongify(self);
        [self selectPhotoFrom:UIImagePickerControllerSourceTypeCamera];
#endif
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:kAUXLocalizedString(@"Cancle") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
}

- (void)selectPhotoFrom:(UIImagePickerControllerSourceType)type {
    
    if (![self isopencameraAndphotoalbum]) {
        if (type == UIImagePickerControllerSourceTypeCamera) {
            [self alertWithMessage:@"非常抱歉，同意相机权限才能正常使用拍照" confirmTitle:@"去设置" confirmBlock:^{
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:url];
            } cancelTitle:@"取消" cancelBlock:nil];
        }else  if (type == UIImagePickerControllerSourceTypePhotoLibrary){
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = type;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }else{
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = type;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.headImg = image;
    [self reStData];
    [self.tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    @weakify(self)
    [picker dismissViewControllerAnimated:YES completion:^{
        @strongify(self)
        if (![AUXLocalNetworkTool isReachable]) {
            
            if (@available(iOS 11.0, *)) {
                [self showErrorViewWithMessage:@"网络不可用"];
                return;
            } else {
                AUXLocalNetworkTool *tool = [AUXLocalNetworkTool defaultTool];
                if (tool.networkReachability.networkReachabilityStatus == -1) {
                }else{
                    [self showErrorViewWithMessage:@"网络不可用"];
                    return;
                }
            }
            
            
        }
        [self showLoadingHUD];
        @weakify(self)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            @strongify(self)
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            NSLog(@"原始图片大小: %lu", (unsigned long)data.length);
            int i = 0;
            while (data.length > (1 << 19) && i < 9) {
                NSLog(@"图片尺寸不合要求，开始压缩");
                i += 1;
                data = UIImageJPEGRepresentation(image, 1.0 - 0.1 * i);
                NSLog(@"第%d次压缩后图片大小: %lu", i, (unsigned long)data.length);
            }
            if (data.length > (1 << 20)) {
                [self hideLoadingHUD];
                [self showErrorViewWithMessage:@"选择图片尺寸过大"];
            } else {
                @weakify(self)
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self)
                    self.headImg = [UIImage imageWithData:data];
                });
                
                
                [[AUXNetworkManager manager] updatePortrait:data progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                }completion:^(NSString *path, NSError *error) {
                    [self hideLoadingHUD];
                    NSLog(@"%@",error);
                    @strongify(self)
                    if (error) {
                        if (error.code == AUXNetworkErrorAccountCacheExpired) {
                            [self alertAccountCacheExpiredMessage];
                            return;
                        }
                        [self showErrorViewWithMessage:@"保存失败"];
                    } else {
                        self.imgpath = path;
                        [self saveInfon];
                        
                    }
                }];
            }
        });
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (void)saveInfon{
    
    if (![AUXLocalNetworkTool isReachable]) {
        if (@available(iOS 11.0, *)) {
            [self showErrorViewWithMessage:@"网络不可用"];
            return;
        } else {
            AUXLocalNetworkTool *tool = [AUXLocalNetworkTool defaultTool];
            if (tool.networkReachability.networkReachabilityStatus == -1) {
            }else{
                [self showErrorViewWithMessage:@"网络不可用"];
                return;
            }
        }
    }
    
    if (AUXWhtherNullString(self.nickName)) {
        [self showErrorViewWithMessage:@"昵称不能为空"];
        return;
    }
    if (AUXWhtherNullString(self.realName)) {
        [self showErrorViewWithMessage:@"姓名不能为空"];
        return;
    }
    AUXUser *user = [[AUXUser alloc] init];
    user.nickName = self.nickName;
    user.realName = self.realName;
    if ([self.genderValue isEqualToString:@"男"]) {
        user.gender =@"M";
    }else  if ([self.genderValue isEqualToString:@"女"]){
         user.gender =@"F";
    }else{
       user.gender =@"N";
    }
    
    user.gender = self.genderValue;
    user.birthday = self.birthday;
    user.region = self.province;
    user.city = self.city;
    if (self.imgpath.length!=0) {
        user.headImg = self.imgpath;
    }
    
    [self showLoadingHUD];
    @weakify(self);
    [[AUXNetworkManager manager] updateUserInfoWithUser:user completion:^(NSError *error) {
        @strongify(self)
        [self hideLoadingHUD];
        switch (error.code) {
            case AUXNetworkErrorNone: {
                [self showSuccess:@"修改成功"];
                AUXUser *currentUser = [AUXUser defaultUser];
                currentUser.nickName = user.nickName;
                currentUser.realName = user.realName;
                currentUser.gender = user.gender;
                currentUser.birthday = user.birthday;
                currentUser.region = user.region;
                currentUser.city = user.city;
                currentUser.headImg = user.headImg;
                [AUXUser archiveUser];
            }
                break;
                
            case AUXNetworkErrorAccountCacheExpired:
                [self hideLoadingHUD];
                [self alertAccountCacheExpiredMessage];
                break;
                
            default:
                [self hideLoadingHUD];
                [self showErrorViewWithMessage:@"修改失败"];
                break;
        }
    }];
}

@end




