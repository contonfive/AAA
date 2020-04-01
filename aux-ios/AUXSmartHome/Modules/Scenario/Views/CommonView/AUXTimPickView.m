//
//  AUXTimPickView.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/12.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXTimPickView.h"

#import "NSDate+AUXCustom.h"
#import "UIColor+AUXCustom.h"
#import "AUXSceneCommonModel.h"

@interface AUXTimPickView ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (strong, nonatomic) UIPickerView *pickerView;
@property (nonatomic,strong) NSMutableArray *firstHoursArray;
@property (nonatomic,strong) NSMutableArray *seccondHoursArray;
@property (nonatomic,strong) NSMutableArray *thirdHoursArray;
@property (nonatomic,assign) NSInteger selectRow;
@property (nonatomic,strong) NSString *startHour;
@property (nonatomic,strong) NSString *endHour;
@property (nonatomic,assign) NSInteger firstNumber;
@property (nonatomic,assign) NSInteger seccondNumber;


@end

@implementation AUXTimPickView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self creatUI];
    }
    return self;
}

-(void)creatUI{
    self.timeStr = [NSString stringWithFormat:@"00:00-24:00"];
    self.backgroundColor = [UIColor whiteColor];
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,282)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self addSubview:self.pickerView];
    AUXSceneCommonModel *commonModel = [AUXSceneCommonModel shareAUXSceneCommonModel];
    if (commonModel.effectiveTime.length!=0) {
        NSString *firstStr = [commonModel.effectiveTime substringToIndex:2];
        NSString *secondStr =  [[commonModel.effectiveTime substringFromIndex:6] substringToIndex:2];
        if ([firstStr hasPrefix:@"0"]) {
            firstStr = [firstStr substringFromIndex:1];
        }
        if ([secondStr hasPrefix:@"0"]) {
            secondStr = [secondStr substringFromIndex:1];
        }
        self.firstNumber = [firstStr integerValue];
        self.seccondNumber = [secondStr integerValue];
    }else{
        self.firstNumber = 0;
        self.seccondNumber = 24;
    }
    self.thirdHoursArray = self.seccondHoursArray.mutableCopy;
    
    if (self.firstHoursArray.count!=0) {
        [self.pickerView selectRow:self.firstNumber inComponent:0 animated:YES];
        [self pickerView:self.pickerView didSelectRow:self.firstNumber inComponent:0];
    }
  

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.thirdHoursArray.count>=self.seccondNumber-self.firstNumber-1) {
            [self.pickerView selectRow: self.seccondNumber-self.firstNumber-1 inComponent:2 animated:YES];
            [self pickerView:self.pickerView didSelectRow:self.seccondNumber-self.firstNumber-1 inComponent:2];
        }
    });
    }

- (NSMutableArray *)firstHoursArray {
    if (!_firstHoursArray) {
        _firstHoursArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 24; i++) {
            [_firstHoursArray addObject:[NSString stringWithFormat:@"%.2ld:00" , i]];
        }
    }
    return _firstHoursArray;
}

- (NSMutableArray *)seccondHoursArray {
    if (!_seccondHoursArray) {
        _seccondHoursArray = [NSMutableArray array];
      
        for (NSInteger i = self.firstNumber+1; i < 25; i++) {
            [_seccondHoursArray addObject:[NSString stringWithFormat:@"%.2ld:00" , i]];
        }
    }
    return _seccondHoursArray;
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
        return  self.firstHoursArray.count;
    } else if(component==1){
        return  1;
    }else{
        return self.thirdHoursArray.count;
        
    }
    
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
        text.text = [_firstHoursArray objectAtIndex:row];
        text.textAlignment = NSTextAlignmentRight;
    }else if (component == 1){
        text.text = @"至";
        text.textColor = [UIColor colorWithHexString:@"333333"];
        text.textAlignment = NSTextAlignmentCenter;
        text.font = [UIFont systemFontOfSize:15];
        
        
    }else if (component == 2) {
        text.text = [_thirdHoursArray objectAtIndex:row];
        text.textAlignment = NSTextAlignmentLeft;
    }
    
    if (row == self.selectRow) {
        //改变当前显示行的字体颜色，如果你愿意，也可以改变字体大小，状态
        if (component==1) {
            text.textColor = [UIColor colorWithHexString:@"333333"];

        }else{
            text.textColor = [UIColor colorWithHexString:@"256BBD"];

        }
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
        str = [_firstHoursArray objectAtIndex:row];
    }else if (component ==1){
        str = @"至";
    }else{
        str = [_thirdHoursArray objectAtIndex:row];
    }
    return str;
}

//被选择的行
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component ==0) {
        NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
        for (NSInteger i = row+1; i < 25; i++) {
            [tmpArray addObject:[NSString stringWithFormat:@"%.2ld:00" , i]];
        }
           self.thirdHoursArray = tmpArray.mutableCopy;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.pickerView reloadComponent:2];//刷新UIPickerView
                [self.pickerView selectRow: 0 inComponent:2 animated:YES];
                [self pickerView:self.pickerView didSelectRow:0 inComponent:2];
            });
    self.startHour = [_firstHoursArray objectAtIndex:row];
    }else if (component ==2){
        self.endHour = [_thirdHoursArray objectAtIndex:row];
    }
    NSString *startHourStr = self.startHour.length==0?@"00:00":[NSString stringWithFormat:@"%@",self.startHour];
    NSString *endHourStr = self.endHour.length==0?@"01:00":self.endHour;
 
    self.selectRow = row;
    [self.pickerView reloadComponent:component];
    self.timeStr = [NSString stringWithFormat:@"%@-%@",startHourStr,endHourStr];
    
}


-(NSInteger)delectPrefixZeroWithStr:(NSString*)str{
    
    str = [str substringToIndex:2];
    
    
    NSString *resultStr = str;
    if ([str hasPrefix:@"0"]) {
        resultStr = [resultStr substringFromIndex:1];
    }
    
    return resultStr.integerValue;
}

@end


