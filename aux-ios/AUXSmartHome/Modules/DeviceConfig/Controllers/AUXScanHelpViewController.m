/*
 * =============================================================================
 *
 * AUX Group Confidential
 *
 * OCO Source Materials
 *
 * (C) Copyright AUX Group Co., Ltd. 2017 All Rights Reserved.
 *
 * The source code for this program is not published or otherwise divested
 * of its trade secrets, unauthorized application or modification of this
 * source code will incur legal liability.
 * =============================================================================
 */

#import "AUXScanHelpViewController.h"
#import "UIColor+AUXCustom.h"
@interface AUXScanHelpViewController ()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (nonatomic,strong)UIScrollView *scroller;
@end

@implementation AUXScanHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setScroller];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}
-(void)setScroller{
    self.scroller = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.view.bounds.origin.y, kScreenWidth, kScreenHeight)];
    [self.backView addSubview:self.scroller];
    UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*SCALEW, 0, kScreenWidth-40*SCALEW, 40*SCALEW)];
    firstLabel.text = @"机型二维码在哪里";
    firstLabel.font = [UIFont boldSystemFontOfSize:FontSize(28)];
    [self.scroller addSubview:firstLabel];
    
    UILabel *seccondLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*SCALEW, firstLabel.bounds.size.height+20*SCALEW, kScreenWidth-40*SCALEW, 22*SCALEW)];
    seccondLabel.text = @"• 机型二维码在挂机上";
    seccondLabel.font = [UIFont systemFontOfSize:FontSize(16)];
    [self.scroller addSubview:seccondLabel];
    seccondLabel.textColor = [UIColor colorWithHexString:@"666666"];
    NSRange seccondLabelRange = [seccondLabel.text rangeOfString:@"挂机"];
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:seccondLabel.text];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:seccondLabelRange];
    seccondLabel.attributedText = attributedString1;
    
    

    
    UIImageView *firstImageview = [[UIImageView alloc]initWithFrame:CGRectMake(20*SCALEW,seccondLabel.bounds.size.height+seccondLabel.frame.origin.y+8*SCALEW, kScreenWidth-40*SCALEW,(kScreenWidth-40*SCALEW)*0.47)];
    [self.scroller addSubview:firstImageview];
    firstImageview.image = [UIImage imageNamed:@"adddevice_img_sn1"];

    UILabel *thirdLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*SCALEW,firstImageview.bounds.size.height+firstImageview.frame.origin.y+20*SCALEW,kScreenWidth-40*SCALEW,22*SCALEW)];
    thirdLabel.text = @"• 机型二维码在柜机上";
    thirdLabel.font = [UIFont systemFontOfSize:FontSize(16)];
    [self.scroller addSubview:thirdLabel];
    thirdLabel.textColor = [UIColor colorWithHexString:@"666666"];
    NSRange thirdLabelLabelRange = [thirdLabel.text rangeOfString:@"柜机"];
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:thirdLabel.text];
    [attributedString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:thirdLabelLabelRange];
    thirdLabel.attributedText = attributedString2;
    
    
    UIImageView *seccondImageview = [[UIImageView alloc]initWithFrame:CGRectMake(20*SCALEW,thirdLabel.bounds.size.height+thirdLabel.frame.origin.y+8*SCALEW, kScreenWidth-40*SCALEW,(kScreenWidth-40*SCALEW)*0.47)];
    [self.scroller addSubview:seccondImageview];
    seccondImageview.image = [UIImage imageNamed:@"adddevice_img_sn2"];
    
    
    
    UILabel *fourthLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*SCALEW,seccondImageview.bounds.size.height+seccondImageview.frame.origin.y+20*SCALEW,kScreenWidth-40*SCALEW,22*SCALEW)];
    fourthLabel.text = @"• 机型条码在保修卡上";
    fourthLabel.font = [UIFont systemFontOfSize:FontSize(16)];
    [self.scroller addSubview:fourthLabel];
    fourthLabel.textColor = [UIColor colorWithHexString:@"666666"];
    NSRange fourthLabelRange = [fourthLabel.text rangeOfString:@"保修卡"];
    NSMutableAttributedString *attributedString3 = [[NSMutableAttributedString alloc] initWithString:fourthLabel.text];
    [attributedString3 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:fourthLabelRange];
    fourthLabel.attributedText = attributedString3;
    
    
    UIImageView *thirdImageview = [[UIImageView alloc]initWithFrame:CGRectMake(20*SCALEW,fourthLabel.bounds.size.height+fourthLabel.frame.origin.y+8*SCALEW, kScreenWidth-40*SCALEW,(kScreenWidth-40*SCALEW)*0.47)];
    [self.scroller addSubview:thirdImageview];
    thirdImageview.image = [UIImage imageNamed:@"adddevice_img_sn3"];
    

//
//    UILabel *fourLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*SCALEW,thirdLabel.bounds.size.height+thirdLabel.frame.origin.y+8*SCALEW,kScreenWidth-40*SCALEW,22*SCALEW)];
//    fourLabel.text = @"情况一：";
//    fourLabel.font = [UIFont systemFontOfSize:FontSize(16)];
//    [self.scroller addSubview:fourLabel];
//    fourLabel.textColor = [UIColor colorWithHexString:@"666666"];
//
//
//    UIImageView *seccondImageview = [[UIImageView alloc]initWithFrame:CGRectMake(20*SCALEW,fourLabel.bounds.size.height+fourLabel.frame.origin.y+8*SCALEW, kScreenWidth-40*SCALEW,(kScreenWidth-40*SCALEW)*0.47)];
//    [self.scroller addSubview:seccondImageview];
//    seccondImageview.image = [UIImage imageNamed:@"adddevice_img_sn2"];
//
//
//    UILabel *fiveLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*SCALEW,seccondImageview.bounds.size.height+seccondImageview.frame.origin.y+8*SCALEW,kScreenWidth-40*SCALEW,22*SCALEW)];
//    fiveLabel.text = @"情况二：";
//    fiveLabel.font = [UIFont systemFontOfSize:FontSize(16)];
//    fiveLabel.textColor = [UIColor colorWithHexString:@"666666"];
//
//    [self.scroller addSubview:fiveLabel];
//
//    UIImageView *thirdImageview = [[UIImageView alloc]initWithFrame:CGRectMake(20*SCALEW,fiveLabel.bounds.size.height+fiveLabel.frame.origin.y+8*SCALEW, kScreenWidth-40*SCALEW,(kScreenWidth-40*SCALEW)*0.47)];
//    [self.scroller addSubview:thirdImageview];
//    thirdImageview.image = [UIImage imageNamed:@"adddevice_img_sn3"];
//
////
//    UILabel *sixLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*SCALEW,thirdImageview.bounds.size.height+thirdImageview.frame.origin.y+20*SCALEW,kScreenWidth-40*SCALEW,22*SCALEW)];
//    sixLabel.text = @"• 机型条码在柜机上";
//    sixLabel.font = [UIFont systemFontOfSize:FontSize(16)];
//    [self.scroller addSubview:sixLabel];
//    sixLabel.textColor = [UIColor colorWithHexString:@"666666"];
//    NSRange sixLabelRange = [sixLabel.text rangeOfString:@"柜机"];
//    NSMutableAttributedString *attributedString3 = [[NSMutableAttributedString alloc] initWithString:sixLabel.text];
//    [attributedString3 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:sixLabelRange];
//    sixLabel.attributedText = attributedString3;
//
//
//    UIImageView *fourImageview = [[UIImageView alloc]initWithFrame:CGRectMake(20*SCALEW,sixLabel.bounds.size.height+sixLabel.frame.origin.y+8*SCALEW, kScreenWidth-40*SCALEW,(kScreenWidth-40*SCALEW)*0.47)];
//    [self.scroller addSubview:fourImageview];
//    fourImageview.image = [UIImage imageNamed:@"adddevice_img_sn4"];
//
//
//    UILabel *sevenLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*SCALEW,fourImageview.bounds.size.height+fourImageview.frame.origin.y+20*SCALEW,kScreenWidth-40*SCALEW,22*SCALEW)];
//    sevenLabel.text = @"• 机型条码在包装盒上";
//    sevenLabel.font = [UIFont systemFontOfSize:FontSize(16)];
//    [self.scroller addSubview:sevenLabel];
//    sevenLabel.textColor = [UIColor colorWithHexString:@"666666"];
//    NSRange sevenLabelRange = [sevenLabel.text rangeOfString:@"包装盒"];
//    NSMutableAttributedString *attributedString4 = [[NSMutableAttributedString alloc] initWithString:sevenLabel.text];
//    [attributedString4 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"10BFCA"] range:sevenLabelRange];
//    sevenLabel.attributedText = attributedString4;
//
//    UIImageView *fiveImageview = [[UIImageView alloc]initWithFrame:CGRectMake(20*SCALEW,sevenLabel.bounds.size.height+sevenLabel.frame.origin.y+8*SCALEW, kScreenWidth-40*SCALEW,(kScreenWidth-40*SCALEW)*0.47)];
//    [self.scroller addSubview:fiveImageview];
//    fiveImageview.image = [UIImage imageNamed:@"adddevice_img_sn5"];
    self.scroller.contentSize = CGSizeMake(kScreenWidth, thirdImageview.bounds.size.height+thirdImageview.frame.origin.y+80);
    
}

@end
