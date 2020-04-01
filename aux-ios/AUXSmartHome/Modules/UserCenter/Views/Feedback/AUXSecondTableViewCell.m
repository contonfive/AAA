//
//  AUXSecondTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/24.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXSecondTableViewCell.h"
#import "NSDate+AUXCustom.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIColor+AUXCustom.h"


@implementation AUXSecondTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)setFirstCellModel:(AUXFirstCellModel *)firstCellModel{
    
    if ([NSString stringWithFormat:@"%ld",(long)firstCellModel.createdAt].length != 0) {
        if (firstCellModel.isTheSametime) {
            self.timeLabel.text = [[NSDate cStringFromTimestamp:[NSString stringWithFormat:@"%ld",(long)firstCellModel.createdAt]] substringFromIndex:11];
        }else{
            self.timeLabel.text = [NSDate cStringFromTimestamp:[NSString stringWithFormat:@"%ld",(long)firstCellModel.createdAt]];
        }
    }
    if (firstCellModel.timeLabelHidden) {
        self.timeLabel.frame = CGRectMake(0, 10, kScreenWidth, 0);
        
    }else{
        self.timeLabel.frame = CGRectMake(0, 10, kScreenWidth, 20);
    }
    self.contentLabel.font = [UIFont systemFontOfSize:FontSize(16)];
    
    CGFloat maxWith = kScreenWidth * 0.8 ;
    CGFloat miniWith = [firstCellModel.content boundingRectWithSize:CGSizeMake(MAXFLOAT,46) options:NSStringDrawingUsesLineFragmentOrigin  attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSize(16)],NSFontAttributeName,nil] context:nil].size.width;
    
    self.contentLabel.text = firstCellModel.content;
    self.contentLabel.numberOfLines = 0;
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSize(16)],NSFontAttributeName,nil];
    CGSize  actualsize =[firstCellModel.content boundingRectWithSize:CGSizeMake(maxWith, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    if (firstCellModel.userReply) {
        self.contentLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
        UIImage *image =  [[UIImage imageNamed:@"mine_help_bubble_blue4"] stretchableImageWithLeftCapWidth:20 topCapHeight:40];
        self.bubblesImageview.image = image;
        
        if (miniWith < maxWith) {
            miniWith = miniWith +10;
            self.contentLabel.frame = CGRectMake(kScreenWidth-miniWith-34, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, miniWith, 46);
            self.bubblesImageview.frame = CGRectMake(kScreenWidth-miniWith-46, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, miniWith+24, 46);
        }else{
            self.contentLabel.frame = CGRectMake(kScreenWidth-maxWith-34,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+20, maxWith, actualsize.height);
            
            if (firstCellModel.timeLabelHidden) {
                self.bubblesImageview.frame = CGRectMake(kScreenWidth-maxWith-44,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, maxWith+24, self.contentLabel.bounds.size.height+20);
            }else{
                self.bubblesImageview.frame = CGRectMake(kScreenWidth-maxWith-44,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, maxWith+24, self.contentLabel.bounds.size.height+self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y);

            }
        }
        
    }else{
        UIImage *image =  [[UIImage imageNamed:@"mine_help_bubble_white4"] stretchableImageWithLeftCapWidth:20 topCapHeight:40];
        
        self.bubblesImageview.image = image;
        self.contentLabel.textColor = [UIColor colorWithHexString:@"333333"];
        if (miniWith < maxWith) {
            miniWith = miniWith +10;
            self.contentLabel.frame = CGRectMake(34, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, miniWith, 46);
            self.bubblesImageview.frame = CGRectMake(20, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, miniWith+24, 46);
        }else{
            self.contentLabel.frame = CGRectMake(34, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+20, maxWith, actualsize.height);
            
            if (firstCellModel.timeLabelHidden) {
                self.bubblesImageview.frame = CGRectMake(20, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, maxWith+24, self.contentLabel.bounds.size.height+20);
            }else{
              self.bubblesImageview.frame = CGRectMake(20, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, maxWith+24, self.contentLabel.bounds.size.height+self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y);
            }
            
        }
    }
    
    
    
    self.cellHeight = self.bubblesImageview.bounds.size.height + self.timeLabel.bounds.size.height+ 20;
}

@end
