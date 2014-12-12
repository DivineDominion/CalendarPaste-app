//
//  ShiftTemplateController.m
//  ShiftCal
//
//  Created by Christian Tietze on 03.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplateController.h"
#import "AppDelegate.h"

#define DATABASE_PATH @"database.sqlite"

// Class-level global
static NSString *kShiftEntityName = @"ShiftTemplate";

@interface ShiftTemplateController ()
@property (strong, nonatomic, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic, readwrite) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;
@end

@implementation ShiftTemplateController

#pragma mark - Instance methods

- (instancetype)init
{
    self = [super init];

#ifdef ADD_PRESET_SHIFTS
    if (self)
    {
        [self loadModel];
    }
#endif
    
    return self;
}

- (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSUInteger)countOfShiftEntities
{    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kShiftEntityName
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];

    NSError *error = nil;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:request error:&error];
    NSAssert(count != NSNotFound, @"Could not count shifts, error: %@", error);
    
    return count;
}

#ifdef ADD_PRESET_SHIFTS
- (void)loadModel
{
    // Populate DB on first/empty starts 
    if ([self countOfShiftEntities] == 0)
    {
        [self generateTestObjects];
    }
}

- (void)generateTestObjects
{
    ShiftTemplate *shift = nil;
    
    shift = (ShiftTemplate *)[NSEntityDescription insertNewObjectForEntityForName:kShiftEntityName
                                                           inManagedObjectContext:self.managedObjectContext];
    
    shift.title        = @"Work Shift";
    shift.durHours     = [NSNumber numberWithInt:4];
    shift.durMinutes   = [NSNumber numberWithInt:30];
    shift.displayOrder = [NSNumber numberWithInt:0];
    shift.location     = @"23 Savile Row, London";
    
    shift = (ShiftTemplate *)[NSEntityDescription insertNewObjectForEntityForName:kShiftEntityName
                                                           inManagedObjectContext:self.managedObjectContext];
    
    shift.title        = @"Team Meeting";
    shift.durHours     = [NSNumber numberWithInt:2];
    shift.durMinutes   = [NSNumber numberWithInt:0];
    shift.displayOrder = [NSNumber numberWithInt:1];
    
    shift = (ShiftTemplate *)[NSEntityDescription insertNewObjectForEntityForName:kShiftEntityName
                                                           inManagedObjectContext:self.managedObjectContext];
    
    shift.title        = @"Training";
    shift.durHours     = [NSNumber numberWithInt:1];
    shift.durMinutes   = [NSNumber numberWithInt:30];
    shift.displayOrder = [NSNumber numberWithInt:2];
    shift.location     = @"15 Baker Street, London";
    
    shift = (ShiftTemplate *)[NSEntityDescription insertNewObjectForEntityForName:kShiftEntityName
                                                           inManagedObjectContext:self.managedObjectContext];

    shift.title        = @"Pomodoro";
    shift.durHours     = [NSNumber numberWithInt:0];
    shift.durMinutes   = [NSNumber numberWithInt:45];
    shift.displayOrder = [NSNumber numberWithInt:3];

    shift = (ShiftTemplate *)[NSEntityDescription insertNewObjectForEntityForName:kShiftEntityName
                                                           inManagedObjectContext:self.managedObjectContext];
    
    shift.title        = @"On call";
    shift.durHours     = [NSNumber numberWithInt:1];
    shift.durMinutes   = [NSNumber numberWithInt:30];
    shift.allDay       = [NSNumber numberWithBool:YES];
    shift.displayOrder = [NSNumber numberWithInt:4];
    shift.location     = @"Home";
    
    
    NSError *error = nil;
    BOOL success   = [self.managedObjectContext save:&error];
    NSAssert(success, @"Could not save shift, error: %@", error);
}
#endif

#pragma mark - Import/export utilities

- (NSMutableDictionary *)attributeDictionaryForShift:(ShiftTemplate *)shift
{
    NSMutableDictionary *attributes = nil;
    
    NSArray *attributeKeys = [[[shift entity] attributesByName] allKeys];
    attributes = [NSMutableDictionary dictionaryWithDictionary:[shift dictionaryWithValuesForKeys:attributeKeys]];
    
    return attributes;
}

- (NSMutableDictionary *)attributeDictionary
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kShiftEntityName
                                              inManagedObjectContext:self.managedObjectContext];
    NSArray *attributeKeys = [[entity attributesByName] allKeys];
    
    for (NSString *key in attributeKeys)
    {
        [attributes setValue:nil forKey:key];
    }
    
    return attributes;
}

- (NSMutableDictionary *)defaultAttributeDictionary
{
    NSMutableDictionary *attributes = [self attributeDictionary];
    NSDictionary *defaultAttributes = [ShiftTemplate defaultAttributes];
    
    [attributes setValuesForKeysWithDictionary:defaultAttributes];
    
    return attributes;
}

- (ShiftTemplate *)importShiftByAttributeDictionary:(NSDictionary *)attributes
{
    ShiftTemplate *shift = [self createShift];
    
    [shift setValuesForKeysWithDictionary:attributes];
    
    return shift;
}

- (ShiftTemplate *)importShift:(NSManagedObject *)foreignShift
{
    NSArray *attKeys         = [[[foreignShift entity] attributesByName] allKeys];
    NSDictionary *attributes = [foreignShift dictionaryWithValuesForKeys:attKeys];
    
    return [self importShiftByAttributeDictionary:attributes];
}

#pragma mark - CR(U)D

- (ShiftTemplate *)createShift
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kShiftEntityName inManagedObjectContext:context];
    
    ShiftTemplate *shift = [[ShiftTemplate alloc] initWithEntity:entityDescription
                    insertIntoManagedObjectContext:context];
    
    return shift;
}

- (ShiftTemplate *)shiftWithId:(NSManagedObjectID *)shiftId
{
    NSError *error = nil;
    ShiftTemplate *shift = (ShiftTemplate *)[self.managedObjectContext existingObjectWithID:shiftId error:&error];
    
    NSAssert(shift, @"Could not retrieve object by ID, error: %@", error);
    
    return shift;
}

- (void)deleteShift:(ShiftTemplate *)shift
{
    [self.managedObjectContext deleteObject:shift];
}

- (NSArray *)shifts
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kShiftEntityName
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSAssert(fetchResults, @"Could not retrieve model data, error: %@", error);

    return fetchResults;
}

- (BOOL)saveManagedObjectContext
{
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, @"Could not persist changes, error: %@", error);
    return success;
}

#pragma mark - Core Data wrapper

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
    if (coordinator)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *documentsDir = [self documentsDirectory];
    NSURL *storeUrl     = [documentsDir URLByAppendingPathComponent:DATABASE_PATH];
    NSError *error      = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES};
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
    {
        StupidError(@"error while initializing persistentStoreCoordinator: %@", error.localizedDescription);
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel)
    {
        return _managedObjectModel;
    }
    
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

@end
