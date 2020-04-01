//
//  AUXPushLimitMessageTimePick.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/29.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXPushLimitMessageTimePick.h"
#import "NSDate+AUXCustom.h"
#import "UIColor+AUXCustom.h"

@interface AUXPushLimitMessageTimePick ()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (strong, nonatomic) UIPickerView *pickerView;
@property (nonatomic,strong) NSMutableArray *firsthoursArray;
@property (nonatomic,strong) NSMutableArray *seccondhoursArray;
@property (nonatomic,assign) NSInteger selectRow;
@property (nonatomic,assign) NSInteger firstNumber;
@property (nonatomic,assign) NSInteger seccondNumber;
@property (nonatomic,strong)NSString *str1;
@property (nonatomic,strong)NSString *str2;

@end

@implementation AUXPushLimitMessageTimePick

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
       
        [self creatUI];
    }
    return self;
}

-(void)creatUI{
    self.backgroundColor = [UIColor whiteColor];
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,250)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self addSubview:self.pickerView];
    self.starttime =200;
    self.endtime = 200;
    self.firstNumber = [[MyDefaults objectForKey:kPushMessageStartTime] integerValue];
    [self.pickerView selectRow:self.firstNumber inComponent:0 animated:YES];
    [self pickerView:self.pickerView didSelectRow:self.firstNumber inComponent:0];
    self.seccondNumber = [[MyDefaults objectForKey:kPushMessageEndTime] integerValue];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pickerView selectRow: self.seccondNumber inComponent:2 animated:YES];
        [self pickerView:self.pickerView didSelectRow: self.seccondNumber inComponent:2];
    });
    
}


- (NSMutableArray *)firsthoursArray {
    if (!_firsthoursArray) {
        _firsthoursArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 24; i++) {
            [_firsthoursArray addObject:[NSString stringWithFormat:@"%.2ld:00" , (long)i]];
        }
    }
    return _firsthoursArray;
}

- (NSMutableArray *)seccondhoursArray {
    if (!_seccondhoursArray) {
        _seccondhoursArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 24; i++) {
            [_seccondhoursArray addObject:[NSString stringWithFormat:@"%.2ld:00" , (long)i]];
        }
    }
    return _seccondhoursArray;
}

#pragma mark 返回有几列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

#pragma mark 返回指定列的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (component==0) {
        return  self.firsthoursArray.count;
    } else if(component==1){
        return  1;
    }
    return self.seccondhoursArray.count;
}

#pragma mark 返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 46.0f;
}

#pragma mark 返回指定列的宽度
- (CGFloat) pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    if (component==0) {
        return  self.frame.size.width/3;
    } else if(component==1){
        return  self.frame.size.width/3;
    }
    return  self.frame.size.width/3;
}


#pragma mark 自定义指定列的每行的视图，即指定列的每行的视图行为一致
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if (!view){
        view = [[UIView alloc]init];
    }
    UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width/3,46)];
    text.textColor = [UIColor colorWithHexString:@"666666"];
    text.font = [UIFont systemFontOfSize:FontSize(22)];
    if (component ==0) {
        text.text = [_firsthoursArray objectAtIndex:row];
        text.textAlignment = NSTextAlignmentRight;
    }else if (component == 1){
        text.text = @"至";
        text.font = [UIFont systemFontOfSize:FontSize(12)];
        text.textColor = [UIColor colorWithHexString:@"333333"];
        text.textAlignment = NSTextAlignmentCenter;
        
    }else if (component == 2) {
        text.text = [_seccondhoursArray objectAtIndex:row];
        text.textAlignment = NSTextAlignmentLeft;
    }
    if (row == self.selectRow) {
        //改变当前显示行的字体颜色，如果你愿意，也可以改变字体大小，状态
        if (component != 1) {
            text.textColor = [UIColor colorWithHexString:@"256BBD"];
        }
    }
    [view addSubview:text];
    //隐藏上下直线
    [self.pickerView.subviews objectAtIndex:1].backgroundColor = [UIColor colorWithHexString:@"DDDDDD"];
    [self.pickerView.subviews objectAtIndex:2].backgroundColor = [UIColor colorWithHexString:@"DDDDDD"];
    return view;
}

#pragma mark 显示的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *str =@"";
    if (component ==0) {
        str = [_firsthoursArray objectAtIndex:row];
    }else if (component ==1){
        str = @":";
    }else{
        str = [_seccondhoursArray objectAtIndex:row];
    }
    return str;
}

#pragma mark 被选择的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component ==0) {
        self.str1 = [_firsthoursArray objectAtIndex:row];
    }else if (component ==1){
    }else{
        self.str2 = [_seccondhoursArray objectAtIndex:row];
    }
    NSString *startHour = self.str1.length==0?[NSString stringWithFormat:@"%ld",(long)self.firstNumber]:self.str1;
    NSString *endHour = self.str2.length==0?[NSString stringWithFormat:@"%ld",(long)self.seccondNumber]:self.str2;
    self.starttime = startHour.integerValue ;
    self.endtime = endHour.integerValue;
    self.selectRow = row;
    [self.pickerView reloadComponent:component];
}

@end

