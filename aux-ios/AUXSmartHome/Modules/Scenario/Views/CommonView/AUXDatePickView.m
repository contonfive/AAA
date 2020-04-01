//
//  AUXDatePickView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/10.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXDatePickView.h"
#import "NSDate+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXSceneCommonModel.h"

@interface AUXDatePickView ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (strong, nonatomic) UIPickerView *pickerView;
@property (nonatomic,strong) NSMutableArray *hoursArray;
@property (nonatomic,strong) NSMutableArray *minutesArray;
@property (nonatomic,assign) NSInteger selectRow;

@property (nonatomic,copy)NSString *str1;
@property (nonatomic,copy)NSString *str2;

@end

@implementation AUXDatePickView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self creatUI];
    }
    return self;
}

-(void)creatUI{
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    self.backgroundColor = [UIColor whiteColor];
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,250)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self addSubview:self.pickerView];
    [self.pickerView reloadAllComponents];//刷新UIPickerView
    
    if (commonModel.actionTime.length!=0) {
        NSString *firstStr = [commonModel.actionTime substringToIndex:2];
        NSString *secondStr =  [commonModel.actionTime substringFromIndex:3];
        if ([firstStr hasPrefix:@"0"]) {
            firstStr = [firstStr substringFromIndex:1];
        }
        if ([secondStr hasPrefix:@"0"]) {
            secondStr = [secondStr substringFromIndex:1];
        }
        self.firstNumber = [firstStr integerValue];
        self.seccondNumber = [secondStr integerValue];
    }
 
    
    if (self.firstNumber==0 && self.seccondNumber==0) {
        if (commonModel.actionTime.length==0) {
            self.firstNumber = [[self getTheCorrectNum:[NSDate nowhh]] integerValue];
            self.seccondNumber = [[self getTheCorrectNum:[NSDate nowmm]] integerValue];
        }
    }
    
    [self.pickerView selectRow:self.firstNumber inComponent:0 animated:YES];
    [self.pickerView selectRow: self.seccondNumber inComponent:2 animated:YES];
    [self pickerView:self.pickerView didSelectRow:self.firstNumber inComponent:0];
    self.timeStr = [NSString stringWithFormat:@"%ld:%ld",(long)self.firstNumber,(long)self.seccondNumber];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self pickerView:self.pickerView didSelectRow: self.seccondNumber inComponent:2];
    });
}

-(NSString*) getTheCorrectNum:(NSString*)tempString
{
    while ([tempString hasPrefix:@"0"])
    {
        tempString = [tempString substringFromIndex:1];
    }
    return tempString;
}

- (NSMutableArray *)hoursArray {
    if (!_hoursArray) {
        _hoursArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 24; i++) {
            [_hoursArray addObject:[NSString stringWithFormat:@"%.2ld" , i]];
        }
    }
    return _hoursArray;
}

- (NSMutableArray *)minutesArray {
    if (!_minutesArray) {
        _minutesArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 60; i++) {
            [_minutesArray addObject:[NSString stringWithFormat:@"%.2ld" , i]];
        }
    }
    return _minutesArray;
}

#pragma mark pickerview function
//返回有几列

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView

{
    return 3;
}

//返回指定列的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component

{
    if (component==0) {
        return  self.hoursArray.count;
    } else if(component==1){
        return  1;
    }
    return self.minutesArray.count;
    
}

//返回指定列，行的高度，就是自定义行的高度

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 46.0f;
    
}

//返回指定列的宽度

- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component==0) {
        return  self.frame.size.width/3;
    } else if(component==1){
        return  self.frame.size.width/3;
    }
    return  self.frame.size.width/3;
}


// 自定义指定列的每行的视图，即指定列的每行的视图行为一致
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if (!view){
        view = [[UIView alloc]init];
    }
    UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width/3,46)];
    text.textColor = [UIColor colorWithHexString:@"666666"];
    text.font = [UIFont systemFontOfSize:FontSize(22)];
    if (component ==0) {
        text.text = [_hoursArray objectAtIndex:row];
        text.textAlignment = NSTextAlignmentRight;
    }else if (component == 1){
        text.text = @":";
        text.textColor = [UIColor colorWithHexString:@"256BBD"];
        text.textAlignment = NSTextAlignmentCenter;
        
        
    }else if (component == 2) {
        text.text = [_minutesArray objectAtIndex:row];
        text.textAlignment = NSTextAlignmentLeft;
    }
    
    if (row == self.selectRow) {
        //改变当前显示行的字体颜色，如果你愿意，也可以改变字体大小，状态
        text.textColor = [UIColor colorWithHexString:@"256BBD"];
    }
    
    [view addSubview:text];
    //隐藏上下直线
    [self.pickerView.subviews objectAtIndex:1].backgroundColor = [UIColor colorWithHexString:@"DDDDDD"];
    [self.pickerView.subviews objectAtIndex:2].backgroundColor = [UIColor colorWithHexString:@"DDDDDD"];
    return view;
}

//显示的标题

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *str =@"";
    if (component ==0) {
        str = [_hoursArray objectAtIndex:row];
    }else if (component ==1){
        str = @":";
    }else{
        str = [_minutesArray objectAtIndex:row];
    }
    return str;
}

//被选择的行
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
//    NSString *str1 =@"";
//    NSString *str2 =@"";
//    NSString *str3 =@"";
    if (component ==0) {
        self.str1 = [_hoursArray objectAtIndex:row];
        
    }else if (component ==1){
    }else{
        self.str2 = [_minutesArray objectAtIndex:row];
    }
    
    NSString*hours = self.firstNumber<10?[NSString stringWithFormat:@"0%ld",self.firstNumber]:[NSString stringWithFormat:@"%ld",self.firstNumber];
    
     NSString*minutes = self.seccondNumber<10?[NSString stringWithFormat:@"0%ld",self.seccondNumber]:[NSString stringWithFormat:@"%ld",self.seccondNumber];
    
    
    
    NSString *hourStr = self.str1.length==0?hours:self.str1;
    NSString *miniStr = self.str2.length==0?minutes:self.str2;
    
    self.timeStr = [NSString stringWithFormat:@"%@:%@",hourStr,miniStr];
    self.selectRow = row;
    [self.pickerView reloadComponent:component];
}

@end

