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

#import "AUXDeviceModel.h"
#import <YYModel.h>

@implementation AUXDeviceModel

//- (void)setValueWithDBModel:(AUXDBDeviceModel *)dbModel {
//    self.deviceMainUri = dbModel.deviceMainUri;
//    self.entityUri = dbModel.entityUri;
//    self.feature = dbModel.feature;
//    self.model = dbModel.model;
//    self.modelId = dbModel.modelId;
//    self.suitType = dbModel.suitType;
//    self.useType = dbModel.useType;
//    self.hardwareType = dbModel.hardwareType;
//    self.deviceType = dbModel.deviceType;
//    self.step = dbModel.step;
//    self.stepUri = dbModel.stepUri;
//    self.category = dbModel.categoryType;
//}
//
//+ (NSArray<AUXDBDeviceModel *> *)convertToDBModelList:(NSArray<AUXDeviceModel *> *)modelList {
//    NSMutableArray<AUXDBDeviceModel *> *dbModelList = [[NSMutableArray alloc] init];
//    
//    for (AUXDeviceModel *deviceModel in modelList) {
//        AUXDBDeviceModel *dbModel = [AUXDBDeviceModel MR_createEntity];
//        
//        dbModel.deviceMainUri = deviceModel.deviceMainUri;
//        dbModel.entityUri = deviceModel.entityUri;
//        dbModel.feature = deviceModel.feature;
//        dbModel.model = deviceModel.model;
//        dbModel.modelId = deviceModel.modelId;
//        dbModel.suitType = deviceModel.suitType;
//        dbModel.useType = deviceModel.useType;
//        dbModel.hardwareType = deviceModel.hardwareType;
//        dbModel.deviceType = deviceModel.deviceType;
//        dbModel.step = deviceModel.step;
//        dbModel.stepUri = deviceModel.stepUri;
//        dbModel.categoryType = deviceModel.category;
//        /*
//        switch (deviceModel.suitType) {
//            case AUXDeviceSuitTypeAC:
//                dbModel.suitTypeName = @"单元机";
//                break;
//                
//            default:
//                dbModel.suitTypeName = @"多联机";
//                break;
//        }
//        
//        switch (deviceModel.useType) {
//            case AUXDeviceMachineTypeHang:
//                dbModel.useTypeName = @"挂机";
//                break;
//                
//            default:
//                dbModel.useTypeName = @"柜机";
//                break;
//        } */
//        
//        switch (deviceModel.category) {
//            case AUXDeviceCategoryTypeHang:
//                dbModel.categoryTypeName = @"挂机";
//                break;
//                
//            case AUXDeviceCategoryTypeStand:
//                dbModel.categoryTypeName = @"柜机";
//                break;
//                
//            case AUXDeviceCategoryTypeAC:
//                dbModel.categoryTypeName = @"单元机";
//                break;
//                
//            default:
//                dbModel.categoryTypeName = @"多联机";
//                break;
//        }
//        
//        [dbModelList addObject:dbModel];
//    }
//    
//    return dbModelList;
//}

- (NSString *)description
{
    return [self yy_modelDescription];
}

@end
