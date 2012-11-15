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

@implementation ShiftTemplateController

# pragma mark - Instance methods

- (id)init
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

- (void)dealloc
{
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    [_managedObjectContext release];
    
    [super dealloc];
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
    
    [request release];
    
    return count;
}

#ifdef ADD_PRESET_SHIFTS
- (void)loadModel
{
    // Populate DB on first start
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
    
    return [attributes autorelease];
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
    ShiftTemplate *shift = [[self createShift] retain];
    
    [shift setValuesForKeysWithDictionary:attributes];
    
    return [shift autorelease];
}

- (ShiftTemplate *)importShift:(NSManagedObject *)foreignShift
{
    ShiftTemplate *shift = [[self createShift] retain];
    
    NSArray *attKeys         = [[[foreignShift entity] attributesByName] allKeys];
    NSDictionary *attributes = [foreignShift dictionaryWithValuesForKeys:attKeys];
    [shift setValuesForKeysWithDictionary:attributes];
    
    return [shift autorelease];
}

#pragma mark - CR(U)D

- (ShiftTemplate *)createShift
{
    ShiftTemplate *shift = nil;
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kShiftEntityName inManagedObjectContext:context];
    
    shift = [[ShiftTemplate alloc] initWithEntity:entityDescription
                    insertIntoManagedObjectContext:context];
    
    return [shift autorelease];
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

    [request release];
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
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
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
    
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return _managedObjectModel;
}

# pragma mark - class methods

+ (NSString *)durationTextForHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    NSString *minutesString = @"";
    NSString *hoursString   = [NSString stringWithFormat:@"%dh", hours];
    
    if (minutes > 0) {
        minutesString = [NSString stringWithFormat:@" %dmin", minutes];
        
        if (hours == 0) {
            hoursString = @"";
        }
    }
    
    return [NSString stringWithFormat:@"%@%@", hoursString, minutesString];
}

@end
