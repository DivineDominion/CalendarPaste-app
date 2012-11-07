//
//  Macros.h
//  ShiftCal
//
//  Created by Christian Tietze on 31.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#ifndef ShiftCal_Macros_h
#define ShiftCal_Macros_h

    #define StupidError(...) [NSException raise:@"StudipError" format:__VA_ARGS__];

    #define DEVELOPMENT

    #define PREFS_DEFAULT_CALENDAR_KEY @"DefaultCalendar"

#endif
