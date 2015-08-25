//
//  SerialCommunication.c
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-07.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/serial/ioss.h>
#include <IOKit/IOBSD.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <paths.h>
#include <termios.h>
#include <sysexits.h>
#include <sys/param.h>
#include <sys/select.h>
#include <sys/time.h>
#include <time.h>
#include <CoreFoundation/CoreFoundation.h>
#include "SerialCommunication.h"

CFArrayRef getSerialModemList() {
    uint32_t serialModemCount = 0;
    CFMutableArrayRef devicePaths = CFArrayCreateMutable(kCFAllocatorDefault, serialModemCount, &kCFTypeArrayCallBacks);
    
    kern_return_t kernalReturnValue;
    
    CFMutableDictionaryRef deviceMatchingDictionary = NULL;
    deviceMatchingDictionary = IOServiceMatching(kIOSerialBSDServiceValue);
    io_iterator_t deviceIterator;
    kernalReturnValue = IOServiceGetMatchingServices(kIOMasterPortDefault, deviceMatchingDictionary,
                                                     &deviceIterator);
    if (kernalReturnValue != KERN_SUCCESS) {
        return NULL;
    }
    
    io_service_t device;
    while ((device = IOIteratorNext(deviceIterator)))
    {
        CFMutableDictionaryRef deviceProperties = NULL;
        kernalReturnValue = IORegistryEntryCreateCFProperties(device, &deviceProperties, kCFAllocatorDefault, kNilOptions);
        if (kernalReturnValue != KERN_SUCCESS) {
            return NULL;
        }
        
        CFStringRef devicePathKey = CFStringCreateWithCString(kCFAllocatorDefault, kIOCalloutDeviceKey, kCFStringEncodingASCII);
        CFStringRef devicePath = CFDictionaryGetValue(deviceProperties, devicePathKey);
        IOObjectRelease(device);
        CFArrayAppendValue(devicePaths, devicePath);
    }
    
    IOObjectRelease(deviceIterator);
    return CFArrayCreateCopy(kCFAllocatorDefault, devicePaths);
}

Boolean ReadDataFromSerialModem(uint8_t *buffer, ssize_t bufferSize, int fileDescriptor) {
    Boolean didReadData = FALSE;
    memset(buffer, 0, bufferSize);
    ssize_t readBytes = 0;
    ssize_t readOffset = 0;
    do {
        readBytes = read(fileDescriptor, buffer + readOffset, bufferSize);
        didReadData = didReadData || (readBytes > 0);
    } while (readBytes > 0 && readOffset + readBytes < bufferSize);
    
    return didReadData;
}

Boolean WriteDataToSerialModem(uint8_t *data, ssize_t dataLength, int fileDescriptor)
{
    uint32_t writeAttemptCount;
    uint32_t maxRetryLimit = 10;
    ssize_t totalBytesWritten = 0, bytesWritten = 0;
    
    for (writeAttemptCount = 0; writeAttemptCount < maxRetryLimit; writeAttemptCount++) {
        
        bytesWritten = write(fileDescriptor, data + totalBytesWritten, dataLength);
        
        if (bytesWritten == -1) {
            continue;
        } else {
            totalBytesWritten += bytesWritten;
        }
        
        if (totalBytesWritten < dataLength) {
            continue;
        }

        return TRUE;
    }
    return FALSE;
}

static struct termios gOriginalTTYAttrs;

int OpenSerialConnectionToDeviceAtPath(const char *deviceFilePath)
{
    int             fileDescriptor = -1;
    int             handshake;
    
    fileDescriptor = open(deviceFilePath, O_RDWR | O_NOCTTY | O_NONBLOCK);
    if (fileDescriptor == -1) {
        printf("Error opening serial port %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    if (ioctl(fileDescriptor, TIOCEXCL) == -1) {
        printf("Error setting TIOCEXCL on %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    if (fcntl(fileDescriptor, F_SETFL, 0) == -1) {
        printf("Error clearing O_NONBLOCK %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    if (tcgetattr(fileDescriptor, &gOriginalTTYAttrs) == -1) {
        printf("Error getting tty attributes %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    speed_t speed = 250000;
    if (ioctl(fileDescriptor, IOSSIOSPEED, &speed) == -1) {
        printf("Error calling ioctl(..., IOSSIOSPEED, ...) %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
    }

    unsigned long blocking = 1;
    if (ioctl(fileDescriptor, FIONBIO, &blocking) == -1) {
        printf("Error calling ioctl(..., FIONBIO, ...) %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
    }

    if (ioctl(fileDescriptor, TIOCSDTR) == -1) {
        printf("Error asserting DTR %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
    }
    
    if (ioctl(fileDescriptor, TIOCCDTR) == -1) {
        printf("Error clearing DTR %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
    }
    
    handshake = TIOCM_DTR | TIOCM_RTS | TIOCM_CTS | TIOCM_DSR;
    if (ioctl(fileDescriptor, TIOCMSET, &handshake) == -1) {
        printf("Error setting handshake lines %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
    }
    
    if (ioctl(fileDescriptor, TIOCMGET, &handshake) == -1) {
        printf("Error getting handshake lines %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
    }
    
    printf("Handshake lines currently set to %d\n", handshake);
    
    unsigned long mics = 10UL;
    if (ioctl(fileDescriptor, IOSSDATALAT, &mics) == -1) {
        printf("Error setting read latency %s - %s(%d).\n",
               deviceFilePath, strerror(errno), errno);
        goto error;
    }
    
    // Success
    return fileDescriptor;
    
    // Failure path
error:
    if (fileDescriptor != -1) {
        close(fileDescriptor);
    }
    
    return -1;
}


