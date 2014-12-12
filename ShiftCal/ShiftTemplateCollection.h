//
//  ShiftTemplateCollection.h
//  ShiftCal
//
//  Created by Christian Tietze on 03.10.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShiftTemplateController.h"

@interface ShiftTemplateCollection : NSObject
@property (nonatomic, strong) ShiftTemplateController *shiftTemplateController;
@property (nonatomic, strong) NSMutableArray *shifts;
@property (nonatomic, readonly) NSUInteger countOfShifts;
@property (nonatomic, getter=isEmpty, readonly) BOOL empty;

- (instancetype)initWithShiftTemplateController:(ShiftTemplateController *)shiftTemplateController;
- (instancetype)initWithFallbackCalendarIdentifier:(NSString *)fallbackCalendarIdentifier shiftTemplateController:(ShiftTemplateController *)shiftTemplateController NS_DESIGNATED_INITIALIZER;

- (ShiftTemplate *)shiftAtIndex:(NSUInteger)index;
- (NSInteger)addShiftWithAttributes:(NSDictionary *)shiftAttributes;
- (void)removeShiftAtIndex:(NSUInteger)index;
- (void)updateShiftAtIndex:(NSUInteger)index withAttributes:(NSDictionary *)shiftAttributes;
- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to;
- (void)persistOrder;

- (void)resetInvalidCalendarsTo:(NSString *)defaultCalendarIdentifier;
- (void)resetInvalidCalendarsTo:(NSString *)defaultCalendarIdentifier onChanges:(void (^)(void))changeBlock;

@end

