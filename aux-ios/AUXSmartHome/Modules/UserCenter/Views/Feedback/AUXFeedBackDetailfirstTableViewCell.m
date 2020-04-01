//
//  AUXFeedBackDetailfirstTableViewCell.m
//  AUXSmartHome
//
//  Created by AUX on 2019/4/22.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXFeedBackDetailfirstTableViewCell.h"
#import "NSDate+AUXCustom.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation AUXFeedBackDetailfirstTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModel:(AUXFirstCellModel *)model{
    self.backView.frame = self.bounds;
    self.timeLabel.frame = CGRectMake(0, 10, kScreenWidth, 20);
    if ([NSString stringWithFormat:@"%ld",(long)model.createdAt].length != 0) {
        self.timeLabel.text = [NSDate cStringFromTimestamp:[NSString stringWithFormat:@"%ld",(long)model.createdAt]];
    }
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    CGFloat maxWith = kScreenWidth * 0.8;
    self.backImageView.image = [[UIImage imageNamed:@"mine_help_bubble_blue1"] stretchableImageWithLeftCapWidth:20 topCapHeight:40];
    self.detailLabel.text = model.content;
    self.detailLabel.numberOfLines =0;
    CGFloat miniWith = [model.content boundingRectWithSize:CGSizeMake(MAXFLOAT, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:FontSize(16)]} context:nil].size.width;
    CGSize  actualsize =[model.content boundingRectWithSize:CGSizeMake(kScreenWidth*0.8, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:FontSize(16)]} context:nil].size;
    
    
    NSArray *tmpArray = model.imageUrls;
    
    if (tmpArray.count ==0) {
        if (miniWith < kScreenWidth*0.8) {
            miniWith = miniWith +10;
            self.detailLabel.frame = CGRectMake(kScreenWidth-miniWith-34,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, miniWith, 46);
            self.backImageView.frame = CGRectMake(kScreenWidth-miniWith-46,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, miniWith+24, self.detailLabel.bounds.size.height);
        }else{
            self.detailLabel.frame = CGRectMake(kScreenWidth-maxWith-34,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, maxWith, actualsize.height+20);
            self.backImageView.frame = CGRectMake(kScreenWidth-maxWith-46,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, maxWith+24, self.detailLabel.bounds.size.height);
        }
        
        self.cellHeight = self.backImageView.bounds.size.height + self.timeLabel.bounds.size.height+20;
        self.imageView1.hidden = YES;
        self.imageview2.hidden = YES;
        self.imageview3.hidden = YES;
        self.imageview4.hidden = YES;
        self.imageBackgroundImageView.hidden = YES;
        self.cellHeight = self.backImageView.bounds.size.height + self.timeLabel.bounds.size.height+40;
        
    }else{
        self.detailLabel.frame = CGRectMake(kScreenWidth-maxWith-34,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, maxWith, actualsize.height+20);
        self.backImageView.frame = CGRectMake(kScreenWidth-maxWith-46,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, maxWith+24, self.detailLabel.bounds.size.height);
        
        CGFloat BtnX = kScreenWidth-maxWith-30+(kScreenWidth * 0.8-200)/5;
        CGFloat space = (kScreenWidth * 0.8-200)/5;
        if (tmpArray.count ==1) {
            self.imageView1.frame = CGRectMake(BtnX, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            [self.imageView1 sd_setImageWithURL:model.imageUrls.firstObject placeholderImage:nil];
            self.imageView1.hidden = NO;
            self.imageview2.hidden = YES;
            self.imageview3.hidden = YES;
            self.imageview4.hidden = YES;
            
        }else if (tmpArray.count ==2){
            self.imageView1.hidden = NO;
            self.imageview2.hidden = NO;
            self.imageview3.hidden = YES;
            self.imageview4.hidden = YES;
            self.imageView1.frame = CGRectMake(BtnX, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            self.imageview2.frame = CGRectMake(self.imageView1.frame.origin.x+50+space,
                                               self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            [self.imageView1 sd_setImageWithURL:model.imageUrls.firstObject placeholderImage:nil];
            [self.imageview2 sd_setImageWithURL:model.imageUrls[1] placeholderImage:nil];
            
        }else if (tmpArray.count ==3){
            self.imageView1.hidden = NO;
            self.imageview2.hidden = NO;
            self.imageview3.hidden = NO;
            self.imageview4.hidden = YES;
            self.imageView1.frame = CGRectMake(BtnX, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            self.imageview2.frame = CGRectMake(self.imageView1.frame.origin.x+50+space, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            self.imageview3.frame = CGRectMake(self.imageview2.frame.origin.x+50+space, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            [self.imageView1 sd_setImageWithURL:model.imageUrls.firstObject placeholderImage:nil];
            [self.imageview2 sd_setImageWithURL:model.imageUrls[1] placeholderImage:nil];
            [self.imageview3 sd_setImageWithURL:model.imageUrls[2] placeholderImage:nil];
            
        }else if (tmpArray.count ==4){
            self.imageView1.hidden = NO;
            self.imageview2.hidden = NO;
            self.imageview3.hidden = NO;
            self.imageview4.hidden = NO;
            self.imageView1.frame = CGRectMake(BtnX, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            self.imageview2.frame = CGRectMake(self.imageView1.frame.origin.x+50+space, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            self.imageview3.frame = CGRectMake(self.imageview2.frame.origin.x+50+space, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            self.imageview4.frame = CGRectMake(self.imageview3.frame.origin.x+50+space, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            [self.imageView1 sd_setImageWithURL:model.imageUrls.firstObject placeholderImage:nil];
            [self.imageview2 sd_setImageWithURL:model.imageUrls[1] placeholderImage:nil];
            [self.imageview3 sd_setImageWithURL:model.imageUrls[2] placeholderImage:nil];
            [self.imageview4 sd_setImageWithURL:model.imageUrls[3] placeholderImage:nil];
        }
        
        if (tmpArray.count>4) {
            self.imageView1.hidden = NO;
            self.imageview2.hidden = NO;
            self.imageview3.hidden = NO;
            self.imageview4.hidden = NO;
            self.imageView1.frame = CGRectMake(BtnX, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            self.imageview2.frame = CGRectMake(self.imageView1.frame.origin.x+50+space, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            self.imageview3.frame = CGRectMake(self.imageview2.frame.origin.x+50+space, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            self.imageview4.frame = CGRectMake(self.imageview3.frame.origin.x+50+space, self.detailLabel.frame.size.height+self.detailLabel.frame.origin.y+12, 50, 50);
            [self.imageView1 sd_setImageWithURL:model.imageUrls.firstObject placeholderImage:nil];
            [self.imageview2 sd_setImageWithURL:model.imageUrls[1] placeholderImage:nil];
            [self.imageview3 sd_setImageWithURL:model.imageUrls[2] placeholderImage:nil];
            [self.imageview4 sd_setImageWithURL:model.imageUrls[3] placeholderImage:nil];
        }
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [self.imageView1 addGestureRecognizer:tapGesture1];
        self.imageView1.userInteractionEnabled = YES;
        self.imageView1.tag = 1000;
        
        UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [self.imageview2 addGestureRecognizer:tapGesture2];
        self.imageview2.userInteractionEnabled = YES;
        self.imageview2.tag = 1001;
        UITapGestureRecognizer *tapGesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [self.imageview3 addGestureRecognizer:tapGesture3];
        self.imageview3.userInteractionEnabled = YES;
        self.imageview3.tag = 1002;
        UITapGestureRecognizer *tapGesture4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
        [self.imageview4 addGestureRecognizer:tapGesture4];
        self.imageview4.userInteractionEnabled = YES;
        self.imageview4.tag = 1003;
        
        
        
        self.imageView1.layer.masksToBounds = YES;
        self.imageView1.layer.cornerRadius = 2;
        
        self.imageview2.layer.masksToBounds = YES;
        self.imageview2.layer.cornerRadius = 2;
        
        
        self.imageview3.layer.masksToBounds = YES;
        self.imageview3.layer.cornerRadius = 2;
        
        self.imageview4.layer.masksToBounds = YES;
        self.imageview4.layer.cornerRadius = 2;
        
        
        self.backImageView.frame = CGRectMake(kScreenWidth-maxWith-46,self.timeLabel.bounds.size.height + self.timeLabel.frame.origin.y+10, maxWith+20, self.detailLabel.bounds.size.height+self.imageView1.bounds.size.height+24);
        self.imageBackgroundImageView.frame =  CGRectMake(kScreenWidth-maxWith-46, self.detailLabel.bounds.size.height + self.detailLabel.frame.origin.y, maxWith+12,self.imageView1.bounds.size.height+24);
        self.imageBackgroundImageView.image = [UIImage imageNamed:@"mine_help_bubble_blue3"];
        self.cellHeight = self.backImageView.bounds.size.height + self.timeLabel.bounds.size.height+40;
    }
    
    
    UIImage *image =  [[UIImage imageNamed:@"mine_help_bubble_blue4"] stretchableImageWithLeftCapWidth:20 topCapHeight:40];
    self.backImageView.image = image;
}

- (void)clickImage:(UITapGestureRecognizer *)sender{
    if (self.didselect) {
        self.didselect(sender.view.tag);
    }
}


@end
