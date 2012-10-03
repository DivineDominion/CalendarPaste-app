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
    
    if (self)
    {
        [self loadModel];
    }
    
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
    
    return count;
}

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
    
    for (NSInteger i = 0; i < 5; i++)
    {
        shift = (ShiftTemplate *)[NSEntityDescription insertNewObjectForEntityForName:kShiftEntityName
                                                               inManagedObjectContext:self.managedObjectContext];
        
        shift.title      = [NSString stringWithFormat:@"Test %d", i];
        shift.durHours   = [NSNumber numberWithInt:2];
        shift.durMinutes = [NSNumber numberWithInt:34];
    }
    
    NSError *error = nil;
    BOOL success   = [self.managedObjectContext save:&error];
    NSAssert(success, @"Could not save shift, error: %@", error);
}

#pragma mark - Data

- (ShiftTemplate *)createShift
{
    ShiftTemplate *shift = nil;
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:kShiftEntityName inManagedObjectContext:context];
    
    shift = [[ShiftTemplate alloc] initWithEntity:entityDescription
                    insertIntoManagedObjectContext:context];
    
    return [shift autorelease];
}

- (ShiftTemplate *)importShift:(NSManagedObject *)foreignShift
{
    // TODO find out appropriate position
    ShiftTemplate *shift = [[self createShift] retain];
    
    NSArray *attKeys         = [[[foreignShift entity] attributesByName] allKeys];
    NSDictionary *attributes = [foreignShift dictionaryWithValuesForKeys:attKeys];
    [shift setValuesForKeysWithDictionary:attributes];
    
    NSError *error = nil;
    BOOL success = [self.managedObjectContext save:&error];
    NSAssert(success, @"Could not import, error: %@", error);
    
    return [shift autorelease];
}

- (ShiftTemplate *)shiftWithId:(NSManagedObjectID *)shiftId
{
    NSError *error = nil;
    ShiftTemplate *shift = (ShiftTemplate *)[self.managedObjectContext existingObjectWithID:shiftId error:&error];
    
    NSAssert(shift, @"Could not retrieve object by ID, error: %@", error);
    
    return shift;
}

- (NSArray *)shifts
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:kShiftEntityName
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSAssert(fetchResults, @"Could not retrieve model data, error: %@", error);

    [request release];
    return fetchResults;
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
