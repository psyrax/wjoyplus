//
//  WiimoteBatteryPart.h
//  Wiimote
//
//  Created by alxn1 on 30.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimotePart.h"

@interface WiimoteBatteryPart : WiimotePart
{
    @private
        double  m_Level;
        BOOL    m_IsLow;
}

- (double)batteryLevel;
- (BOOL)isBatteryLevelLow;

@end
