//
//  AUXElectronicSpecificationModel+CoreDataProperties.h
//  
//
//  Created by AUX on 2019/7/11.
//
//

#import "AUXElectronicSpecificationModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXElectronicSpecificationModel (CoreDataProperties)

+ (NSFetchRequest<AUXElectronicSpecificationModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *deviceType;
@property (nullable, nonatomic, copy) NSString *instruction;

@end

NS_ASSUME_NONNULL_END
