//
//  CoreDataStackTestCase.h
//  TapTest
//
//  Created by Christian Tietze on 13.05.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>

@interface CoreDataStackTestCase : XCTestCase
@property (nonatomic, strong, readwrite) NSManagedObjectContext *context;
@property (nonatomic, copy, readonly) NSString *modelName;

- (void)setUpWithModelName:(NSString *)modelName;
@end
