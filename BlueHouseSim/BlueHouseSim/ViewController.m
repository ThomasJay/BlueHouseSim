//
//  ViewController.m
//  BlueHouseSim
//
//  Created by Tom Jay on 9/4/15.
//  Copyright (c) 2015 Tom Jay. All rights reserved.
//
//
// This application is a simple OSX app that advertises as a BLE Peripheral device.
//
// Once a phone connects, it will stop advertising until the conneciton is dropped.
//
// It will send "Input" values change changed.
//
// It will show relay commands that are sent from the phone.
//
// There is also a "Status" command that can be sent from the phone that will allow all Input values to be sent.
//
//

#import "ViewController.h"
@import CoreBluetooth;

#define BLUE_HOME_SERVICE        @"DFB0"
#define IO_CHARACTERISTIC @"DFB1"


@interface ViewController() <CBPeripheralManagerDelegate> {
    BOOL relay0;
    BOOL relay1;
    BOOL relay2;
    BOOL relay3;
    
    BOOL connected;
    
    BOOL isStarted;
}

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CBMutableService *blueHomeService;
@property (nonatomic, strong) CBMutableCharacteristic *serviceCharacteristic;
@property (nonatomic, strong) NSDictionary *advertisement;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [self setStatus:@"Not Connected"];
    
    [self correctRelayValues];
    
    // Setup BLE Service
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];

    
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}




- (IBAction)startButtonPressed:(id)sender {
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        
        
        self.serviceCharacteristic = [[CBMutableCharacteristic alloc]
                                     initWithType:[CBUUID UUIDWithString:IO_CHARACTERISTIC]
                                     properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify | CBCharacteristicPropertyWrite
                                     value:nil
                                     permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
        
        
        // Create the service
        self.blueHomeService = [[CBMutableService alloc]
                              initWithType:[CBUUID UUIDWithString:BLUE_HOME_SERVICE]
                              primary:YES];
        
        // Add in the characteristics for the service
        self.blueHomeService.characteristics = [NSArray arrayWithObjects:
                                              self.serviceCharacteristic,
                                              nil];
        
        [self.peripheralManager addService:self.blueHomeService];
        
        NSArray *services = [NSArray arrayWithObject:[CBUUID UUIDWithString:BLUE_HOME_SERVICE]];
        self.advertisement = [NSDictionary dictionaryWithObjectsAndKeys:
                              services, CBAdvertisementDataServiceUUIDsKey,
                              @"BLUEPHONE1000", CBAdvertisementDataLocalNameKey,
                              nil];
        [self.peripheralManager startAdvertising:self.advertisement];
        
        self.startButton.hidden = YES;
        
        
    }
    else {
        
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:@"BLE Error"];
        [alert setMessageText:@"The BLE on your computer is not turned on or not capable of being used for BLE."];
        [alert runModal];
        
    }

}


- (IBAction)input0ValueChanged:(id)sender {
    if (connected) {
        [self sendValueForInput:@"Input0" value:_input0Control.selectedSegment];
    }
}


- (IBAction)input1ValueChanged:(id)sender {
    if (connected) {
        [self sendValueForInput:@"Input1" value:_input1Control.selectedSegment];
    }

}


- (IBAction)input2ValueChanged:(id)sender {
    if (connected) {
        [self sendValueForInput:@"Input2" value:_input2Control.selectedSegment];
    }

}


- (IBAction)input3ValueChanged:(id)sender {
    if (connected) {
        [self sendValueForInput:@"Input3" value:_input3Control.selectedSegment];
    }

}


-(void) setStatus:(NSString *)status {
    _statusLabel.stringValue = [NSString stringWithFormat:@"Status: %@", status];

}


- (IBAction)relay0AttemptValueChanged:(id)sender {
    [self correctRelayValues];
}

- (IBAction)relay1AttemptValueChanged:(id)sender {
     [self correctRelayValues];
}

- (IBAction)relay2AttemptValueChanged:(id)sender {
     [self correctRelayValues];
}

- (IBAction)relay3AttemptValueChanged:(id)sender {
     [self correctRelayValues];
}


-(void) correctRelayValues {
    _relay0Control.selectedSegment = relay0;
    _relay1Control.selectedSegment = relay1;
    _relay2Control.selectedSegment = relay2;
    _relay3Control.selectedSegment = relay3;
}


-(void) sendValueForInput:(NSString *)controlName value:(NSInteger) value {
    
    NSString *dataString = [NSString stringWithFormat:@"<%@>%ld;", controlName, (long)value];
    NSData *dataChunk = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL success = [self.peripheralManager updateValue:dataChunk
                                     forCharacteristic:_serviceCharacteristic
                                  onSubscribedCentrals:nil];
    
    NSLog(@"Sent %@ status: %d", dataString, success);

}


#pragma CoreBluetooth

- (void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    NSString *state = nil;
    switch (peripheral.state) {
        case CBPeripheralManagerStateResetting:
            state = @"resetting"; break;
        case CBPeripheralManagerStateUnsupported:
            state = @"unsupported"; break;
        case CBPeripheralManagerStateUnauthorized:
            state = @"unauthorized"; break;
        case CBPeripheralManagerStatePoweredOff:
            state = @"off"; break;
        case CBPeripheralManagerStatePoweredOn:
            state = @"on"; break;
        default:
            state = @"unknown"; break;
    }
    
    NSLog(@"peripheralManagerDidUpdateState:%@ to %@ (%ld)", peripheral, state, peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            
            [self setStatus:@"BLE Ready"];
            break;
        default:
            break;
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    
    isStarted = YES;
    
    [self setStatus:@"BLE Advertising..."];
    
}

- (void) peripheralManager:(CBPeripheralManager *) peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
    
    [self setStatus:@"BLE Connected...Not Advertising"];
    
    [self.peripheralManager stopAdvertising];
    
    connected = YES;
    
}



- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic {
    
    [self setStatus:@"BLE Disconnected...Advertising..."];
    
    [self.peripheralManager startAdvertising:self.advertisement];
    
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {

    for (CBATTRequest *request in requests) {
        
        NSData *requestData = request.value;

        NSString *stringData = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Received stringData=%@", stringData);
        
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
        
        [self parseCommand:stringData];

    }
    
}



-(void) parseCommand:(NSString *)command {
    
    
    if ([command isEqualTo:@"<STATUS>0;"] || [command isEqualTo:@"<STATUS>1;"]) {
        [self sendAllStatus];
    }
    

    if ([command isEqualTo:@"<RELAY0>0;"]) {
        relay0 = NO;
    }
    
    if ([command isEqualTo:@"<RELAY0>1;"]) {
        relay0 = YES;
    }
    
    if ([command isEqualTo:@"<RELAY1>0;"]) {
        relay1 = NO;
    }
    
    if ([command isEqualTo:@"<RELAY1>1;"]) {
        relay1 = YES;
    }
    
    if ([command isEqualTo:@"<RELAY2>0;"]) {
        relay2 = NO;
    }
    
    if ([command isEqualTo:@"<RELAY2>1;"]) {
        relay2 = YES;
    }
    
    if ([command isEqualTo:@"<RELAY3>0;"]) {
        relay3 = NO;
    }
    
    if ([command isEqualTo:@"<RELAY3>1;"]) {
        relay3 = YES;
    }
    
    [self correctRelayValues];
    
}

-(void) sendAllStatus {
    [self performSelector:@selector(input0ValueChanged:) withObject:nil afterDelay:0.1];
    [self performSelector:@selector(input1ValueChanged:) withObject:nil afterDelay:0.3];
    [self performSelector:@selector(input2ValueChanged:) withObject:nil afterDelay:0.6];
    [self performSelector:@selector(input3ValueChanged:) withObject:nil afterDelay:0.8];
}




@end
