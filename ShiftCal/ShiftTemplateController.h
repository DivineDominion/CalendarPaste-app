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

extern NSString * const kShiftEntityName;

@interface ShiftTemplateController : NSObject
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext NS_DESIGNATED_INITIALIZER;

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
