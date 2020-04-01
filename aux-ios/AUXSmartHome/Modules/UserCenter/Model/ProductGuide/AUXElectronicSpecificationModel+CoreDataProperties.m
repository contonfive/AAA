//
//  AUXElectronicSpecificationModel+CoreDataProperties.m
//  
//
//  Created by AUX on 2019/7/11.
//
//

#import "AUXElectronicSpecificationModel+CoreDataProperties.h"

@implementation AUXElectronicSpecificationModel (CoreDataProperties)

+ (NSFetchRequest<AUXElectronicSpecificationModel *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"AUXElectronicSpecificationModel"];
}

@dynamic deviceType;
@dynamic instruction;

@end
