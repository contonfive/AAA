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

#import "AUXElectricityConsumptionCurvePointModel.h"

@implementation AUXElectricityConsumptionCurvePointModel

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"waveFlatElectricity": @"dval",
             @"dateString": @"dtval"};
}

+ (NSArray<NSString *> *)modelPropertyBlacklist {
    return @[@"totalElectricity"];
}

- (instancetype)copyWithZone:(NSZone *)zone {
    AUXElectricityConsumptionCurvePointModel *pointModel = [[[self class] allocWithZone:zone] init];
    
    pointModel.waveFlatElectricity = self.waveFlatElectricity;
    pointModel.peakElectricity = self.peakElectricity;
    pointModel.valleyElectricity = self.valleyElectricity;
    pointModel.xValue = self.xValue;
    
    return pointModel;
}

- (CGFloat)totalElectricity {
    return self.waveFlatElectricity + self.peakElectricity + self.valleyElectricity;
}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end

