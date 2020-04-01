//
//  AUXLaunchAdModel.m
//  AUXSmartHome
//
//  Created by AUX Group Co., Ltd on 2019/1/14.
//  Copyright © 2019年 AUX Group Co., Ltd. All rights reserved.
//

#import "AUXLaunchAdModel.h"

static NSString* const kAUXAdvertisementId = @"advertisementId";
static NSString* const kAUXDuration = @"duration";
static NSString* const kAUXShowFinishAnimateTime = @"showFinishAnimateTime";
static NSString* const kAUXImageBannerURLString = @"kAUXImageBannerURLString";
static NSString* const kAUXGIFImageCycleOnce = @"GIFImageCycleOnce";
static NSString* const kAUXVideoURLString = @"videoURLString";
static NSString* const kAUXVideoCycleOnce = @"videoCycleOnce";
static NSString* const kAUXStartTime = @"startTime";
static NSString* const kAUXEndTime = @"endTime";
static NSString* const kAUXIsCanClick = @"isCanClick";
static NSString* const kAUXClickStartTime = @"clickStartTime";
static NSString* const kAUXClickEndTime = @"clickEndTime";
static NSString* const kAUXSourceValue = @"sourceValue";
static NSString* const kAUXLinkedUrl = @"linkedUrl";
static NSString* const kAUXSourceType = @"sourceType";

@implementation AUXLaunchAdModel

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self) {
        self.advertisementId = [aDecoder decodeObjectForKey:kAUXAdvertisementId];
        self.duration = [[aDecoder decodeObjectForKey:kAUXDuration] integerValue];
        self.showFinishAnimateTime = [[aDecoder decodeObjectForKey:kAUXShowFinishAnimateTime] boolValue];
        self.imageBannerURLString = [aDecoder decodeObjectForKey:kAUXImageBannerURLString];
        self.GIFImageCycleOnce = [[aDecoder decodeObjectForKey:kAUXGIFImageCycleOnce] boolValue];
        self.videoURLString = [aDecoder decodeObjectForKey:kAUXVideoURLString];
        self.videoCycleOnce = [[aDecoder decodeObjectForKey:kAUXVideoCycleOnce] boolValue];
        self.startTime = [[aDecoder decodeObjectForKey:kAUXStartTime] longLongValue];
        self.endTime = [[aDecoder decodeObjectForKey:kAUXEndTime] longLongValue];
        self.isCanClick = [[aDecoder decodeObjectForKey:kAUXIsCanClick] boolValue];
        self.clickStartTime = [[aDecoder decodeObjectForKey:kAUXClickStartTime] longLongValue];
        self.clickEndTime = [[aDecoder decodeObjectForKey:kAUXClickEndTime] longLongValue];
        self.sourceValue = [aDecoder decodeObjectForKey:kAUXSourceValue];
        self.linkedUrl = [aDecoder decodeObjectForKey:kAUXLinkedUrl];
        self.sourceType = [aDecoder decodeObjectForKey:kAUXSourceType];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.advertisementId forKey:kAUXAdvertisementId];
    [aCoder encodeObject:@(self.duration) forKey:kAUXDuration];
    [aCoder encodeObject:@(self.showFinishAnimateTime) forKey:kAUXShowFinishAnimateTime];
    [aCoder encodeObject:@(self.GIFImageCycleOnce) forKey:kAUXGIFImageCycleOnce];
    [aCoder encodeObject:@(self.videoCycleOnce) forKey:kAUXVideoCycleOnce];
    [aCoder encodeObject:self.imageBannerURLString forKey:kAUXImageBannerURLString];
    [aCoder encodeObject:@(self.startTime) forKey:kAUXStartTime];
    [aCoder encodeObject:@(self.endTime) forKey:kAUXEndTime];
    [aCoder encodeObject:self.videoURLString forKey:kAUXVideoURLString];
    [aCoder encodeObject:@(self.isCanClick) forKey:kAUXIsCanClick];
    [aCoder encodeObject:@(self.clickStartTime) forKey:kAUXClickStartTime];
    [aCoder encodeObject:@(self.clickEndTime) forKey:kAUXClickEndTime];
    [aCoder encodeObject:self.sourceValue forKey:kAUXSourceValue];
    [aCoder encodeObject:self.linkedUrl forKey:kAUXLinkedUrl];
    [aCoder encodeObject:self.sourceType forKey:kAUXSourceType];
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
