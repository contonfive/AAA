//
//  AUXThirdTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/24.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXThirdTableViewCell.h"
#import "NSDate+AUXCustom.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AUXThirdTableViewCell

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
    
    if (firstCellModel.userReply) {
        self.backImageView.frame = CGRectMake(kScreenWidth - 142, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10+10, 122, 84);
    }else{
        self.backImageView.frame = CGRectMake(20, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10+10, 122, 84);
    }
    
    if (![firstCellModel.imageUrls.firstObject isEqual:@"AAA"]) {
        [self.chrysanthemumView stopAnimating];
        self.aboveView.hidden = YES;
        NSArray *array = firstCellModel.imageUrls.mutableCopy;
        NSURL *url = [NSURL URLWithString:array[0]];
        [self.backImageView  sd_setImageWithURL:url placeholderImage:nil];
    }else{
        [self.chrysanthemumView startAnimating];
        self.aboveView.hidden = NO;
        UIImage *img = firstCellModel.imageUrls[1];
        self.backImageView.image = img;
        self.aboveView.frame = CGRectMake(kScreenWidth - 142, self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10+10, 122, 84);
        self.chrysanthemumView.frame = CGRectMake(51,20, 20, 20);
        self.progressLabel.frame = CGRectMake(0, self.chrysanthemumView.frame.origin.y+self.chrysanthemumView.bounds.size.height+10, self.aboveView.frame.size.width, 20);
    }
    
    self.backImageView.layer.masksToBounds = YES;
    self.backImageView.layer.cornerRadius = 4;
    
}




@end

