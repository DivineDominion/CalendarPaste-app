//
//  PersistentStack.m
//  ShiftCal via TapTest
//
//  Created by Christian Tietze on 10.05.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "PersistentStack.h"

@interface PersistentStack ()
@property (nonatomic, strong, readwrite) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSURL* modelURL;
@property (nonatomic, strong) NSURL* storeURL;
@end

@implementation PersistentStack

+ (instancetype)persistentStack
{
    NSURL *storeURL = [self documentsDirectory];
    NSURL *modelURL = nil; // TODO replace with URL instead of merged OM
    return [[self alloc] initWithStoreURL:storeURL modelURL:modelURL];
}

+ (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (instancetype)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL
{
    NSParameterAssert(storeURL);
    
    self = [super init];
    
    if (self)
    {
        _storeURL = storeURL;
        _modelURL = modelURL;
        [self setupManagedObjectContext];
    }
    
    return self;
}

- (void)setupManagedObjectContext
{
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.managedObjectContext.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    NSError *error;
    NSDictionary *storeOptions = [self defaultStoreOptions];
    [self.managedObjectContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.storeURL options:storeOptions error:&error];
    if (error)
    {
        NSLog(@"error: %@", error);
    }
    
    self.managedObjectContext.undoManager = [[NSUndoManager alloc] init];
}

- (NSDictionary *)defaultStoreOptions
{
    return @{NSPersistentStoreUbiquitousContentNameKey: @"Calendar-Paste",
             NSMigratePersistentStoresAutomaticallyOption : @YES,
             NSInferMappingModelAutomaticallyOption : @YES};
}

- (NSManagedObjectModel*)managedObjectModel
{
    return [NSManagedObjectModel mergedModelFromBundles:nil];
//    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    return self.managedObjectContext.persistentStoreCoordinator;
}

- (void)objectContextWillSave:(NSNotification *)notification
{
#warning TODO add updated-at date
//    NSManagedObjectContext* context = self.managedObjectContext;
//    NSSet* allModified = [context.insertedObjects setByAddingObjectsFromSet: context.updatedObjects];
//    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
//        return [evaluatedObject respondsToSelector:@selector(modificationDate)];
//    }];
//    NSSet* modifiable = [allModified filteredSetUsingPredicate:predicate];
//    [modifiable makeObjectsPerformSelector:@selector(setModificationDate:)
//                                withObject:[NSDate date]];
}
@end
