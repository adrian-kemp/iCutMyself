//
//  SerialCommunication.h
//  iCutMyself
//
//  Created by Adrian Kemp on 2015-08-07.
//  Copyright (c) 2015 DickFingers Inc. All rights reserved.
//

#ifndef __iCutMyself__SerialCommunication__
#define __iCutMyself__SerialCommunication__

#include <CoreFoundation/CoreFoundation.h>
#include <stdio.h>

CFArrayRef getSerialModemList();
int OpenSerialConnectionToDeviceAtPath(const char *deviceFilePath);
Boolean WriteDataToSerialModem(uint8_t *data, ssize_t dataLength, int fileDescriptor);
Boolean ReadDataFromSerialModem(uint8_t *buffer, ssize_t bufferSize, int fileDescriptor);

#endif /* defined(__iCutMyself__SerialCommunication__) */
