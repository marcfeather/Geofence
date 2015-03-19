#import "GeofenceView.h"

@interface GeofenceView ()

@end

@implementation GeofenceView

- (void) viewWillAppear:(BOOL)animated {
    
    UIImage *topLogo = [UIImage imageNamed:@"geofenceIcon"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:topLogo];
    
    self.tabBarController.tabBar.tintColor = [UIColor orangeColor];
    [self.navigationController.navigationBar setTintColor:[UIColor orangeColor]];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(goToAddGeofenceView)];
    
    UIImage *initialStatusImage = [[UIImage imageNamed:@"StatusOff"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.monitoringStatusButton = [[UIBarButtonItem alloc] initWithImage:initialStatusImage
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:nil];
    
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = self.monitoringStatusButton;

}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    self.navigationItem.hidesBackButton = YES;
    
    [self configureMenuView];
    
    self.geofenceMap.delegate = self;
    self.geofenceMap.showsUserLocation = YES;
    
    for (CLRegion *monitored in [self.GPSManager monitoredRegions])
        [self.GPSManager stopMonitoringForRegion:monitored];
    
    self.GPSManager = [[CLLocationManager alloc] init];
    self.GPSManager.delegate = self;
    self.GPSManager.distanceFilter = kCLDistanceFilterNone;
    self.GPSManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([self.GPSManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.GPSManager requestAlwaysAuthorization];
    }
    
    if ((![CLLocationManager locationServicesEnabled])
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"In order to use this app, you need to allow it to access your location. Please open this app's settings and set location access to 'Always'." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [self.GPSManager startUpdatingLocation];
    
    [self performSelector:@selector(setMapCenter) withObject:self afterDelay:2.0];
}

- (void) setMapCenter {
    self.geofenceManager = [[GeofenceManager alloc] init];
    [self.geofenceManager setMapCenterUsingUserRegion:self.geofenceMap withSpan:0.1];
}

-(void) configureMenuView {
    self.callMenu = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showStatePanelView)];
    self.callMenu.direction = UISwipeGestureRecognizerDirectionDown;
    [self.navigationController.navigationBar addGestureRecognizer:self.callMenu];
    
    self.callMenu = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showStatePanelView)];
    self.callMenu.direction = UISwipeGestureRecognizerDirectionDown;
    [self.navigationController.navigationBar addGestureRecognizer:self.callMenu];
    
    self.callMenu = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideStatePanelView)];
    self.callMenu.direction = UISwipeGestureRecognizerDirectionUp;
    [self.stateInfoView addGestureRecognizer:self.callMenu];
    
    self.callMenu = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideStatePanelView)];
    self.callMenu.direction = UISwipeGestureRecognizerDirectionUp;
    [self.stateInfoView addGestureRecognizer:self.callMenu];
}

- (void) displayOrHideStateInfoView {
    if (![self.stateInfoView isHidden]) {
        [self hideStatePanelView];
    }
    else {
        [self showStatePanelView];
    }
}

- (void) retrieveSavedData {
    NSUserDefaults *retrieveSavedData = [NSUserDefaults standardUserDefaults];
    self.regionLatitude = [[retrieveSavedData objectForKey:@"regionLatitude"] doubleValue];
    self.regionLongitude = [[retrieveSavedData objectForKey:@"regionLongitude"] doubleValue];
    self.regionRadius = [[retrieveSavedData objectForKey:@"regionRadius"] doubleValue];
    self.geofenceName = [retrieveSavedData objectForKey:@"regionName"];
    self.geofenceDescription = [retrieveSavedData objectForKey:@"regionDescription"];
}

- (CLCircularRegion *)createGeofence {
    [self retrieveSavedData];
    
    if (self.regionRadius == 0 || self.regionLatitude == 0 || self.regionLongitude == 0 || self.geofenceName == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There is no Geofence to be monitored. Please, create a Geofence and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self.geofenceManager postGeofenceStatusOnTodayWidget:@"OFF"];

    }
    else {
        self.locationUsedRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(self.regionLatitude, self.regionLongitude) radius:self.regionRadius identifier:self.geofenceName];
        return self.locationUsedRegion;

    }
    return self.locationUsedRegion;
}

- (IBAction) startOrStopMonitoringRegion:(id)sender  {

    [self createGeofence];
    self.geofenceManager = [[GeofenceManager alloc] init];
    
    if ([self.regionMonitoring isOn]) {
        [self hideStatePanelView];
        [self.geofenceManager insertGeofence:self.locationUsedRegion withName:self.geofenceName description:self.geofenceDescription andRadius:self.regionRadius intoMap:self.geofenceMap usingLocationManager:self.GPSManager];
        [self.geofenceManager postGeofenceStatusOnTodayWidget:@"ON"];
    }
    if (![self.regionMonitoring isOn]) {
        [self hideStatePanelView];
        [self.geofenceManager stopMonitoringAndClearGeofence:self.locationUsedRegion fromMap:self.geofenceMap usingLocationManager:self.GPSManager];
        [self.geofenceManager postGeofenceStatusOnTodayWidget:@"OFF"];
    }
}

- (IBAction) changeMapType:(id)sender {
    NSInteger selectedSegment = self.segmentedMapType.selectedSegmentIndex;
    self.geofenceManager = [[GeofenceManager alloc] init];
    
    if (selectedSegment == 0) {
        [self.geofenceManager set3DMapView:self.geofenceMap:NO];
        [self.geofenceManager setMapTypeStandard:self.geofenceMap];
    }
    if (selectedSegment == 1) {
        [self.geofenceManager setMapTypeHybrid:self.geofenceMap];
    }
    if (selectedSegment == 2) {
        [self.geofenceManager setMapTypeSatellite:self.geofenceMap];
    }
    if (selectedSegment == 3) {
        [self.geofenceManager set3DMapView:self.geofenceMap:YES];
    }
    [self hideStatePanelView];
}


- (void) applyBlurOnMap {
    
    if(!UIAccessibilityIsReduceTransparencyEnabled()) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.restorationIdentifier = @"blurryView";
        blurEffectView.frame = self.geofenceMap.bounds;
        
        [self.geofenceMap addSubview:blurEffectView];
    }
}

- (void) removeBlurFromMap {
    
    for (UIView *blurryView in self.geofenceMap.subviews) {

        if ([blurryView.restorationIdentifier isEqualToString:@"blurryView"]) {
            [blurryView removeFromSuperview];
        }
    }
}

- (void) goToAddGeofenceView {
    [self performSegueWithIdentifier:@"addGeofenceView" sender:self];
}

- (void) displayLocalNotification {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    localNotification.alertBody = [NSString stringWithFormat:@"%@ at %@",self.statusMessage,self.currentTimeString];
    localNotification.alertAction = @"OK";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication]presentLocalNotificationNow:localNotification];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Geofence"
                                                    message:self.statusMessage
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
    [[self navigationController] tabBarItem].badgeValue = @"1";
    
    AVSpeechSynthesizer *speech = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@.%@",self.statusMessage, self.ETAMessage]];
    utterance.rate = 0.25;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    [speech speakUtterance:utterance];
    
}

- (void) getCurrentTime {
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [NSTimeZone resetSystemTimeZone];
    NSTimeZone *gmtZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:gmtZone];
    [dateFormatter setDateFormat:@"HH:mm"];
    self.currentTimeString = [dateFormatter stringFromDate:now];
}

- (void) actionsToBeExecuted {
    [self getCurrentTime];
    [self displayLocalNotification];
    
    [self.logNotification addObject:@"Your Geofence was executed successfully"];
    [self.logTime addObject:self.currentTimeString];
    
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    [saveData setObject:self.logNotification forKey:@"logNotification"];
    [saveData setObject:self.logTime forKey:@"logTime"];
    [saveData synchronize];
    
}

- (void) showStatePanelView {
    if ([self.stateInfoView isHidden]) {
        [self.stateInfoView setHidden:NO];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self.stateInfoView setFrame:CGRectMake(self.stateInfoView.frame.origin.x,
                                                self.stateInfoView.frame.origin.y + 212,
                                                self.stateInfoView.frame.size.width,
                                                self.stateInfoView.frame.size.height)];
        
        [self.pullView setFrame:CGRectMake(self.pullView.frame.origin.x,
                                           self.pullView.frame.origin.y + 187,
                                           self.pullView.frame.size.width,
                                           self.pullView.frame.size.height)];
        [UIView commitAnimations];
        [self applyBlurOnMap];
    }
}

- (void) hideStatePanelView {
    if (![self.stateInfoView isHidden]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self.stateInfoView setFrame:CGRectMake(self.stateInfoView.frame.origin.x,
                                                self.stateInfoView.frame.origin.y - 212,
                                                self.stateInfoView.frame.size.width,
                                                self.stateInfoView.frame.size.height)];
        
        [self.pullView setFrame:CGRectMake(self.pullView.frame.origin.x,
                                           self.pullView.frame.origin.y - 187,
                                           self.pullView.frame.size.width,
                                           self.pullView.frame.size.height)];
        
        
        [UIView commitAnimations];
        [self removeBlurFromMap];
        [self.stateInfoView setHidden:YES];
    }
}

#pragma mark LocationManager Delegate Methods

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLCircularRegion *)region {
    self.statusMessage = @"You are now entering the monitored region";
    [self.geofenceManager postGeofenceStatusOnTodayWidget:@"IN"];

    [self actionsToBeExecuted];
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLCircularRegion *)region {
    self.statusMessage = @"You are now leaving the monitored region";
    [self.geofenceManager postGeofenceStatusOnTodayWidget:@"OUT"];

    [self actionsToBeExecuted];
}

- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLCircularRegion *)region {
    self.geofenceManager = [[GeofenceManager alloc] init];
    
    if (region == nil) {
        NSLog(@"Problems in the region %@", region.description);
    }
    else {
        
        if (state == CLRegionStateUnknown ) {
            [self.monitoringStatusButton setImage:[[UIImage imageNamed:@"StatusUnknown"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [self.geofenceManager postGeofenceStatusOnTodayWidget:@"UNKNOW"];

        }
        if (state == CLRegionStateInside) {
            [self.monitoringStatusButton setImage:[[UIImage imageNamed:@"StatusIn"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [self.geofenceManager postGeofenceStatusOnTodayWidget:@"IN"];

        }
        if (state == CLRegionStateOutside) {
            [self.monitoringStatusButton setImage:[[UIImage imageNamed:@"StatusOut"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [self.geofenceManager postGeofenceStatusOnTodayWidget:@"OUT"];
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    
    if (newLocation.speed > 0) {
        double ETA = self.regionRadius / newLocation.speed;
        
        int etaSeconds = (int)ETA % 60;
        int etaMinutes = (int)(ETA / 60) % 60;
        
        if (etaMinutes == 0) {
            
            self.ETAMessage = [NSString stringWithFormat:@"The E.T.A for your region's destinations is: %i seconds", etaSeconds];
        }
        else {
            
            self.ETAMessage = [NSString stringWithFormat:@"The E.T.A for your region's destinations is: %i minutes And %i seconds", etaMinutes, etaSeconds];
        }
    }
}

#pragma mark MKAnnotationView and MKOverlayView Delegate Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if([annotation isEqual:[self.geofenceMap userLocation]]) {
        
        return nil;
    }

    MKPinAnnotationView *pin = (MKPinAnnotationView *)[self.geofenceMap dequeueReusableAnnotationViewWithIdentifier:@"geofencePin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"geofencePin"];
        pin.pinColor = MKPinAnnotationColorGreen;
        pin.canShowCallout = YES;
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *carImage = [[UIImage imageNamed:@"deleteGeofence"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [deleteButton setImage:carImage forState: UIControlStateNormal];
        deleteButton.frame = CGRectMake(0, 0, 32, 32);
        
        pin.leftCalloutAccessoryView = deleteButton;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 23, 23);
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        [pin setImage:[UIImage imageNamed:@"marker"]];
    }
    
    else {
        pin.annotation = annotation;
    }
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    self.geofenceManager = [[GeofenceManager alloc] init];
    
    [self.geofenceManager stopMonitoringAndClearGeofence:self.locationUsedRegion fromMap:self.geofenceMap usingLocationManager:self.GPSManager];
    [self.geofenceManager deleteGeofenceData];
    [self.geofenceManager postGeofenceStatusOnTodayWidget:@"OFF"];
    
    if (self.GPSManager.monitoredRegions.count == 0) {
        [self.heartbeatTimer invalidate];
        [self.regionMonitoring setOn:NO animated:YES];
        [self.monitoringStatusButton setImage:[[UIImage imageNamed:@"StatusOff"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self setMapCenter];
    }
}

- (MKOverlayView *) mapView:(MKMapView *)mapView viewForOverlay:(id)overlay {
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [UIColor clearColor];
    circleView.fillColor = [UIColor colorWithRed:243.0/255.0 green:130./255.0 blue:49.0/255.0 alpha:0.6];
    circleView.lineWidth = 0;
    return circleView;
}

- (void) viewDidDisappear:(BOOL)animated {
    [[self navigationController] tabBarItem].badgeValue = nil;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
