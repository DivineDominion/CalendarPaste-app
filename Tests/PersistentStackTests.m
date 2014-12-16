//
//  PersistentStackTests.m
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PersistentStack.h"

@interface TestPersistentStack : PersistentStack
@end
@implementation TestPersistentStack
- (NSDictionary *)defaultStoreOptions
{
    return nil; // Prevents iCloud usage
}
@end

@interface PersistentStackTests : XCTestCase
@property (strong) PersistentStack *persistentStack;
@end

@implementation PersistentStackTests
- (void)setUp
{
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"ShiftTemplates" withExtension:@"momd"];
    NSURL* storeURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"test.sqlite"]];
    self.persistentStack = [[TestPersistentStack alloc] initWithStoreURL:storeURL modelURL:modelURL];
}

- (void)tearDown
{
    _persistentStack = nil;
}

- (void)testInitializer
{
    XCTAssertNotNil(self.persistentStack, @"Should have a persistent stack");
}

- (void)testManagedObjectContextSetUp
{
    XCTAssertNotNil(self.persistentStack.managedObjectContext, @"Should have a managed object context");
    XCTAssertNotNil(self.persistentStack.managedObjectContext.persistentStoreCoordinator, @"Should have a persistent store coordinator");
    NSPersistentStore* store = self.persistentStack.managedObjectContext.persistentStoreCoordinator.persistentStores[0];
    XCTAssertNotNil(store, @"Should have a persistent store");
    XCTAssertEqualObjects(store.type, NSSQLiteStoreType, @"Should be a sqlite store");
    XCTAssertNotNil(self.persistentStack.managedObjectContext.undoManager, @"Should have an undo manager");
}

- (NSManagedObjectContext *)context
{
    return self.persistentStack.managedObjectContext;
}

//- (void)testWillSaveNotification_ChangesModificationDateOfNewItems {
//    CTTTapRecord *tapRecord = [CTTTapRecord insertTapRecordWithLeftHandScore:123 rightHandScore:456 inManagedObjectContext:[self context]];
//    assertThat(tapRecord.modificationDate, is(nilValue()));
//    
//    [self.persistentStack objectContextWillSave:nil];
//    
//    assertThat(tapRecord.modificationDate, is(notNilValue()));
//}
//
//- (void)testWillSaveNotification_DoesntChangeModificationDateOfSavedItems {
//    CTTTapRecord *tapRecord = [CTTTapRecord insertTapRecordWithLeftHandScore:123 rightHandScore:456 inManagedObjectContext:[self context]];
//    NSDate *pastModificationDate = [NSDate dateWithTimeIntervalSince1970:400];
//    tapRecord.modificationDate = pastModificationDate;
//    assertThatBool([self.persistentStack.managedObjectContext save:NULL], equalToBool(YES));
//    
//    [self.persistentStack objectContextWillSave:nil];
//    
//    assertThat(tapRecord.modificationDate, is(equalTo(pastModificationDate)));
//}
//
//- (void)testWillSaveNotification_ChangesModificationDateOfUpdatedItems {
//    CTTTapRecord *tapRecord = [CTTTapRecord insertTapRecordWithLeftHandScore:123 rightHandScore:456 inManagedObjectContext:[self context]];
//    NSDate *pastModificationDate = [NSDate dateWithTimeIntervalSince1970:400];
//    tapRecord.modificationDate = pastModificationDate;
//    assertThatBool([[self context] save:NULL], equalTo(@YES));
//    
//    assertThatBool([[self context] hasChanges], equalTo(@NO));
//    tapRecord.leftHandScore = @50;
//    assertThatBool([[self context] hasChanges], equalTo(@YES));
//    
//    [self.persistentStack objectContextWillSave:nil];
//    
//    NSDate *newModificationDate = tapRecord.modificationDate;
//    assertThat(newModificationDate, isNot(equalTo(pastModificationDate)));
//    assertThat([newModificationDate laterDate:pastModificationDate], equalTo(newModificationDate));
//}

@end
