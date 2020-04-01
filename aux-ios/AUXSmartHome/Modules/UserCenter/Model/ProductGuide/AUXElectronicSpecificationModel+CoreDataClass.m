//
//  AUXElectronicSpecificationModel+CoreDataClass.m
//  
//
//  Created by AUX on 2019/7/11.
//
//

#import "AUXElectronicSpecificationModel+CoreDataClass.h"

@implementation AUXElectronicSpecificationModel
+ (NSMutableArray<AUXElectronicSpecificationModel *> *)convertToDBModelList:(NSArray *)modelList{
    
    NSMutableArray *dataArray = [[NSMutableArray alloc]init];
    
   
    for (NSDictionary *dic in modelList) {
        AUXElectronicSpecificationModel *dbModel = [AUXElectronicSpecificationModel MR_createEntity];
        dbModel.deviceType = dic[@"deviceType"];
        dbModel.instruction = dic[@"instruction"];
         BOOL isContent = NO;
        for (AUXElectronicSpecificationModel *tmpdbModel in dataArray) {
            if ([tmpdbModel.deviceType isEqualToString:dbModel.deviceType]) {
                isContent = YES;
            }
        }
        if (!isContent) {
           [dataArray addObject:dbModel];
        }
    }
    return dataArray;
}
@end
