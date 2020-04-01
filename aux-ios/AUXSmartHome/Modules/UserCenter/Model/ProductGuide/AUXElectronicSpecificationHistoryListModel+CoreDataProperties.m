//
//  AUXElectronicSpecificationHistoryListModel+CoreDataProperties.m
//  
//
//  Created by AUX on 2019/7/11.
//
//

#import "AUXElectronicSpecificationHistoryListModel+CoreDataProperties.h"

@implementation AUXElectronicSpecificationHistoryListModel (CoreDataProperties)

+ (NSFetchRequest<AUXElectronicSpecificationHistoryListModel *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AUXElectronicSpecificationHistoryListModel"];
}

@dynamic date;
@dynamic deviceType;

@end
