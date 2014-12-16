//
//  CoreDataStackTestCase.m
//  TapTest
//
//  Created by Christian Tietze on 13.05.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "CoreDataStackTestCase.h"

@interface CoreDataStackTestCase ()
@property (nonatomic, copy, readwrite) NSString *modelName;
@end

@implementation CoreDataStackTestCase

- (void)setUpWithModelName:(NSString *)modelName {
    [super setUp];
    self.modelName = modelName;
}

- (void)setUp {
    [self setUpWithModelName:@"ShiftTemplates"];
    
    [self setUpContext];
    XCTAssertNotNil(self.context, @"Core Data context should have been initialized");
}

- (void)setUpContext {
    NSParameterAssert(self.modelName);
    
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *modelURL = [bundle URLForResource:self.modelName withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    XCTAssert(model, @"model should exist");
    NSPersistentStoreCoordinator *coord = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSError *error;
    NSPersistentStore *store = [coord addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error];
    XCTAssert(store, @"store not created: %@",  error);
    
    [self.context setPersistentStoreCoordinator:coord];
}

- (void)tearDown {
    _context = nil;
    
    [super tearDown];
}
@end
