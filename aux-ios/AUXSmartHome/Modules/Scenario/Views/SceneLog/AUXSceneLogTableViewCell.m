//
//  AUXSceneLogTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/20.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSceneLogTableViewCell.h"
#import "UIColor+AUXCustom.h"
#import "UIView+AUXCornerRadius.h"

@interface AUXSceneLogTableViewCell ()
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic,assign) BOOL timeLabelHidden;
@property (weak, nonatomic) IBOutlet UIButton *selectButton1;
@end
@implementation AUXSceneLogTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cellbackgroundView.layer.masksToBounds = YES;
    self.cellbackgroundView.layer.cornerRadius = 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModel:(AUXSceneLogModel *)model{
    [self.selectButton setImage:[UIImage imageNamed:@"scene_btn_display"] forState:UIControlStateNormal];

    self.dataArray = model.detailList.mutableCopy;
    self.timeLabelHidden = model.timeLabelHidden;
    self.iconImageView.frame = CGRectMake(10, 12, 16, 16);
    self.name1Label.frame = CGRectMake(30,10 , kScreenWidth-142, 20);
    self.name2Labnel.frame = CGRectMake(30, 34, kScreenWidth-114, 17);
    self.selectButton.frame = CGRectMake(kScreenWidth-102, 8, 22, 22);

    if (model.sceneType == AUXSceneTypeOfPlace) {
        self.iconImageView.image = [UIImage imageNamed:@"scene_log_icon_palce"];
        self.cellbackgroundView.backgroundColor = [UIColor colorWithHexString:@"9AD0F6"];
    }else if (model.sceneType == AUXSceneTypeOfTime) {
        self.iconImageView.image = [UIImage imageNamed:@"scene_log_icon_time"];
        self.cellbackgroundView.backgroundColor = [UIColor colorWithHexString:@"95E4EB"];
    }else  if (model.sceneType == AUXSceneTypeOfManual){
        self.iconImageView.image = [UIImage imageNamed:@"scene_log_icon_hand"];
        self.cellbackgroundView.backgroundColor = [UIColor colorWithHexString:@"A1ADF2"];
    }
    self.timeLabel.text = [model.createDay substringFromIndex:10];
    NSArray *tmpArray = model.detailList.mutableCopy;
    NSMutableString * str = [[NSMutableString alloc]init];
    if (tmpArray.count >1) {
        str = tmpArray[1];
    }
    for (int i=1; i <tmpArray.count; i++) {
        NSString *tmpStr = tmpArray[i];
        if (i >=2) {
            str = [NSMutableString stringWithFormat:@"%@\n%@",str,tmpStr];
        }
    }
    self.name1Label.text = [NSString stringWithFormat:@"%@%@",model.sceneName,model.result];
    
    NSLog(@"%@",self.name1Label.text);
    self.name1Label.font = [UIFont systemFontOfSize:14];
    CGSize  actualsize =[self.name1Label.text boundingRectWithSize:CGSizeMake(kScreenWidth-114, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14],NSFontAttributeName,nil] context:nil].size;
    if (actualsize.height<20) {
        self.name1Label.frame = CGRectMake(30,10 , kScreenWidth-142, 20);
    }else{
        self.name1Label.frame = CGRectMake(30,10 , kScreenWidth-142, actualsize.height);
    }
    
    
    self.name2Labnel.text = tmpArray.firstObject;
    self.name2Labnel.font = [UIFont systemFontOfSize:12];
    CGFloat name2Labelheight = [self returnFloatBy:self.name2Labnel.text];
    if (name2Labelheight < 17 ) {
        self.name2Labnel.frame = CGRectMake(30, self.name1Label.frame.size.height+self.name1Label.frame.origin.y+4, kScreenWidth-114, 17);
        if (model.timeLabelHidden) {
            self.timeLabel.frame = CGRectMake(0, 0, 0, 0);
        }else{
            self.timeLabel.frame = CGRectMake(52, 10, 200, 20);
            self.timeLabel.text = [model.createDay substringFromIndex:10];
        }
    }else{
        self.name2Labnel.numberOfLines = 0;
        self.name2Labnel.frame = CGRectMake(30, self.name1Label.frame.size.height+self.name1Label.frame.origin.y+4, kScreenWidth-114, name2Labelheight);
        if (model.timeLabelHidden) {
            self.timeLabel.frame = CGRectMake(0, 0, 0, 0);
        }else{
            self.timeLabel.frame = CGRectMake(52, 10, 200, 20);
        }
    }
    if (tmpArray.count <=1) {
        self.nameLabel3.hidden = YES;
        self.selectButton.hidden = YES;
    }else{
        self.nameLabel3.hidden = NO;
        self.selectButton.hidden = NO;

        CGFloat heiht = 0;
        CGFloat nameLabel3height = [self returnFloatBy:str];
             if (nameLabel3height < 15 ) {
                 heiht = 20;
             }else  if (nameLabel3height >15 && nameLabel3height <30) {
                  heiht = 30;
             }else{
               heiht = nameLabel3height;;
             }
        self.nameLabel3.frame =  CGRectMake(30, self.name2Labnel.frame.origin.y+self.name2Labnel.bounds.size.height+4, kScreenWidth-114, heiht);
        self.nameLabel3.text = @"...";
    }
    if (tmpArray.count >1) {
     self.cellbackgroundView.frame = CGRectMake(52, self.timeLabel.frame.origin.y+self.timeLabel.frame.size.height+4,  kScreenWidth-70, self.nameLabel3.frame.origin.y + self.nameLabel3.frame.size.height+10);
    }else{
         self.cellbackgroundView.frame = CGRectMake(52, self.timeLabel.frame.origin.y+self.timeLabel.frame.size.height+4,  kScreenWidth-70, self.name2Labnel.frame.origin.y + self.name2Labnel.frame.size.height+10);
    }
    
    
    self.selectButton1.frame = CGRectMake(0, 0, kScreenWidth, self.cellbackgroundView.frame.size.height);

    self.cellHeight = self.cellbackgroundView.frame.origin.y+self.cellbackgroundView.bounds.size.height+4;
}

- (CGFloat)returnFloatBy:(NSString *)str{
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12],NSFontAttributeName,nil];
    CGSize  actualsize =[str boundingRectWithSize:CGSizeMake(kScreenWidth-114, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    return actualsize.height;
}

- (IBAction)selectButtonAction:(UIButton *)sender {
//    self.selectButton.hidden = NO;
    NSMutableString * str = @"".mutableCopy;
    if (self.dataArray.count>1) {
        str = self.dataArray[1];
        for (int i=2; i <self.dataArray.count; i++) {
            NSString *tmpStr = self.dataArray[i];
            if (tmpStr.length!=0) {
                str = [NSMutableString stringWithFormat:@"%@\n%@",str,tmpStr];
            }
        }
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        
        [self.selectButton setImage:[UIImage imageNamed:@"scene_btn_hide"] forState:UIControlStateNormal];
        self.nameLabel3.text = str;
    }else{
        [self.selectButton setImage:[UIImage imageNamed:@"scene_btn_display"] forState:UIControlStateNormal];
        self.nameLabel3.text = @"...";
    }
    self.cellHeight = self.cellbackgroundView.frame.origin.y+self.cellbackgroundView.bounds.size.height;
}

@end


