//
//  AUXElectronicSpecificationModel+CoreDataClass.h
//  
//
//  Created by AUX on 2019/7/11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MagicalRecord/MagicalRecord.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUXElectronicSpecificationModel : NSManagedObject
+ (NSMutableArray<AUXElectronicSpecificationModel *> *)convertToDBModelList:(NSArray *)modelList;
@end

NS_ASSUME_NONNULL_END

#import "AUXElectronicSpecificationModel+CoreDataProperties.h"
