//
//  ShiftTemplateControllerTests.m
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CoreDataStackTestCase.h"

#import "ShiftTemplateController.h"

@interface ShiftTemplateControllerTests : CoreDataStackTestCase
@end

@implementation ShiftTemplateControllerTests
{
    NSURL *storeURL;
    ShiftTemplateController *controller;
}

- (void)setUp {
    [super setUp];
    
    controller = [[ShiftTemplateController alloc] initWithManagedObjectContext:self.context];
}

- (void)testInitialization {
    XCTAssertNotNil(controller);
}

@end

