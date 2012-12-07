/*
 *  wirtual_joy_device.h
 *  wjoy
 *
 *  Created by alxn1 on 13.07.12.
 *  Copyright 2012 alxn1. All rights reserved.
 *
 */

#ifndef WIRTUAL_JOY_DEVICE_H
#define WIRTUAL_JOY_DEVICE_H

#include <IOKit/hid/IOHIDDevice.h>
#include "wirtual_joy_config.h"

class WirtualJoyDevice : public IOHIDDevice
{
    OSDeclareDefaultStructors(WirtualJoyDevice)
    public:
        static WirtualJoyDevice *withHidDescriptor(
                                        const void *hidDescriptorData,
                                        size_t hidDescriptorDataSize,
                                        OSString *productString);

        virtual bool init(
                        const void *hidDescriptorData,
                        size_t hidDescriptorDataSize,
                        OSString *productString,
                        OSDictionary *dictionary = 0);

        virtual IOReturn newReportDescriptor(IOMemoryDescriptor **descriptor) const;
        virtual OSString *newManufacturerString() const;
        virtual OSString *newProductString() const;
        virtual OSString *newTransportString() const;
        virtual OSNumber *newPrimaryUsageNumber() const;
        virtual OSNumber *newPrimaryUsagePageNumber() const;
        virtual OSNumber *newLocationIDNumber() const;

        bool updateState(const void *hidData, size_t hidDataSize);

    protected:
        virtual void free();

    private:
        static const uint32_t locationIdBase = 0xFAFAFAFA;

        OSString *m_ProductString;
        HIDCapabilities m_Capabilities;
        IOBufferMemoryDescriptor *m_HIDReportDescriptor;
        IOBufferMemoryDescriptor *m_StateBuffer;
        uint32_t m_LocationID;

        bool parseHidDescriptor(
                        const void *hidDescriptorData,
                        size_t hidDescriptorDataSize);
};

#endif /* WIRTUAL_JOY_DEVICE_H */
