#import "RadiusPickerView.h"
#import "AddGeofenceView.h"

@interface RadiusPickerView ()

@end

@implementation RadiusPickerView

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    UIImage *topLogo = [UIImage imageNamed:@"geofenceIcon"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:topLogo];
    self.navigationItem.hidesBackButton = YES;
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(goToAddGeofenceView:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.radiusPicker.delegate = self;
    self.radiusList = [[NSArray alloc] initWithObjects:@"100",
                  @"200",
                  @"500",
                  @"1000",
                  nil];
    
    self.unityList = [[NSArray alloc] initWithObjects:@"meters", nil];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [self.radiusList count];
    }
    else {
        return [self.unityList count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(component == 0)
    {
        return [self.radiusList objectAtIndex:row];
    }
    else
    {
        return [self.unityList objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.radiusValue = [[self.radiusList objectAtIndex:row] doubleValue];
    
    if (self.radiusValue > 0) {
        [self.doneButton setEnabled:YES];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) goToAddGeofenceView:(id)sender {
    
    [self performSegueWithIdentifier:@"addGeofenceView" sender:self];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    AddGeofenceView *addGeofence = segue.destinationViewController;
    addGeofence.radius = self.radiusValue;

}

@end
