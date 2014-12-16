//
//  CoreDataWiringTest.m
//  TapTest
//
//  Created by Christian Tietze on 09.05.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "CoreDataStackTestCase.h"


//@interface CoreDataWiringTest : CoreDataStackTestCase
//@end
//
//@implementation CoreDataWiringTest
//
//- (void)setUp
//{
//    [super setUp];
//}
//
//- (void)tearDown
//{
//    [super tearDown];
//}
//
//- (void)testConvenienceInserting {
//    CTTTapRecord *tapRecord = [CTTTapRecord insertTapRecordWithLeftHandScore:123 rightHandScore:456 inManagedObjectContext:self.context];
//    
//    assertThat(tapRecord.leftHandScore, equalTo(@123));
//    assertThat(tapRecord.rightHandScore, equalTo(@456));
//}
//
//- (void)testInserting_AddsAnObjectToTheContext {
//    CTTTapRecord *tapRecord = [CTTTapRecord insertTapRecordWithLeftHandScore:123 rightHandScore:456 inManagedObjectContext:self.context];
//
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:[CTTTapRecord entityDescriptionInManagedObjectContext:self.context]];
//    NSError *error;
//    NSArray *results = [self.context executeFetchRequest:request error:&error];
//
//    assertThat(@(results.count), is(equalTo(@1)));
//    CTTTapRecord *result = results.firstObject;
//    assertThat(result.leftHandScore, equalTo(tapRecord.leftHandScore));
//    assertThat(result.rightHandScore, equalTo(tapRecord.rightHandScore));
//}
//
//
//@end
