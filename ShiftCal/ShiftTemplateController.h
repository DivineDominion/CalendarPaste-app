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
{
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectModel         *_managedObjectModel;
    NSManagedObjectContext       *_managedObjectContext;
}

@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, readonly) NSManagedObjectContext       *managedObjectContext;

+ (NSString *)durationTextForHours:(NSInteger)hours andMinutes:(NSInteger)minutes;

- (ShiftTemplate *)createShift;
- (ShiftTemplate *)importShift:(NSManagedObject *)foreignShift;
- (ShiftTemplate *)importShiftByAttributeDictionary:(NSDictionary *)attributes;
- (NSMutableDictionary *)attributeDictionaryForShift:(ShiftTemplate *)shift;
- (NSMutableDictionary *)attributeDictionary;
- (ShiftTemplate *)shiftWithId:(NSManagedObjectID *)shiftId;
- (void)deleteShift:(ShiftTemplate *)shift;
- (NSArray *)shifts;
- (BOOL)saveManagedObjectContext;

@end
