//
//  SIDMasterViewController.h
//  Fingerpaint
//
//  Created by Peter Kämpf on 04.04.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (weak, nonatomic) IBOutlet UIPickerView *paramsPicker;
@property (weak, nonatomic) IBOutlet UITextField *paramsEntry;

@end
