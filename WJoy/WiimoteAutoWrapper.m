//
//  WiimoteAutoWrapper.m
//  WJoy
//
//  Created by alxn1 on 27.07.12.
//  Copyright 2012 alxn1. All rights reserved.
//

#import "WiimoteAutoWrapper.h"

#import <Cocoa/Cocoa.h>

@interface WiimoteAutoWrapper (PrivatePart)

+ (NSString*)wjoyNameFromWiimote:(Wiimote*)device;

+ (void)newWiimoteDeviceNotification:(NSNotification*)notification;

- (id)initWithWiimote:(Wiimote*)device;

@end

@implementation WiimoteAutoWrapper

static NSUInteger maxConnectedDevices = 0;

+ (NSUInteger)maxConnectedDevices
{
    return maxConnectedDevices;
}

+ (void)setMaxConnectedDevices:(NSUInteger)count
{
    if(maxConnectedDevices == count)
        return;

    maxConnectedDevices = count;

    while([[Wiimote connectedDevices] count] > count)
    {
        NSArray  *connectedDevices   = [Wiimote connectedDevices];
        Wiimote  *device             = [connectedDevices objectAtIndex:[connectedDevices count] - 1];

        [device disconnect];
    }
}

+ (void)start
{
    if(![WJoyDevice prepare])
    {
        [[NSApplication sharedApplication] terminate:self];
        return;
    }

    [[Wiimote notificationCenter]
                            addObserver:self
                               selector:@selector(newWiimoteDeviceNotification:)
                                   name:WiimoteConnectedNotification
                                 object:nil];
}

- (void)wiimote:(Wiimote*)wiimote buttonPressed:(WiimoteButtonType)button
{
    if(button>9){
        [self makePointer:button pressing:YES];
        NSLog(@"%u", button);
    }else{
    [m_HIDState setButton:button pressed:YES];
    };
}

- (void)wiimote:(Wiimote*)wiimote buttonReleased:(WiimoteButtonType)button
{
    if(button>9){
       [self makePointer:button pressing:NO];
    }
    [m_HIDState setButton:button pressed:NO];
}

- (void)wiimoteDisconnected:(Wiimote*)wiimote
{
    [self release];
}

- (void)wiimote:(Wiimote*)wiimote nunchuck:(WiimoteNunchuckExtension*)nunchuck buttonPressed:(WiimoteNunchuckButtonType)button
{
    [m_HIDState setButton:WiimoteButtonCount + button pressed:YES];
 
}

- (void)wiimote:(Wiimote*)wiimote nunchuck:(WiimoteNunchuckExtension*)nunchuck buttonReleased:(WiimoteNunchuckButtonType)button
{
    [m_HIDState setButton:WiimoteButtonCount + button pressed:NO];
}

- (void)wiimote:(Wiimote*)wiimote nunchuck:(WiimoteNunchuckExtension*)nunchuck stickPositionChanged:(NSPoint)position
{
    [m_HIDState setPointer:0 position:position];
}

- (void)      wiimote:(Wiimote*)wiimote
    classicController:(WiimoteClassicControllerExtension*)classic
        buttonPressed:(WiimoteClassicControllerButtonType)button
{
    [m_HIDState setButton:WiimoteButtonCount + WiimoteNunchuckButtonCount + button pressed:YES];
}

- (void)      wiimote:(Wiimote*)wiimote
    classicController:(WiimoteClassicControllerExtension*)classic
       buttonReleased:(WiimoteClassicControllerButtonType)button
{
    [m_HIDState setButton:WiimoteButtonCount + WiimoteNunchuckButtonCount + button pressed:NO];
}

- (void)      wiimote:(Wiimote*)wiimote
    classicController:(WiimoteClassicControllerExtension*)classic
                stick:(WiimoteClassicControllerStickType)stick
      positionChanged:(NSPoint)position
{
    NSLog(@"%@", NSStringFromPoint(position));
    NSLog(@"%u", stick);
    [m_HIDState setPointer:WiimoteNunchuckStickCount + stick position:position];
}

- (void)VHIDDevice:(VHIDDevice*)device stateChanged:(NSData*)state
{
    [m_WJoy updateHIDState:state];
}

@end

@implementation WiimoteAutoWrapper (PrivatePart)

+ (NSString*)wjoyNameFromWiimote:(Wiimote*)device
{
    return [NSString stringWithFormat:@"Wiimote (%@)", [device addressString]];
}

+ (void)newWiimoteDeviceNotification:(NSNotification*)notification
{
    [[WiimoteAutoWrapper alloc]
        initWithWiimote:(Wiimote*)[notification object]];
}

- (id)init
{
    [[super init] release];
    return nil;
}

- (id)initWithWiimote:(Wiimote*)device
{
    self = [super init];
    if(self == nil)
        return nil;
    if(!directions){
        directions=[[NSMutableArray alloc]init];
    }
    
    if([[Wiimote connectedDevices] count] >
       [WiimoteAutoWrapper maxConnectedDevices])
    {
        [device disconnect];
        [self release];
        return nil;
    }

    m_Device    = device;
    m_HIDState  = [[VHIDDevice alloc] initWithType:VHIDDeviceTypeJoystick
                                      pointerCount:WiimoteNunchuckStickCount + WiimoteClassicControllerStickCount
                                       buttonCount:WiimoteButtonCount + WiimoteNunchuckButtonCount + WiimoteClassicControllerButtonCount
                                        isRelative:NO];

    m_WJoy      = [[WJoyDevice alloc]
                             initWithHIDDescriptor:[m_HIDState descriptor]
                                     productString:[WiimoteAutoWrapper wjoyNameFromWiimote:device]];

    if(m_HIDState   == nil ||
       m_WJoy       == nil)
    {
        [device disconnect];
        [self release];
        return nil;
    }

    [m_Device setDelegate:self];
    [m_HIDState setDelegate:self];

    return self;
}
-(void)makePointer:(WiimoteButtonType)button pressing:(BOOL)press
{
    NSNumber *buttonPressed = [NSNumber numberWithInteger:button];
    if (press) {
        [directions addObject:buttonPressed];
    }else{
        NSUInteger dirIndx = 0;
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSNumber *direction in directions) {
            if ([direction isEqual:buttonPressed]) {
                [indexSet addIndex:dirIndx];
            }
            dirIndx++;
        }
    [directions removeObjectsAtIndexes:indexSet];
    }
    
    NSMutableArray *inputArray= [[NSMutableArray alloc] initWithArray:directions copyItems:YES];
    switch ([inputArray count]) {
        case 1:{
            switch ([[inputArray objectAtIndex:0]integerValue]) {
                    //right
                case 13:{
                    puntero = NSMakePoint(1.0, 0.0);
                }
                break;
                    //left
                case 12:
                {
                    puntero = NSMakePoint(-1.0, 0.0);
                }
                break;
                    //down
                case 10:
                {
                    puntero = NSMakePoint(0.0, -1.0);
                }
                break;
                    //up
                case 11:
                {
                    puntero = NSMakePoint(0.0, 1.0);
                }
                break;
                default:
                {
                    puntero = NSMakePoint(0.0, 0.0);
                }
                    break;
            }
        }
            break;
        case 2:{
            NSString *diagonalRef = [NSString stringWithFormat:@"%@%@",[inputArray objectAtIndex:0],[inputArray objectAtIndex:1]];
            switch ([diagonalRef integerValue]) {
                    //down+left
                case 1210:
                case 1012:
                {
                    puntero = NSMakePoint(-0.71, -0.71);
                }
                    break;
                    //up+left
                case 1211:
                case 1112:
                {
                    puntero = NSMakePoint(-0.71, 0.71);
                }
                    break;
                    //down+right
                case 1310:
                case 1013:
                {
                    puntero = NSMakePoint(0.71, -0.71);
                }
                    break;
                case 1311:
                case 1113:
                {
                    puntero = NSMakePoint(0.71, 0.71);
                }
                    break;
                default:
                {
                    puntero = NSMakePoint(0.71, 0.71);
                }
                    break;
            }
        }
            break;
        default:
        {
            puntero = NSPointFromCGPoint(CGPointMake(0.0, 0.0));
        }break;
        
    }
    [m_HIDState setPointer:0 position:puntero];
}
- (void)dealloc
{
    [m_HIDState release];
    [m_WJoy release];
    [super dealloc];
}

@end
