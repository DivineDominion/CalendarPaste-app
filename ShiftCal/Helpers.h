//
//  Helpers.h
//  ShiftCal
//
//  Created by Christian Tietze on 14/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#ifndef ShiftCal_Helpers_h
#define ShiftCal_Helpers_h

    #define StupidError(...) [NSException raise:@"StudipError" format:__VA_ARGS__];
    #define IS_4INCH_DISPLAY [[UIScreen mainScreen] bounds].size.height == 568.0f


#endif
