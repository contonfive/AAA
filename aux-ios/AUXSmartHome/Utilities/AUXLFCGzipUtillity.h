//
//  AUXLFCGzipUtillity.h
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2018/6/26.
//  Copyright © 2018年 AUX Group Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "zlib.h"

@interface AUXLFCGzipUtillity : NSObject

/**
 压缩

 @param pUncompressedData 需要要所得数据
 @return 压缩后的数据
 */
+ (NSData *)gzipData:(NSData *)pUncompressedData;
/**
 解压缩数据

 @param compressedData 需要解压缩的数据
 @return 解压缩后的数据
 */
+ (NSData *)uncompressZippedData:(NSData *)compressedData;

@end
