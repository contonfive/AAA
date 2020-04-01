//
//  AUXSceneResetSceneViewController.m
//  AUXSmartHome
//  Created by AUX on 2019/4/8.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneResetSceneViewController.h"
#import "UIColor+AUXCustom.h"
#import "AUXSceneAddNewDetailViewController.h"
#import "AUXSceneDeviceModel.h"
#import "AUXSceneCommonModel.h"
#import "AUXAirConditioningModeCollectionViewCell.h"
#import "AUXCollectCellModel.h"
#import "AUXUser.h"
#import "AUXDeviceStateInfo.h"


@interface AUXSceneResetSceneViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *onDeviceButton;
@property (weak, nonatomic) IBOutlet UIButton *offDeviceButton;
@property (weak, nonatomic) IBOutlet UILabel *currentTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *minTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxTemperatureLabel;
@property (weak, nonatomic) IBOutlet UISlider *temperatureSlider;
@property (weak, nonatomic) IBOutlet UIView *patternView;
@property (weak, nonatomic) IBOutlet UIView *onlineStateView;
@property (weak, nonatomic) IBOutlet UIView *temperatureView;
@property (nonatomic,strong)NSMutableArray *sceneDeviceModelArray;
@property (nonatomic,copy)NSString *mode;
@property (nonatomic,assign) NSInteger onOff;
@property (nonatomic,copy)   NSString *temperature;
@property (nonatomic,strong)AUXSceneCommonModel *deviceModel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (nonatomic,strong) AUXSceneDeviceModel *oldsceneDeviceModel;
@property (nonatomic,strong) AUXSceneDeviceModel *newsceneDeviceModel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSString *selectCelltitle;
@property (nonatomic,assign) BOOL isChange;
@property (nonatomic, strong) NSMutableArray<AUXDeviceInfo *> *deviceInfoArray;
@property (weak, nonatomic) IBOutlet UIButton *temperatureButton;
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;

@end

@implementation AUXSceneResetSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AUXAirConditioningModeCollectionViewCell" bundle:nil]  forCellWithReuseIdentifier:@"AUXAirConditioningModeCollectionViewCell"];
    [self.temperatureSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    if (self.titleStr.length !=0) {
        self.title = self.titleStr;
    }
    [self setButton];
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    self.newsceneDeviceModel = [[AUXSceneDeviceModel alloc]init];
    self.temperatureSlider.minimumTrackTintColor = [UIColor colorWithHexString:@"256BBD"];
    [self.temperatureSlider  setThumbImage:[UIImage imageNamed:@"device_btn_slide_small"] forState:UIControlStateNormal];
    self.customBackAtcion = YES;
}

- (void)backAtcion{
    if (self.delectLastobject) {
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        NSMutableArray *tmparr= commonModel.deviceActionDtoList.mutableCopy;
        [tmparr removeLastObject];
        commonModel.deviceActionDtoList = tmparr;
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark  设置页面所有的button
- (void)setButton {
    for (id obj in self.onlineStateView.subviews)  {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton* theButton = (UIButton*)obj;
            theButton.layer.masksToBounds = YES;
            theButton.layer.cornerRadius = 5;
            theButton.layer.borderWidth = 1;
            theButton.layer.borderColor = [[UIColor colorWithHexString:@"E5E5E5"] CGColor];
            [theButton setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
            theButton.backgroundColor = [UIColor clearColor];
        }
    }
    [self.offDeviceButton setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
    self.offDeviceButton.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    [self.sceneDeviceModelArray removeAllObjects];
    if (self.index.length !=0) {
        self.oldsceneDeviceModel = commonModel.deviceActionDtoList[self.index.integerValue];
    }else{
        self.oldsceneDeviceModel = commonModel.deviceActionDtoList.lastObject;
    }
    self.mode = self.oldsceneDeviceModel.mode;
    
    NSMutableArray *modeArray;
    
    for (AUXDeviceInfo *info in self.deviceInfoArray) {
        if ([info.deviceId isEqualToString:self.oldsceneDeviceModel.deviceId]) {
            NSString *feature = @"";
            AUXDeviceFeature *deviceFeature;
            NSString *addressString ;
            AUXACStatus *deviceStatus;
            NSInteger coolType ;
            feature = info.feature;
            deviceFeature = info.deviceFeature;
            addressString = info.addressArray.firstObject;
            deviceStatus = info.device.statusDic[addressString];
            coolType = deviceFeature.coolType.firstObject ? deviceFeature.coolType.firstObject.integerValue : 1;
            modeArray = [NSMutableArray arrayWithArray:@[@(AUXServerDeviceModeCool), @(AUXServerDeviceModeHeat), @(AUXServerDeviceModeDry), @(AUXServerDeviceModeWind),       @(AUXServerDeviceModeAuto)]];
            AUXDeviceStateInfo *deviceStateinfo = [AUXDeviceStateInfo shareAUXDeviceStateInfo];
            BOOL iscontain = [deviceStateinfo.dataArray containsObject:info.deviceId];
            
//有些时候 deviceStatus(SDK 返回) 这个参数返回的是 nil
//目前解决方案是：首先判断这个这个参数是否为nil 如果为空就根据后台coolType 来判断是否支持制热
            BOOL isremoveSupportHeat = NO;
            if (deviceStatus == nil) {
                if (coolType == 0) {
                    isremoveSupportHeat = YES;
                }
            }else{
                if (!deviceStatus.supportHeat || coolType == 0) {
                    isremoveSupportHeat = YES;
                }
            }
            if (isremoveSupportHeat) {
                if (iscontain) {
                    if ([modeArray containsObject:@(AUXServerDeviceModeHeat)]) {
                        [modeArray removeObject:@(AUXServerDeviceModeHeat)];
                    }
                }
            }
            if (deviceFeature) {
                NSMutableArray *tmpArray = modeArray.mutableCopy;
                for (NSNumber *modeNum in tmpArray) {
                    if (![deviceFeature.supportModes containsObject:modeNum]) {
                        if ([modeArray containsObject:modeNum]) {
                            [modeArray removeObject:modeNum];
                        }
                    }
                }
            }
        }
    }
    [self.dataArray removeAllObjects];
    for (int i =0; i<modeArray.count; i++) {
        NSString *tmpstr = @"";
        if ([[NSString stringWithFormat:@"%@",modeArray[i]] isEqualToString:@"0"]) {
            tmpstr = @"自动";
        }else if ([[NSString stringWithFormat:@"%@",modeArray[i]] isEqualToString:@"1"]) {
            tmpstr = @"制冷";
        }else if ([[NSString stringWithFormat:@"%@",modeArray[i]] isEqualToString:@"2"]) {
            tmpstr = @"制热";
        }else if ([[NSString stringWithFormat:@"%@",modeArray[i]] isEqualToString:@"3"]) {
            tmpstr = @"除湿";
        }else if ([[NSString stringWithFormat:@"%@",modeArray[i]] isEqualToString:@"4"]) {
            tmpstr = @"送风";
        }
        NSDictionary *dic = @{@"modetitle":tmpstr,@"isSelect":@NO};
        AUXCollectCellModel *model = [[AUXCollectCellModel alloc]init];
        [model yy_modelSetWithDictionary:dic];
        [self.dataArray addObject:model];
    }
    AUXCollectCellModel *model = self.dataArray.firstObject;
    if ([model.modetitle isEqualToString:@"自动"]) {
        if ([self.dataArray containsObject:model]) {
            [self.dataArray removeObject:model];
        }
        [self.dataArray addObject:model];
    }
    NSLog(@"%@",self.oldsceneDeviceModel.mode);
    if (self.oldsceneDeviceModel.onOff) {
        [self onDeviceButtonAction:self.onDeviceButton];
        NSString *modeStr = @"";
        if ([self.oldsceneDeviceModel.mode isEqualToString:@"0"]) {
            modeStr = @"自动";
            self.temperature = @"";
        }else if ([self.oldsceneDeviceModel.mode isEqualToString:@"1"]) {
            modeStr = @"制冷";
        }else if ([self.oldsceneDeviceModel.mode isEqualToString:@"2"]) {
            modeStr = @"除湿";
        }else if ([self.oldsceneDeviceModel.mode isEqualToString:@"4"]) {
            modeStr = @"制热";
        }else if ([self.oldsceneDeviceModel.mode isEqualToString:@"6"]) {
            modeStr = @"送风";
            self.temperature = @"";
        }else{
            [self onDeviceButtonAction:self.offDeviceButton];
        }
        NSMutableArray *tmpArray1 = [[NSMutableArray alloc]init];
        NSPredicate *predicate = nil;
        predicate = [NSPredicate predicateWithFormat:@"modetitle contains[c] %@", modeStr];
        NSMutableArray *tmpArray = [[self.dataArray filteredArrayUsingPredicate:predicate] mutableCopy];
        AUXCollectCellModel *model = tmpArray.firstObject;
        for (AUXCollectCellModel *tmpmodel in self.dataArray) {
            if ([tmpmodel.modetitle isEqualToString:model.modetitle]) {
                tmpmodel.isSelect = YES;
                [tmpArray1 addObject:tmpmodel];
            }else{
                [tmpArray1 addObject:tmpmodel];
            }
        }
        self.dataArray = tmpArray1.mutableCopy;
        self.temperatureSlider.value = [self.oldsceneDeviceModel.temperature floatValue];
        self.temperature = self.oldsceneDeviceModel.temperature;
        if (self.oldsceneDeviceModel.temperature.length==0) {
            self.currentTemperatureLabel.text = [NSString stringWithFormat:@"26°C"];
        }else{
            self.currentTemperatureLabel.text = [NSString stringWithFormat:@"%@°C",self.temperature];
        }
        if ([self.oldsceneDeviceModel.mode isEqualToString:@"0"]|| [self.oldsceneDeviceModel.mode isEqualToString:@"6"]||self.oldsceneDeviceModel.mode.length==0) {
            self.temperatureView.hidden = YES;
        }else{
            self.temperatureView.hidden = NO;
            if (self.oldsceneDeviceModel.temperature.length==0) {
                self.temperatureSlider.value = 26.0;
                self.temperatureButton.selected = YES;
            }
            [self temperatureButtonAction:self.temperatureButton];
            
        }
        
        
    }else{
        [self offDeviceButtonAction:self.offDeviceButton];
    }
    [self.collectionView reloadData];
    
}




- (NSMutableArray *)sceneDeviceModelArray {
    if (!_sceneDeviceModelArray) {
        self.sceneDeviceModelArray = [[NSMutableArray alloc]init];
    }
    return _sceneDeviceModelArray;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        self.dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

#pragma mark  滑块的滑动事件
-(void)sliderValueChanged:(UISlider *)slider {
    self.currentTemperatureLabel.text = [NSString stringWithFormat:@"%d°C",(int)slider.value];
    self.temperature = [NSString stringWithFormat:@"%d",(int)slider.value];
}

#pragma mark  开机按钮的点击事件
- (IBAction)onDeviceButtonAction:(UIButton *)sender {
    
    if (self.temperature.length==0) {
        self.currentTemperatureLabel.text = [NSString stringWithFormat:@"26°C"];
    }else{
        self.temperature = self.oldsceneDeviceModel.temperature;
        self.currentTemperatureLabel.text =[NSString stringWithFormat:@"%@°C",self.oldsceneDeviceModel.temperature];
        
    }
    sender.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
    [sender setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
    self.offDeviceButton.backgroundColor = [UIColor clearColor];
    [self.offDeviceButton setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
    self.onOff = 1;
    
    if (!([self.mode isEqualToString:@"0"]||[self.mode isEqualToString:@"6"])) {
        self.temperatureView.hidden = NO;
        
    }else{
        self.temperatureView.hidden = YES;
    }
    self.patternView.hidden = NO;
    
    ////////////////////////////////////////////////
    if (self.temperature.length==0 && self.mode.length==0) {
        self.temperatureView.hidden = YES;
    }
}

#pragma mark  关机按钮的点击事件
- (IBAction)offDeviceButtonAction:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
    [sender setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
    self.onDeviceButton.backgroundColor = [UIColor clearColor];
    [self.onDeviceButton setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
    self.onOff = 0;
    self.temperature = @"";
    self.temperatureView.hidden = YES;
    self.patternView.hidden = YES;
}


#pragma mark  确定按钮的点击事件
- (IBAction)ensureItemAction:(UIBarButtonItem *)sender {
    //    模式 0:自动模式 1:制冷模式 2:除湿模式 4:制热模式 6:送风模式
    NSLog(@"%@",self.dataArray);
    self.mode = @"";
    
    for (AUXCollectCellModel *model in self.dataArray) {
        if (model.isSelect) {
            if ([model.modetitle isEqualToString:@"自动"]) {
                self.mode = @"0";
            }else if ([model.modetitle isEqualToString:@"制冷"]) {
                self.mode = @"1";
            }else if ([model.modetitle isEqualToString:@"除湿"]) {
                self.mode = @"2";
            }else if ([model.modetitle isEqualToString:@"制热"]) {
                self.mode = @"4";
            }else if ([model.modetitle isEqualToString:@"送风"]) {
                self.mode = @"6";
                self.temperature = @"";
            }
        }
    }
    
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    for ( AUXSceneDeviceModel *model in commonModel.deviceActionDtoList) {
        [self.sceneDeviceModelArray addObject:model];
    }
    if (self.sceneDeviceModelArray.count==1) {
        AUXSceneDeviceModel *model = self.sceneDeviceModelArray.firstObject;
        model.mode = self.mode;//这个是获取的稍后给值
        model.onOff = self.onOff;//这个是获取的稍后给值
        model.temperature = self.temperature;//这个是获取的稍后给值
        self.isChange = YES;
    }else if (self.sceneDeviceModelArray.count >1) {
        
        if (self.deviceId.length!=0) {
            for ( AUXSceneDeviceModel *model in self.sceneDeviceModelArray) {
                if ([model.deviceId isEqualToString:self.deviceId]) {
                    model.mode = self.mode;//这个是获取的稍后给值
                    model.onOff = self.onOff;//这个是获取的稍后给值
                    model.temperature = self.temperature;//这个是获取的稍后给值
                    self.isChange = YES;
                }
            }
        }else{
            NSMutableArray *tmparray = commonModel.deviceActionDtoList.mutableCopy;
            AUXSceneDeviceModel *model = tmparray.lastObject;
            model.mode = self.mode;//这个是获取的稍后给值
            model.onOff = self.onOff;//这个是获取的稍后给值
            model.temperature = self.temperature;//这个是获取的稍后给值
            [tmparray removeLastObject];
            [tmparray addObject:model];
            commonModel.deviceActionDtoList = tmparray.mutableCopy;
            self.isChange = YES;
        }
    }
    commonModel.deviceActionDtoList = self.sceneDeviceModelArray.mutableCopy;
    if ([self.from isEqualToString:@"sceneMy"]) {
        if (self.isChange) {
            [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
        }
        if (self.goBlock) {
            [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
            self.goBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        if (self.sceneType == AUXSceneTypeOfManual ) {
            commonModel.actionDescription = @"手动执行指定动作";
            commonModel.sceneType =AUXSceneTypeOfManual;
        }else if(self.sceneType == AUXSceneTypeOfPlace ) {
            commonModel.actionDescription = @"进入/离开指定区域后执行指定动作";
            commonModel.sceneType =AUXSceneTypeOfPlace;
        }else if(self.sceneType == AUXSceneTypeOfTime ) {
            commonModel.actionDescription = @"在指定时间执行指定动作";
            commonModel.sceneType =AUXSceneTypeOfTime;
        }
        [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
        AUXSceneAddNewDetailViewController *sceneAddNewDetailViewController = [AUXSceneAddNewDetailViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
        sceneAddNewDetailViewController.sceneType = self.sceneType;
        sceneAddNewDetailViewController.titleStr = self.isNewAdd;
        sceneAddNewDetailViewController.isNewAdd = self.isNewAdd;
        sceneAddNewDetailViewController.sceneName = self.sceneName;
        sceneAddNewDetailViewController.gobackBlock = ^(NSString * _Nonnull deviceId, NSString * _Nonnull index) {
            NSLog(@"%@",deviceId);
            self.deviceId = deviceId;
            self.index = index;
        };
        [self.navigationController pushViewController:sceneAddNewDetailViewController animated:YES];
    }
}

#pragma mark  温度按钮的点击事件
- (IBAction)temperatureButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        self.selectImageView.image = [UIImage imageNamed:@"common_btn_selected_s"];
        self.temperatureSlider.userInteractionEnabled = YES;
        self.temperatureSlider.alpha = 1;
        self.currentTemperatureLabel.alpha = 1;
        self.minTemperatureLabel.alpha = 1;
        self.maxTemperatureLabel.alpha= 1;
        if (self.temperature.length ==0) {
            self.temperature = @"26";
        }
    }else{
        self.selectImageView.image = [UIImage imageNamed:@"common_btn_unselected_s"];
        self.temperatureSlider.userInteractionEnabled = NO;
        self.temperatureSlider.alpha = 0.36;
        self.currentTemperatureLabel.alpha = 0.36;
        self.minTemperatureLabel.alpha = 0.36;
        self.maxTemperatureLabel.alpha= 0.36;
        self.temperature = @"";
    }
}

#pragma mark  collectview每个分区显示对少个item
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

#pragma mark  collectview 定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark  collectview item展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AUXCollectCellModel *model = self.dataArray[indexPath.row];
    static NSString * CellIdentifier = @"AUXAirConditioningModeCollectionViewCell";
    AUXAirConditioningModeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.modeTitleLabel.text = model.modetitle;
    if (model.isSelect) {
        cell.modeTitleLabel.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
        cell.modeTitleLabel.textColor = [UIColor whiteColor];
        cell.modeTitleLabel.layer.borderColor = [[UIColor clearColor] CGColor];
    }else{
        cell.modeTitleLabel.backgroundColor = [UIColor clearColor];
        cell.modeTitleLabel.textColor = [UIColor colorWithHexString:@"666666"];
        cell.modeTitleLabel.layer.borderColor = [[UIColor colorWithHexString:@"E5E5E5"] CGColor];
    }
    
    return cell;
}


#pragma mark  collectview item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return  CGSizeMake(self.layout.itemSize.width, 30);;
}

#pragma mark  collectview 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(12, 0, 0,0);//上、左、下、右
}

#pragma mark UICollectionView被选中时调用的方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    模式 0:自动模式 1:制冷模式 2:除湿模式 4:制热模式 6:送风模式
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    AUXAirConditioningModeCollectionViewCell *cell = (AUXAirConditioningModeCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.temperature.length==0) {
        self.temperatureSlider.value = 26;
        self.temperatureButton.selected = YES;
        [self temperatureButtonAction:self.temperatureButton];
        
    }
    if ([cell.modeTitleLabel.text isEqualToString:@"制冷"]) {
        self.temperatureView.hidden=NO;
        self.mode = @"1";
        
    }else if ([cell.modeTitleLabel.text isEqualToString:@"制热"]){
        self.temperatureView.hidden=NO;
        self.mode = @"4";
        
    }else if ([cell.modeTitleLabel.text isEqualToString:@"除湿"]){
        self.temperatureView.hidden=NO;
        self.mode = @"2";
        
    }else if ([cell.modeTitleLabel.text isEqualToString:@"送风"]){
        self.temperatureView.hidden=YES;
        self.mode = @"6";
    }else if ([cell.modeTitleLabel.text isEqualToString:@"自动"]){
        self.temperatureView.hidden=YES;
        self.mode = @"0";
        self.temperature = @"";
    }
    
    
    NSString *str;
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    AUXCollectCellModel *model1 = self.dataArray[indexPath.row];
    for (AUXCollectCellModel *model in self.dataArray) {
        if ([model1.modetitle isEqualToString:model.modetitle]) {
            model.isSelect = !model.isSelect;
            
            [tmpArray addObject:model];
        }else{
            model.isSelect = NO;
            [tmpArray addObject:model];
        }
    }
    self.selectCelltitle =cell.modeTitleLabel.text;
    self.dataArray = tmpArray.mutableCopy;
    [self.collectionView reloadData];
    
    
    
    
    
    NSString *modeStr = @"";
    
    for (AUXCollectCellModel *model in self.dataArray) {
        if (model.isSelect) {
            if ([model.modetitle isEqualToString:@"自动"]) {
                modeStr = @"0";
            }else if ([model.modetitle isEqualToString:@"制冷"]) {
                modeStr = @"1";
            }else if ([model.modetitle isEqualToString:@"除湿"]) {
                modeStr = @"2";
            }else if ([model.modetitle isEqualToString:@"制热"]) {
                modeStr = @"4";
            }else if ([model.modetitle isEqualToString:@"送风"]) {
                modeStr = @"6";
                self.temperature = @"";
            }
        }
    }
    if (modeStr.length==0 || [modeStr isEqualToString:@"0"]||[modeStr isEqualToString:@"6"]) {
        self.temperatureView.hidden= YES;
        self.temperature = @"";
    }else{
        self.temperatureView.hidden= NO;
    }
}


#pragma mark 获取数据
- (NSMutableArray<AUXDeviceInfo *> *)deviceInfoArray {
    _deviceInfoArray = [[AUXUser defaultUser].deviceInfoArray mutableCopy];
    return _deviceInfoArray;
}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (UICollectionViewFlowLayout *)layout {
    if (!_layout) {
        _layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
        CGFloat cellWidth = (kAUXScreenWidth - 40 - 12*self.dataArray.count-1) / self.dataArray.count;
        _layout.itemSize = CGSizeMake(cellWidth, 30);
    }
    return _layout;
}


@end



