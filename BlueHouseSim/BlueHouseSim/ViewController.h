//
//  ViewController.h
//  BlueHouseSim
//
//  Created by Tom Jay on 9/4/15.
//  Copyright (c) 2015 Tom Jay. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSTextField *statusLabel;
@property (nonatomic, weak) IBOutlet NSButton *startButton;

@property (nonatomic, weak) IBOutlet NSSegmentedControl *input0Control;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *input1Control;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *input2Control;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *input3Control;

@property (nonatomic, weak) IBOutlet NSSegmentedControl *relay0Control;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *relay1Control;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *relay2Control;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *relay3Control;



@end

