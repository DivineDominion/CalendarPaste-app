//
//  PersistentStack.h
//  ShiftCal via TapTest
//
//  Created by Christian Tietze on 10.05.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PersistentStack : NSObject
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)persistentStack;

- (instancetype)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL;
- (void)objectContextWillSave:(NSNotification *)notification;
@end
