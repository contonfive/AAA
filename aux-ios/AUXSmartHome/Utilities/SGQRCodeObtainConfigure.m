//
//  SGQRCodeObtainConfigure.m
//  SGQRCodeExample
//
//  Created by kingsic on 2018/7/29.
//  Copyright © 2018年 kingsic. All rights reserved.
//

#import "SGQRCodeObtainConfigure.h"

@implementation SGQRCodeObtainConfigure

+ (instancetype)QRCodeObtainConfigure {
    return [[self alloc] init];
}

- (NSArray *)metadataObjectTypes {
    if (!_metadataObjectTypes) {
        _metadataObjectTypes = @[AVMetadataObjectTypeUPCECode,
                                 AVMetadataObjectTypeCode39Code,
                                 AVMetadataObjectTypeCode39Mod43Code,
                                 AVMetadataObjectTypeEAN13Code,
                                 AVMetadataObjectTypeEAN8Code,
                                 AVMetadataObjectTypeCode93Code,
                                 AVMetadataObjectTypeCode128Code,
                                 AVMetadataObjectTypePDF417Code,
                                 AVMetadataObjectTypeQRCode,
                                 AVMetadataObjectTypeAztecCode,
                                 AVMetadataObjectTypeInterleaved2of5Code,
                                 AVMetadataObjectTypeITF14Code,
                                 AVMetadataObjectTypeDataMatrixCode];
    }
    return _metadataObjectTypes;
}

@end
