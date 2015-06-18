//
//  SIDMasterViewController.m
//  Fingerpaint
//
//  Created by Peter Kämpf on 04.04.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.0   May 18, 2015
//

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()
@property (strong, nonatomic) IBOutlet UILabel *lineWidthLabel;
@property (strong, nonatomic) IBOutlet UILabel *alphaValueLabel;
@property (strong, nonatomic) IBOutlet UILabel *lineBrightLabel;
@property (strong, nonatomic) IBOutlet UILabel *speedLabel;
@property (strong, nonatomic) IBOutlet UILabel *frameRateLabel;
@property (strong, nonatomic) IBOutlet UISlider *paramsSlider;
@property (strong, nonatomic) NSTimer *displayTimer;
@property (assign, nonatomic) NSUInteger paramsIndex;
@property (strong, nonatomic) NSArray *pickerStrings;
@property (strong, nonatomic) NSMutableArray *paramsArray;
@end

@implementation MasterViewController

#pragma mark - Setup

// Initialize the window

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.preferredContentSize = self.view.bounds.size;
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

// Launch a timer for frameRate updates. Since viewDidLoad is called twice, we need to check
// whether the timer runs already.
    if (!self.displayTimer) {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateDisplayValues:) userInfo:nil repeats:YES];
        self.displayTimer = timer;
    }
    self.paramsIndex    =    0;
    self.paramsArray    = [[NSMutableArray alloc] initWithCapacity:8];
    self.paramsArray[0] =   @5.0;        // speedLimitFactor
    self.paramsArray[1] =   @4.0;        // maxOffTimeFactor
    self.paramsArray[2] =   @3.0;        // minTrustedScore
    self.paramsArray[3] = @100.0;        // minimumSpeed
    self.paramsArray[4] =  @50.0;        // xMarginForHitTesting
    self.paramsArray[5] =  @25.0;        // yMarginForHitTesting
    self.paramsArray[6] =   @0.15;       // penModeErrorLimit
    self.paramsArray[7] =   @0.4;        // timeBetweenSameLines
    self.paramsSlider.minimumValue = 0.0;
    self.paramsSlider.maximumValue = 9.0;
    float newParameter    = [self.paramsArray[self.paramsIndex] floatValue];
    self.paramsEntry.text = [NSString stringWithFormat:@"%.1f", newParameter];
    [self.paramsSlider setValue:newParameter animated:NO];
    self.pickerStrings    = [[NSArray alloc] initWithObjects:@"speedLimitFactor", @"maxOffTimeFactor", @"minTrustedScore", @"minimumSpeed", @"xMarginForHitTesting", @"yMarginForHitTesting", @"penModeErrorLimit", @"timeBetweenSameLines", nil];

    self.paramsPicker.delegate   = self;
    self.paramsPicker.dataSource = self;
    self.paramsEntry.delegate    = self;
}

// Number of spinwheels of the paramsPicker:

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// Number of entries of the paramsPicker:

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerStrings count];
}

// Give back the entry string for the row row of the paramsPicker:

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerStrings[row];
}

#pragma mark - IB Actions

// Action after the line width slider has been changed:

- (IBAction)lineWidthSliderChanged:(UISlider *)sender {
    [self.detailViewController.linePresets setWidth:sender.value];
    self.lineWidthLabel.text = [NSString stringWithFormat:@"%.1f", sender.value];
}

// Action after the transparency slider has been changed:

- (IBAction)alphaSliderChanged:(UISlider *)sender {
    [self.detailViewController.linePresets setAlphaValue:sender.value];
    self.alphaValueLabel.text = [NSString stringWithFormat:@"%.2f", sender.value];
}

// Action after the line brightness slider has been changed:

- (IBAction)brightSliderChanged:(UISlider *)sender {
    [self.detailViewController.linePresets setBright:0.01*sender.value];
    self.lineBrightLabel.text = [NSString stringWithFormat:@"%.0f", sender.value];
}

// Action after a new use case has been selected:

- (IBAction)newParameterSelection:(UISegmentedControl *)sender {
    [self.detailViewController.pvData setUsageMode:sender.selectedSegmentIndex];
    [self.detailViewController setParameters:sender.selectedSegmentIndex];

// Update the parameters array:
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.paramsArray[0] =   @5.0;        // speedLimitFactor
            self.paramsArray[1] =   @4.0;        // maxOffTimeFactor
            self.paramsArray[2] =   @3.0;        // minTrustedScore
            self.paramsArray[3] = @100.0;        // minimumSpeed
            self.paramsArray[4] =  @50.0;        // xMarginForHitTesting
            self.paramsArray[5] =  @25.0;        // yMarginForHitTesting
            self.paramsArray[6] =   @0.15;       // penModeErrorLimit
            self.paramsArray[7] =   @0.4;        // timeBetweenSameLines
            break;

        case 1:
            self.paramsArray[0] =   @8.0;
            self.paramsArray[1] =   @7.0;
            self.paramsArray[2] =   @7.0;
            self.paramsArray[3] = @180.0;
            self.paramsArray[4] =  @50.0;
            self.paramsArray[5] =  @25.0;
            self.paramsArray[6] =   @0.12;       // penModeErrorLimit
            self.paramsArray[7] =   @0.4;        // timeBetweenSameLines
            break;

        default:
            self.paramsArray[0] =  @20.0;
            self.paramsArray[1] =  @12.0;
            self.paramsArray[2] =   @3.0;
            self.paramsArray[3] = @300.0;
            self.paramsArray[4] =  @50.0;
            self.paramsArray[5] =  @25.0;
            self.paramsArray[6] =   @0.20;       // penModeErrorLimit
            self.paramsArray[7] =   @0.4;        // timeBetweenSameLines
            break;
    }

// Only now can the slider be correctly set:
    float newParameter    = [self.paramsArray[self.paramsIndex] floatValue];
    self.paramsEntry.text = [NSString stringWithFormat:@"%.1f", newParameter];
    [self.paramsSlider setValue:newParameter animated:YES];
}

// Action when the Pinch and Pan button has been selected.

- (IBAction)togglePinchAndPanSwitch:(UISwitch *)sender {
    [self.detailViewController.pvData setPinchAndPan:sender.isOn];
}

// Action when the iOS8-mode button has been selected.

- (IBAction)toggleTouchRadius:(UISwitch *)sender {
    [self.detailViewController.tRec setRadiusCheckAvailable:sender.isOn];
}

// Action when the Show Rects button has been selected.

- (IBAction)toggleRectDisplaySwitch:(UISwitch *)sender {
    [self.detailViewController.pvData setRectDisplay:sender.isOn];
}

// Action when the Recording button has been selected.

- (IBAction)startRecTapped:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:(@"Start")]) {
        [sender setTitle: @"Stop" forState: UIControlStateNormal];
        [sender setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    } else {
        [sender setTitle: @"Start" forState: UIControlStateNormal];
        [sender setTitleColor:nil forState:UIControlStateNormal];
    }
    [self.detailViewController startRecording];
}

// Action after a parameter has been selected for editing:

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.paramsIndex = row;

    switch (row) {
        case 0:
            self.paramsSlider.minimumValue =  0.0;
            self.paramsSlider.maximumValue = 30.0;
            break;

        case 1:
            self.paramsSlider.minimumValue =  1.0;
            self.paramsSlider.maximumValue = 12.0;
            break;

        case 2:
            self.paramsSlider.minimumValue =  1.0;
            self.paramsSlider.maximumValue = 24.0;
            break;

        case 3:
            self.paramsSlider.minimumValue =   0.0;
            self.paramsSlider.maximumValue = 500.0;
            break;

        case 4:
            self.paramsSlider.minimumValue =   0.0;
            self.paramsSlider.maximumValue = 120.0;
            break;

        case 5:
            self.paramsSlider.minimumValue =   0.0;
            self.paramsSlider.maximumValue = 120.0;
            break;

        case 6:
            self.paramsSlider.minimumValue =   0.01;
            self.paramsSlider.maximumValue =   0.5;
            break;

        default:
            self.paramsSlider.minimumValue =   0.01;
            self.paramsSlider.maximumValue =   2.5;
            break;
    }

// Only now can the slider be correctly set:
    float newParameter    = [self.paramsArray[row] floatValue];
    self.paramsEntry.text = [NSString stringWithFormat:@"%.1f", newParameter];
    [self.paramsSlider setValue:newParameter animated:YES];
}

// Action after a new value has been edited for the selected parameter:

- (IBAction)paramsEdited:(UITextField *)sender {
    float newParameter = [sender.text floatValue];
    self.paramsArray[self.paramsIndex] = [NSNumber numberWithFloat:(newParameter)];
    [self.paramsSlider setValue:newParameter animated:YES];
    [self notifyPulsedTouchRecognizer];
}

// Fold away the screen keyboard when Return is typed:

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// Action when the parameter slider moves:

- (IBAction)paramsSliderMoved:(UISlider *)sender {
    self.paramsArray[self.paramsIndex] = [NSNumber numberWithFloat:(sender.value)];
    self.paramsEntry.text = [NSString stringWithFormat:@"%.2f", sender.value];
    [self notifyPulsedTouchRecognizer];
}

// Action when the Erase button has been selected.

- (IBAction)eraseButtonTapped:(UIButton *)sender {
    [self.detailViewController eraseButton];
}

#pragma mark - Notification handling

// Recalculate frame rate, called by timer every 500 ms.

- (void)updateDisplayValues:(NSNotification *)notification {

    self.speedLabel.text    = [NSString stringWithFormat:@"%.2f", self.detailViewController.tRec.lineSpeed];
    CGFloat frameRate       = [self.detailViewController calculateFrameRate];
    if (frameRate > 0.01) {
        self.frameRateLabel.text = [NSString stringWithFormat:@"%.2f", frameRate];
    }
}

// Send out the notification about the new parameter:

- (void) notifyPulsedTouchRecognizer {

// Send a message with the pen mode of the just processed line:
    NSDictionary *dataInfo = @{self.pickerStrings[0]: self.paramsArray[0],
                               self.pickerStrings[1]: self.paramsArray[1],
                               self.pickerStrings[2]: self.paramsArray[2],
                               self.pickerStrings[3]: self.paramsArray[3],
                               self.pickerStrings[4]: self.paramsArray[4],
                               self.pickerStrings[5]: self.paramsArray[5],
                               self.pickerStrings[6]: self.paramsArray[6]};
    [[NSNotificationCenter defaultCenter] postNotificationName:SID_ParameterChangedNotification
                                                        object:self
                                                      userInfo:dataInfo];
}

#pragma mark - other stuff

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
// Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
    }
}

- (void)dealloc {
}

@end
