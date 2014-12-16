//
//  TestUserDefaults.m
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "TestUserDefaults.h"

@implementation TestUserDefaults

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _defaultsStub = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)objectForKey:(NSString *)defaultName {
    return self.defaultsStub[defaultName];
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
    if (value == nil) {
        value = [NSNull null];
    }
    
    self.defaultsStub[defaultName] = value;
}

- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName {
    [self setObject:url forKey:defaultName];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
}

- (void)synchronize { /* no op */ }

@end
