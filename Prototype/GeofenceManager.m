#import "GeofenceManager.h"

@implementation GeofenceManager

- (MKMapView *) setMapCenterUsingUserRegion:(MKMapView *)map withSpan:(float)span {
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:
                                CLLocationCoordinate2DMake(map.userLocation.coordinate.latitude,
                                                           map.userLocation.coordinate.longitude)
                                                                 radius:500
                                                             identifier:@"currentLocation"];
    
    MKCoordinateRegion userRegion = map.region;
    userRegion.center = region.center;
    userRegion.span.longitudeDelta = span;
    userRegion.span.latitudeDelta = span;
    
    [map setRegion:userRegion];
    
    return map;
}

- (void) stopMonitoringAndClearGeofence:(CLCircularRegion *)geofence fromMap:(MKMapView *)map usingLocationManager:(CLLocationManager *)locationManager {
    [locationManager stopUpdatingLocation];
    [locationManager stopMonitoringSignificantLocationChanges];
    
    for (CLRegion *monitored in [locationManager monitoredRegions])
        [locationManager stopMonitoringForRegion:monitored];
    
    for (MKCircle *radius in [map overlays]) {
        [map removeOverlay:radius];
    }
    
    [map removeAnnotations:map.annotations];
    
    MKCoordinateRegion region = map.region;
    region.center = geofence.center;
    region.span.longitudeDelta = 50;
    region.span.latitudeDelta = 50;
    
    [map setRegion:region animated:YES];
}

- (void) insertGeofence:(CLCircularRegion *)geofence withName:(NSString *)name description:(NSString *)description andRadius:(float)radius
intoMap:(MKMapView *)map usingLocationManager:(CLLocationManager *)locationManager {
    
    if(radius > locationManager.maximumRegionMonitoringDistance)
    {
        radius = locationManager.maximumRegionMonitoringDistance;
    }
    
    geofence =  [[CLCircularRegion alloc] initWithCenter:geofence.center radius:radius identifier:name];
    
    MKCoordinateRegion region = map.region;
    region.center = geofence.center;
    region.span.longitudeDelta = 0.05;
    region.span.latitudeDelta = 0.05;
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = geofence.center;
    point.title = name;
    point.subtitle = description;
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:geofence.center
                                                     radius:geofence.radius];
    [map addOverlay:circle];
    
    [map addAnnotation:point];
    
    [map setRegion:region animated:YES];
    
    [locationManager startMonitoringForRegion:geofence];
}

- (BOOL) set3DMapView:(MKMapView *)map :(BOOL)active {
    
    if (active == YES) {
        MKMapCamera *mapCamera = [[MKMapCamera alloc] init];
        [mapCamera setPitch:60.0];
        [mapCamera setHeading: map.userLocation.heading.trueHeading];
        [mapCamera setAltitude:500.0];
        [mapCamera setCenterCoordinate:map.userLocation.coordinate];
        [map setCamera:mapCamera animated:YES];
        
        return YES;
    }
    if (active == NO) {
        MKMapCamera *mapCamera = [[MKMapCamera alloc] init];
        [mapCamera setPitch:0];
        [mapCamera setHeading: map.userLocation.heading.trueHeading];
        [mapCamera setAltitude:2000.0];
        [mapCamera setCenterCoordinate:map.userLocation.coordinate];
        [map setCamera:mapCamera animated:YES];
        
        return NO;
    }
    return NO;
}

- (void) setMapTypeStandard:(MKMapView *)map {
    [map setMapType:MKMapTypeStandard];
}

- (void) setMapTypeHybrid:(MKMapView *)map {
    [map setMapType:MKMapTypeHybrid];
}

- (void) setMapTypeSatellite:(MKMapView *)map {
    [map setMapType:MKMapTypeSatellite];
}

-(void) postGeofenceStatusOnTodayWidget:(NSString *)status {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.geofence"];
    [sharedDefaults setValue:status forKey:@"geofenceStatus"];
    [sharedDefaults synchronize];
}

-(void) postGeofenceNameOnTodayWidget:(NSString *)name {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.geofence"];
    [sharedDefaults setValue:name forKey:@"geofenceName"];
    [sharedDefaults synchronize];
}

- (void) deleteGeofenceData {
    
    NSUserDefaults *saveData = [NSUserDefaults standardUserDefaults];
    [saveData setDouble: 0 forKey:@"regionLatitude"];
    [saveData setDouble: 0 forKey:@"regionLongitude"];
    [saveData setDouble: 0 forKey:@"regionRadius"];
    [saveData setObject: nil forKey:@"regionName"];
    [saveData setObject: nil forKey:@"regionDescription"];
    [saveData setObject: nil forKey:@"regionAddress"];
    [saveData synchronize];
    
    [self postGeofenceNameOnTodayWidget:@"No Geofence Assigned"];
}

- (NSString *) getCurrentTime {
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [NSTimeZone resetSystemTimeZone];
    NSTimeZone *gmtZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:gmtZone];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:now];
}

-(void) insertLocalNotificationWithMessage:(NSString *)message andTime:(NSString *)time {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UILocalNotification *localNotification = [[UILocalNotification alloc]init];
    localNotification.alertBody = [NSString stringWithFormat:@"%@ at %@",message,[self getCurrentTime]];
    localNotification.alertAction = @"OK";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication]applicationIconBadgeNumber] + 1;
    [[UIApplication sharedApplication]presentLocalNotificationNow:localNotification];
}

- (void) deleteLocalNotifications {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (UILocalNotification *notification in eventArray)
    {
        [app cancelLocalNotification:notification];
    }
}

-(void) speakMessage:(NSString *)message withETA:(NSString *)ETA {
    AVSpeechSynthesizer *speech = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:[NSString stringWithFormat:@"%@.%@",message, ETA]];
    utterance.rate = 0.25;
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    [speech speakUtterance:utterance];
}

@end
