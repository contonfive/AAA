//
//  AUXSceneTimeQuantumViewController.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/11.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneTimeQuantumViewController.h"
#import "AUXTimePeriodPickerTableViewCell.h"
#import "AUXSchedulerModel.h"
#import "UIColor+AUXCustom.h"
#import "AUXTimPickView.h"
#import "AUXSceneCommonModel.h"

@interface AUXSceneTimeQuantumViewController ()
@property (weak, nonatomic) IBOutlet UIButton *onoffButton;
@property (nonatomic,strong) NSString *timeStr;
@property (nonatomic,strong)NSString *repetitionStr;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *repetitionView;
@property (nonatomic,assign) NSInteger starhour;
@property (nonatomic,assign) NSInteger endhour;
@property (nonatomic,strong)NSMutableArray *dateArray;
@property (nonatomic,strong)AUXTimPickView*pickView;
@property (weak, nonatomic) IBOutlet UIView *timePickView;
@property (weak, nonatomic) IBOutlet UIButton *noRepeatButton;
@property (weak, nonatomic) IBOutlet UIButton *everyDayButton;
@property (weak, nonatomic) IBOutlet UIButton *weekendButton;
@property (weak, nonatomic) IBOutlet UIButton *workDayButton;
@property (weak, nonatomic) IBOutlet UIButton *customeButton;
@property (weak, nonatomic) IBOutlet UIButton *mondyButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *wednesdayButton;
@property (weak, nonatomic) IBOutlet UIButton *thursdayButton;
@property (weak, nonatomic) IBOutlet UIButton *fridayButton;
@property (weak, nonatomic) IBOutlet UIButton *saturdayButton;
@property (weak, nonatomic) IBOutlet UIButton *sundayButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *repetitionViewConstraint;
@property (nonatomic,assign)BOOL isOffTimeSwitch;
@end

@implementation AUXSceneTimeQuantumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dateArray = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"].mutableCopy;
    [self setdateViewButton];
    [self setallButton];
    [self setpickdate];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    NSLog(@"%@",commonModel.effectiveTime);
    if (([commonModel.effectiveTime isEqualToString:@"00:00-24:00"]&&[commonModel.repeatRule isEqualToString:@"每天"])||(commonModel.effectiveTime.length==0&&commonModel.repeatRule.length==0)) {
        self.onoffButton.selected = NO;
        [self onoffButtonAction:self.onoffButton];
    }else{
        self.onoffButton.selected = YES;
        [self onoffButtonAction:self.onoffButton];
        NSString *tmpStr = commonModel.repeatRule;
        if ([tmpStr isEqualToString:@"1,2,3,4,5,6,7"]||[tmpStr isEqualToString:@"每天"]) {
            [self repetitionButtonAction:self.everyDayButton];
        }else  if ([tmpStr isEqualToString:@"1,2,3,4,5"]||[tmpStr isEqualToString:@"工作日"]){
            [self repetitionButtonAction:self.workDayButton];
        }else  if ([tmpStr isEqualToString:@"6,7"]||[tmpStr isEqualToString:@"双休日"]){
            [self repetitionButtonAction:self.weekendButton];
        }else if ([tmpStr isEqualToString:@"不重复"]||[tmpStr isEqualToString:@""]){
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
}


#pragma mark  设置时间选择器
- (void)setpickdate {
    self.pickView = [[AUXTimPickView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 250)];
    [self.timePickView addSubview:self.pickView];
}

#pragma mark  确定按钮的点击事件
- (IBAction)ensureButtonAction:(id)sender {
    
    

//    if (!self.dateView.hidden && self.repetitionStr.length==0) {
//        self.repetitionStr = @"不重复";
//    }
    
    if (self.isOffTimeSwitch) {
        NSDictionary *dic = @{@"time":self.timeStr,
                              @"repetition":self.repetitionStr};
        if (![self.isNewAdd isEqualToString:@"新增场景"]) {
            [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
        }
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        commonModel.effectiveTime = self.timeStr;
        commonModel.repeatRule = self.repetitionStr;
        if (self.gobackBlock) {
            self.gobackBlock(dic);
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        
        if ([self.repetitionStr hasSuffix:@","]) {
            self.repetitionStr =  [self.repetitionStr substringToIndex:self.repetitionStr.length-1];
        }
        self.timeStr = self.pickView.timeStr;
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        commonModel.effectiveTime = self.timeStr;
        if ([self.repetitionStr hasSuffix:@","]) {
            self.repetitionStr =  [self.repetitionStr substringToIndex:self.repetitionStr.length-1];
        }
        
        if (self.repetitionStr.length==0) {
            self.repetitionStr = [self dateSte];
        }
        
        if (self.repetitionStr.length==0) {
            [self showToastshortWithmessageinCenter:@"请选择重复方式"];
        }else{
            
            AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
            commonModel.effectiveTime = self.timeStr;
            
            
            if ([self.repetitionStr hasSuffix:@","]) {
                self.repetitionStr = [self.repetitionStr substringToIndex:self.repetitionStr.length-1];
            }
            
            commonModel.repeatRule = [NSString stringWithFormat:@"%@",self.repetitionStr];
            
            NSDictionary *dic = @{@"time":self.timeStr,
                                  @"repetition":self.repetitionStr,
                                  };
            if (![self.isNewAdd isEqualToString:@"新增场景"]) {
                [MyDefaults setObject:@"1" forKey:kIsSceneEdit];
            }
            
            if (self.gobackBlock) {
                self.gobackBlock(dic);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
}

- (IBAction)onoffButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"common_btn_on"] forState:UIControlStateNormal];
        self.timePickView.hidden = YES;
        self.repetitionView.hidden = YES;
        self.timeStr = @"00:00-24:00";
        self.repetitionStr =@"每天";
        self.isOffTimeSwitch = YES;
    } else {
        
        [sender setImage:[UIImage imageNamed:@"common_btn_off"] forState:UIControlStateNormal];
        self.timePickView.hidden = NO;
        self.repetitionView.hidden = NO;
        self.isOffTimeSwitch = NO;
        AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
        if (commonModel.effectiveTime.length==0&&commonModel.repeatRule.length==0) {
            [self repetitionButtonAction:self.everyDayButton];
        }else if(commonModel.effectiveTime.length==0&&commonModel.repeatRule.length!=0){
             [self repetitionButtonAction:self.noRepeatButton];
        }else{
            if ([commonModel.repeatRule isEqualToString:@"每天"]) {
                [self repetitionButtonAction:self.everyDayButton];
            }
        }
    }
}

- (IBAction)repetitionButtonAction:(UIButton *)sender {
    NSInteger indexTag =  sender.tag-9000;
    [self repetitionViewButtonMode:sender.tag];
    switch (indexTag) {
        case 1:
        {
            self.customeButton.hidden=NO;
            self.dateView.hidden = YES;
            self.repetitionStr =@"不重复";
             self.repetitionViewConstraint.constant= 153;
        }
            break;
        case 2:
        {
            self.customeButton.hidden=NO;
            self.dateView.hidden = YES;
            self.repetitionStr =@"每天";
             self.repetitionViewConstraint.constant= 153;
        }
            break;
        case 3:
        {
            self.customeButton.hidden=NO;
            self.dateView.hidden = YES;
            self.repetitionStr =@"双休日";
             self.repetitionViewConstraint.constant= 153;
        }
            break;
        case 4:
        {
            self.customeButton.hidden=NO;
            self.dateView.hidden = YES;
            self.repetitionStr =@"工作日";
            self.repetitionViewConstraint.constant= 153;
        }
            break;
        case 5:
        {
            self.customeButton.hidden=YES;
            self.dateView.hidden = NO;
            self.repetitionStr =@"";
            self.repetitionViewConstraint.constant= 200;
           
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)dateButtonAction:(UIButton *)sender {
    NSInteger index =  sender.tag-9006;
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
    if (tag == 9006) {
        str = @"一-";
    }else if (tag == 9007){
        str = @"二-";
    }else if (tag == 9008){
        str = @"三-";
    }else if (tag == 9009){
        str = @"四-";
    }else if (tag == 9010){
        str = @"五-";
    }else if (tag ==9011){
        str = @"六-";
    }else if (tag == 9012){
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
-(void)setButtonMode:(UIButton*)button{
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 5;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [[UIColor colorWithHexString:@"E5E5E5"] CGColor];
    [button setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
}

-(void)setdateViewButtonMode:(UIButton*)button{
    [self.dateView layoutIfNeeded];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = button.frame.size.height/2;
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor colorWithHexString:@"666666"] forState:UIControlStateNormal];
    button.layer.borderWidth = 1;
    button.layer.borderColor = [[UIColor colorWithHexString:@"E5E5E5"] CGColor];
}

#pragma mark  模式状态下button的样式
-(void)repetitionViewButtonMode:(NSInteger)tag{
    if (tag<=9005) {
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

@end





