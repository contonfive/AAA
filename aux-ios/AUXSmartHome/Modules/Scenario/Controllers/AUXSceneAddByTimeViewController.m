//
//  AUXSceneAddByTimeViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/9.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneAddByTimeViewController.h"
#import "AUXDatePickView.h"
#import "UIColor+AUXCustom.h"
#import "AUXSceneSelectDeviceListViewController.h"
#import "AUXSceneCommonModel.h"

@interface AUXSceneAddByTimeViewController ()
@property (weak, nonatomic) IBOutlet UIView *datepickVuew;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *repetitionView;
@property (nonatomic,strong)AUXDatePickView*pickView;
@property (weak, nonatomic) IBOutlet UIButton *customeButton;
@property (nonatomic,strong)NSString* repetitionStr;
@property(nonatomic,assign)int number;
@property (nonatomic,strong)NSMutableArray *dateArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateViewHight;
@property (nonatomic,strong)NSString* oldrepetitionStr;
@property (nonatomic,strong)NSString* oldtime;
@property (nonatomic,assign)BOOL isSelectWeek;
@property (weak, nonatomic) IBOutlet UIButton *noRepeatButton;
@property (weak, nonatomic) IBOutlet UIButton *everyDayButton;
@property (weak, nonatomic) IBOutlet UIButton *weekendButton;
@property (weak, nonatomic) IBOutlet UIButton *workDayButton;
@property (weak, nonatomic) IBOutlet UIButton *mondyButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *wednesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *thursdayButton;
@property (weak, nonatomic) IBOutlet UIButton *fridayButton;
@property (weak, nonatomic) IBOutlet UIButton *saturdayButton;
@property (weak, nonatomic) IBOutlet UIButton *sundayButton;




@end

@implementation AUXSceneAddByTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setpickdate];
    [self setallButton];
    self.dateArray = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"].mutableCopy;
    [self setdateViewButton];
    self.view.backgroundColor = [UIColor colorWithHexString:@"F7F7F7"];
    [self.repetitionView layoutIfNeeded];
    self.dateViewHight.constant = 153;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    NSLog(@"%@",commonModel.effectiveTime);
    NSString *tmpStr = commonModel.repeatRule;
    if ([tmpStr isEqualToString:@"1,2,3,4,5,6,7"]||[tmpStr isEqualToString:@"每天"]) {
        [self repetitionButtonAction:self.everyDayButton];
    }else  if ([tmpStr isEqualToString:@"1,2,3,4,5"]||[tmpStr isEqualToString:@"工作日"]){
        [self repetitionButtonAction:self.workDayButton];
        
    }else  if ([tmpStr isEqualToString:@"6,7"]||[tmpStr isEqualToString:@"双休日"]){
        [self repetitionButtonAction:self.weekendButton];
        
    }else if ([tmpStr isEqualToString:@""]||[tmpStr isEqualToString:@"不重复"]){
        [self repetitionButtonAction:self.noRepeatButton];
        
    }else{
        [self repetitionButtonAction:self.customeButton];
        NSArray *array = [tmpStr componentsSeparatedByString:@","];
        for (NSString *weekStr in array) {
            if ([weekStr isEqualToString:@"1"]||[weekStr isEqualToString:@"一"]) {
                [self dateButtonAction:self.mondyButton];
            }else  if ([weekStr isEqualToString:@"2"]||[weekStr isEqualToString:@"二"]){
                [self dateButtonAction:self.tuesdayButton];
            }else  if ([weekStr isEqualToString:@"3"]||[weekStr isEqualToString:@"三"]){
                [self dateButtonAction:self.wednesdayButton];
            }else  if ([weekStr isEqualToString:@"4"]||[weekStr isEqualToString:@"四"]){
                [self dateButtonAction:self.thursdayButton];
            }else  if ([weekStr isEqualToString:@"5"]||[weekStr isEqualToString:@"五"]){
                [self dateButtonAction:self.fridayButton];
            }else  if ([weekStr isEqualToString:@"6"]||[weekStr isEqualToString:@"六"]){
                [self dateButtonAction:self.saturdayButton];
            }else  if ([weekStr isEqualToString:@"7"]||[weekStr isEqualToString:@"日"]){
                [self dateButtonAction:self.sundayButton];
            }
        }
    }
}


-(void)setallButton{
    for (id obj in self.repetitionView.subviews)  {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton* theButton = (UIButton*)obj;
            [self setButtonMode:theButton];
        }
    }
}

-(void)setdateViewButton{
    for (id obj in self.dateView.subviews)  {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton* theButton = (UIButton*)obj;
            [self setdateViewButtonMode:theButton];
        }
    }
}

#pragma mark  button的样式
- (void)setButtonMode:(UIButton*)button {
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [[UIColor colorWithHexString:@"E5E5E5"] CGColor];
    [button setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    
}

- (void)setdateViewButtonMode:(UIButton*)button {
    [self.dateView layoutIfNeeded];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = button.frame.size.height/2;
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [[UIColor colorWithHexString:@"E5E5E5"] CGColor];
}

#pragma mark  模式状态下button的样式
- (void)repetitionViewButtonMode:(NSInteger)tag {
    if (tag<=8005) {
        for (id obj in self.repetitionView.subviews)  {
            if ([obj isKindOfClass:[UIButton class]]) {
                UIButton* theButton = (UIButton*)obj;
                if (theButton.tag == tag) {
                    theButton.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
                    [theButton setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
                }else{
                    theButton.backgroundColor = [UIColor clearColor];
                    [theButton setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
                }
            }
        }
    }
}

#pragma mark  设置时间选择器
- (void)setpickdate {
    self.pickView = [[AUXDatePickView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 250)];
    [self.datepickVuew addSubview:self.pickView];
}

#pragma mark  保存按钮的点击事件
- (IBAction)rightItemAction:(id)sender {
    
    if (self.repetitionStr.length == 0) {
        self.repetitionStr =[self dateSte];
    }
    if (self.repetitionStr.length ==0) {
        [self showToastshortWithmessageinCenter:@"请选择重复时间"];
        return;
    }
    if ([self.repetitionStr hasSuffix:@","]) {
        self.repetitionStr =  [self.repetitionStr substringToIndex:self.repetitionStr.length-1];
    }
    
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    
    if (![self.pickView.timeStr isEqualToString:commonModel.actionTime]|| ![self.repetitionStr isEqualToString:[self resetStr:commonModel.repeatRule]]) {
        [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
    }
    
    commonModel.actionTime = self.pickView.timeStr;
    commonModel.repeatRule = self.repetitionStr;
    if (commonModel.deviceActionDtoList.count==0) {
        AUXSceneDeviceModel *model = [[AUXSceneDeviceModel alloc]init];
        model.deviceName = @"空调";
        model.onOff = 0;
        commonModel.deviceActionDtoList = @[model].mutableCopy;
    }
    
    AUXSceneSelectDeviceListViewController *selectDeviceListViewController = [AUXSceneSelectDeviceListViewController instantiateFromStoryboard:kAUXStoryboardNameScene];
    selectDeviceListViewController.sceneType = self.sceneType;
    selectDeviceListViewController.isNewAdd = self.isNewAdd;
    if ([self.markType isEqualToString:@"changetime"]) {
        [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
        if (self.gobackBlock) {
            self.gobackBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.navigationController pushViewController:selectDeviceListViewController animated:YES];
    }
}


- (IBAction)repetitionButtonAction:(UIButton *)sender {
    NSInteger indexTag =  sender.tag-8000;
    [self repetitionViewButtonMode:sender.tag];
    switch (indexTag) {
        case 1:
        {
            self.customeButton.hidden=NO;
            self.dateView.hidden = YES;
            [self.repetitionView layoutIfNeeded];
            self.dateViewHight.constant = 153;
            self.repetitionStr =@"不重复";
        }
            break;
        case 2:
        {
            self.customeButton.hidden=NO;
            self.dateView.hidden = YES;
            self.repetitionStr =@"每天";
            [self.repetitionView layoutIfNeeded];
            self.dateViewHight.constant = 153;
        }
            break;
        case 3:
        {
            self.customeButton.hidden=NO;
            self.dateView.hidden = YES;
            self.repetitionStr =@"双休日";
            [self.repetitionView layoutIfNeeded];
            self.dateViewHight.constant = 153;
        }
            break;
        case 4:
        {
            self.customeButton.hidden=NO;
            self.dateView.hidden = YES;
            self.repetitionStr =@"工作日";
            [self.repetitionView layoutIfNeeded];
            self.dateViewHight.constant = 153;
        }
            break;
        case 5:
        {
            self.customeButton.hidden=YES;
            self.dateView.hidden = NO;
            self.repetitionStr =@"";
            [self.repetitionView layoutIfNeeded];
            self.dateViewHight.constant = 195;
        }
            break;
        default:
            break;
    }
}

- (IBAction)dateButtonAction:(UIButton *)sender {
    NSInteger index =  sender.tag-8006;
    sender.selected = !sender.selected;
    NSString *str = [self str:sender.tag];
    if (sender.selected) {
        [self.dateArray replaceObjectAtIndex:index withObject:str];
        sender.backgroundColor = [UIColor colorWithHexString:@"256BBD"];
        [sender setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
    }else{
        [self.dateArray replaceObjectAtIndex:index withObject:@"0"];
        [sender setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithHexString:@"FFFFFF"];
    }
}

-(NSString*)str:(NSInteger)tag{
    NSString *str = @"";
    if (tag == 8006) {
        str = @"一-";
    }else if (tag == 8007){
        str = @"二-";
    }else if (tag == 8008){
        str = @"三-";
    }else if (tag == 8009){
        str = @"四-";
    }else if (tag == 8010){
        str = @"五-";
    }else if (tag == 8011){
        str = @"六-";
    }else if (tag == 8012){
        str = @"日-";
    }
    return str;
}

-(NSString *)dateSte{
    NSString *string = [self.dateArray componentsJoinedByString:@","];
    NSString *strUrl = [string stringByReplacingOccurrencesOfString:@"0," withString:@""];
    NSString *strUrl1 = [strUrl stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *strUrl2 = [strUrl1 stringByReplacingOccurrencesOfString:@"0" withString:@""];
    NSString *datestr = @"";
    if ([strUrl2 isEqualToString:@"一,二,三,四,五"]) {
        datestr = @"工作日";
    }
    if ([strUrl1 isEqualToString:@"一,二,三,四,五,六,日"]) {
        strUrl2 = @"每天";
    }
    if ([strUrl2 isEqualToString:@"六,日"]) {
        datestr = @"双休日";
    }
    NSString *resultStr = datestr.length==0?strUrl2:datestr;
    return resultStr;
}

-(NSString *)resetStr:(NSString*)str{
    NSString *result = @"";
    if ([str isEqualToString: @"1,2,3,4,5,6,7"]) {
        result = @"每天";
    }else if ([str isEqualToString: @"6,7"]) {
        result = @"双休日";
    }else if ([str isEqualToString: @"1,2,3,4,5"]){
        result = @"工作日";
    }else{
        NSString *dateStr =[str stringByReplacingOccurrencesOfString:@"1" withString:@"一"];
        NSString *dateStr2 =[dateStr stringByReplacingOccurrencesOfString:@"2" withString:@"二"];
        NSString *dateStr3 =[dateStr2 stringByReplacingOccurrencesOfString:@"3" withString:@"三"];
        NSString *dateStr4 =[dateStr3 stringByReplacingOccurrencesOfString:@"4" withString:@"四"];
        NSString *dateStr5 =[dateStr4 stringByReplacingOccurrencesOfString:@"5" withString:@"五"];
        NSString *dateStr6 =[dateStr5 stringByReplacingOccurrencesOfString:@"6" withString:@"六"];
        NSString *dateStr7 =[dateStr6 stringByReplacingOccurrencesOfString:@"7" withString:@"日"];
        result = dateStr7;
    }
    return result;
}

@end


