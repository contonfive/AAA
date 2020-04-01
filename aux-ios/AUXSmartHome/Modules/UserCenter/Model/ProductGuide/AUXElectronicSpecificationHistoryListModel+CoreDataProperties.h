//
//  AUXElectronicSpecificationHistoryListModel+CoreDataProperties.h
//  
//
//  Created by AUX on 2019/7/11.
//
//

#import "AUXElectronicSpecificationHistoryListModel+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUXElectronicSpecificationHistoryListModel (CoreDataProperties)

+ (NSFetchRequest<AUXElectronicSpecificationHistoryListModel *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *date;
@property (nullable, nonatomic, copy) NSString *deviceType;

@end

NS_ASSUME_NONNULL_END
