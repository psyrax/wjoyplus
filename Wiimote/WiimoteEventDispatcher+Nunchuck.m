//
//  WiimoteEventDispatcher+Nunchuck.m
//  Wiimote
//
//  Created by alxn1 on 31.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteEventDispatcher+Nunchuck.h"

@implementation WiimoteEventDispatcher (Nunchuck)

- (void)postNunchuck:(WiimoteNunchuckExtension*)nunchuck buttonPressed:(WiimoteNunchuckButtonType)button
{
    [[self delegate] wiimote:[self owner] nunchuck:nunchuck buttonPressed:button];

    if([self isStateNotificationsEnabled])
    {
        [self postNotification:WiimoteNunchuckButtonPressedNotification
                         param:[NSNumber numberWithInteger:button]
                           key:WiimoteNunchuckButtonKey
                        sender:nunchuck];
    }
}

- (void)postNunchuck:(WiimoteNunchuckExtension*)nunchuck buttonReleased:(WiimoteNunchuckButtonType)button
{
    [[self delegate] wiimote:[self owner] nunchuck:nunchuck buttonReleased:button];

    if([self isStateNotificationsEnabled])
    {
        [self postNotification:WiimoteNunchuckButtonReleasedNotification
                         param:[NSNumber numberWithInteger:button]
                           key:WiimoteNunchuckButtonKey
                        sender:nunchuck];
    }
}

- (void)postNunchuck:(WiimoteNunchuckExtension*)nunchuck stickPositionChanged:(NSPoint)position
{
    [[self delegate] wiimote:[self owner] nunchuck:nunchuck stickPositionChanged:position];

    if([self isStateNotificationsEnabled])
    {
        [self postNotification:WiimoteNunchuckStickPositionChangedNotification
                         param:[NSValue valueWithPoint:position]
                           key:WiimoteNunchuckStickPositionKey
                        sender:nunchuck];
    }
}

- (void)postNunchuck:(WiimoteNunchuckExtension*)nunchuck accelerometerEnabledStateChanged:(BOOL)enabled
{
    [[self delegate] wiimote:[self owner] nunchuck:nunchuck accelerometerEnabledStateChanged:enabled];

    [self postNotification:WiimoteNunchuckAccelerometerEnabledStateChangedNotification
                     param:[NSNumber numberWithBool:enabled]
                       key:WiimoteNunchuckAccelerometerEnabledStateKey
                    sender:nunchuck];
}

- (void)postNunchuck:(WiimoteNunchuckExtension*)nunchuck accelerometerChangedGravityX:(double)x y:(double)y z:(double)z
{
    [[self delegate] wiimote:[self owner] nunchuck:nunchuck accelerometerChangedGravityX:x y:y z:z];

    if(![self isStateNotificationsEnabled])
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithDouble:x],
                                        WiimoteNunchuckAccelerometerGravityX,
                                    [NSNumber numberWithDouble:y],
                                        WiimoteNunchuckAccelerometerGravityY,
                                    [NSNumber numberWithDouble:z],
                                        WiimoteNunchuckAccelerometerGravityZ,
                                    nil];

        [self postNotification:WiimoteNunchuckAccelerometerGravityChangedNotification
                        params:params
                        sender:nunchuck];
    }
}

- (void)postNunchuck:(WiimoteNunchuckExtension*)nunchuck accelerometerChangedPitch:(double)pitch roll:(double)roll
{
    [[self delegate] wiimote:[self owner] nunchuck:nunchuck accelerometerChangedPitch:pitch roll:roll];

    if(![self isStateNotificationsEnabled])
    {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithDouble:roll],
                                        WiimoteNunchuckAccelerometerRoll,
                                    [NSNumber numberWithDouble:pitch],
                                        WiimoteNunchuckAccelerometerPitch,
                                    nil];

        [self postNotification:WiimoteNunchuckAccelerometerAnglesChangedNotification
                        params:params
                        sender:nunchuck];
    }
}

@end
