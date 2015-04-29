#import "AddGeofenceView.h"
#import "GeofenceView.h"

@interface AddGeofenceView ()

@end

@implementation AddGeofenceView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
                                                                                  action:@selector(goToGeofenceView:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;

    self.geofenceNameField.delegate = self;
    self.geofenceDescriptionField.delegate = self;
    self.addressField.delegate = self;
    
    self.GPSManager = [[CLLocationManager alloc] init];
    self.GPSManager.delegate = self;
    self.GPSManager.distanceFilter = kCLDistanceFilterNone;
    self.GPSManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.GPSManager startUpdatingLocation];
    
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];

    [self retrieveGeofenceInformation];
    
    if (self.addressField.text.length > 10) {
        self.geofenceManager = [[GeofenceManager alloc] init];
        [self.geofenceManager getCoordinatesWithAddress:self.addressField.text usingMap:self.mapView];
    }
}

- (IBAction) goToGeofenceAndStartMonitoring:(id)sender {

    if (self.geofenceNameField.text.length == 0 || self.addressField.text.length == 0 || self.radius == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"You need to insert a name, assign an address and a distance to a region"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else {
        [self useAddressCoordinates:self];
    }
}

- (IBAction) useAddressCoordinates:(id)sender {
    self.geofenceManager = [[GeofenceManager alloc] init];
    [self.geofenceManager getCoordinatesWithAddress:self.addressField.text usingMap:self.mapView];
    [self performSegueWithIdentifier:@"geofenceView" sender:self];
}

- (IBAction) useCurrentCoordinates:(id)sender {
    self.geofenceManager = [[GeofenceManager alloc] init];
    [self.geofenceManager getAddressWithCurrentCoordinatesUsingMap:self.mapView];
    
    [self retrieveGeofenceInformation];
}

- (IBAction) goToGeofenceView:(id)sender {
    [self performSegueWithIdentifier:@"geofenceView" sender:self];
}

- (IBAction) goToRadiusPickerView:(id)sender {
    [self saveGeofenceInformation];
    [self performSegueWithIdentifier:@"radiusPickerView" sender:self];

}

- (void) retrieveGeofenceInformation {
    NSUserDefaults *retrieveSavedData = [NSUserDefaults standardUserDefaults];
    self.geofenceNameField.text = [retrieveSavedData objectForKey:@"regionName"];
    self.geofenceDescriptionField.text = [retrieveSavedData objectForKey:@"regionDescription"];
    self.addressField.text = [retrieveSavedData objectForKey:@"regionAddress"];
    self.latitude = [retrieveSavedData doubleForKey:@"regionLatitude"];
    self.longitude = [retrieveSavedData doubleForKey:@"regionLongitude"];
    self.radius = [retrieveSavedData doubleForKey:@"regionRadius"];
    
    if (self.radius == 0) {
        NSLog(@"No value was assigned to radius");
    }
    else {
        NSLog(@"%f",self.radius);
    }
}

- (void) saveGeofenceInformation {
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    [saveData setDouble: self.radius forKey:@"regionRadius"];
    [saveData setObject: self.geofenceNameField.text forKey:@"regionName"];
    [saveData setObject: self.geofenceDescriptionField.text forKey:@"regionDescription"];
    [saveData setObject: self.addressField.text forKey:@"regionAddress"];
    [saveData setDouble:self.latitude forKey:@"regionLatitude"];
    [saveData setDouble:self.longitude forKey:@"regionLongitude"];
    [saveData synchronize];
    
    self.geofenceManager = [[GeofenceManager alloc] init];
    [self.geofenceManager postGeofenceNameOnTodayWidget:self.geofenceNameField.text];
}

- (BOOL) textFieldShouldReturn:(UITextField *)theTextField {
    
    if(theTextField==self.geofenceNameField){
        [self.geofenceDescriptionField becomeFirstResponder];
        return YES;
    }
    else if(theTextField==self.geofenceDescriptionField) {
        [self.addressField becomeFirstResponder];
        return YES;
    }
    else if(theTextField==self.addressField) {
        self.geofenceManager = [[GeofenceManager alloc] init];
        [self.geofenceManager getCoordinatesWithAddress:self.addressField.text usingMap:self.mapView];
        [self.addressField resignFirstResponder];
        return YES;
    }
    return NO;
}

- (void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:self.tapRecognizer];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 60, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification *) note {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 60, self.view.frame.size.width, self.view.frame.size.height)];
    [UIView commitAnimations];
    [self.view removeGestureRecognizer:self.tapRecognizer];
}

- (void) didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.geofenceNameField resignFirstResponder];
    [self.geofenceDescriptionField resignFirstResponder];
    [self.addressField resignFirstResponder];

}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}

@end
