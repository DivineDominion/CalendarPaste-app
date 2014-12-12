//
//  ShiftTemplateController.h
//  ShiftCal
//
//  Created by Christian Tietze on 03.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSMutableArray+MoveArray.h"
#import "ShiftTemplate.h"

@interface ShiftTemplateController : NSObject
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (ShiftTemplate *)importShift:(NSManagedObject *)foreignShift;
- (ShiftTemplate *)importShiftByAttributeDictionary:(NSDictionary *)attributes;
- (NSMutableDictionary *)attributeDictionaryForShift:(ShiftTemplate *)shift;
@property (nonatomic, readonly, copy) NSMutableDictionary *attributeDictionary;
- (NSMutableDictionary *)defaultAttributeDictionary;

@property (nonatomic, readonly, copy) NSArray *shifts;
- (ShiftTemplate *)createShift;
- (void)deleteShift:(ShiftTemplate *)shift;
- (ShiftTemplate *)shiftWithId:(NSManagedObjectID *)shiftId;

- (BOOL)saveManagedObjectContext;

@end
