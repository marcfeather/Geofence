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

    if (self.radius == 0) {
        NSLog(@"No value was assigned to radius");
    }
    else {
        NSLog(@"%f",self.radius);
    }
    
    NSUserDefaults *retrieveSavedData = [NSUserDefaults standardUserDefaults];
    self.geofenceNameField.text = [retrieveSavedData objectForKey:@"regionName"];
    self.geofenceDescriptionField.text = [retrieveSavedData objectForKey:@"regionDescription"];
    self.addressField.text = [retrieveSavedData objectForKey:@"regionAddress"];
    
    if (self.addressField.text.length > 10) {
        [self getCoordinatesWithAddress];
    }
}

- (IBAction) goToGeofenceAndStartMonitoring:(id)sender {

    if (self.geofenceNameField.text.length == 0 || self.addressField.text.length == 0 || self.radius == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erro"
                                                        message:@"You need to insert a name and assign an address and a distance to a region"
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
    [self getCoordinatesWithAddress];
    [self saveGeofenceInformation];
    [self performSegueWithIdentifier:@"geofenceView" sender:self];
}

- (IBAction) useCurrentCoordinates:(id)sender {
    [self.mapView removeAnnotations:self.mapView.annotations];

    [self getAddressWithCurrentCoordinates];
    [self performSelector:@selector(getCoordinatesWithAddress) withObject:self afterDelay:2.0];

}

- (IBAction) goToGeofenceView:(id)sender {
    [self performSegueWithIdentifier:@"geofenceView" sender:self];
}

- (IBAction) goToRadiusPickerView:(id)sender {
    [self saveGeofenceInformation];
    [self performSegueWithIdentifier:@"radiusPickerView" sender:self];

}

- (void) saveGeofenceInformation {

        NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
        [saveData setDouble: self.latitude forKey:@"regionLatitude"];
        [saveData setDouble: self.longitude forKey:@"regionLongitude"];
        [saveData setDouble: self.radius forKey:@"regionRadius"];
        [saveData setObject: self.geofenceNameField.text forKey:@"regionName"];
        [saveData setObject: self.geofenceDescriptionField.text forKey:@"regionDescription"];
        [saveData setObject: self.addressField.text forKey:@"regionAddress"];
        [saveData synchronize];
    
    self.geofenceManager = [[GeofenceManager alloc] init];
    [self.geofenceManager postGeofenceNameOnTodayWidget:self.geofenceNameField.text];
}

- (void) getAddressWithCurrentCoordinates {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        NSDictionary *dictionary = [[placemarks objectAtIndex:0] addressDictionary];
        
        if ([dictionary valueForKey:@"Street"] == nil) {
            
            self.addressField.text = @"Unable to get your current address";
        }
        
        else {
            NSString *locationUsedAddress = [NSString stringWithFormat:@"%@, %@, %@, %@",
                                   [dictionary valueForKey:@"Street"],
                                   [dictionary valueForKey:@"City"],
                                   [dictionary valueForKey:@"State"],[dictionary valueForKey:@"Country"]];
            
            self.addressField.text = locationUsedAddress;
            self.latitude = self.mapView.userLocation.coordinate.latitude;
            self.longitude = self.mapView.userLocation.coordinate.longitude;
        }
    }];
}

- (void) getCoordinatesWithAddress {
    
    [self.mapView removeAnnotations:self.mapView.annotations];

    
    NSString *addressString = self.addressField.text;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:addressString completionHandler:^(NSArray* placemarks, NSError* error)
     
     {
         if (placemarks && placemarks.count > 0)
         {
             CLPlacemark *topResult = [placemarks objectAtIndex:0];
             MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
             
             [self.mapView addAnnotation:placemark];
             
             CLLocation *address = placemark.location;
             
             [self.mapView setCenterCoordinate:address.coordinate];
             
             MKCoordinateRegion region = self.mapView.region;
             region.span.longitudeDelta = 0.0;
             region.span.latitudeDelta = 0.0;
             [self.mapView setRegion:region animated:YES];
             
             self.latitude = placemark.location.coordinate.latitude;
             self.longitude = placemark.location.coordinate.longitude;
             
         }
     }];
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
        [self getCoordinatesWithAddress];
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
