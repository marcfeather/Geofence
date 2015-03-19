#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "GeofenceManager.h"

@interface AddGeofenceView : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UITextField *geofenceNameField;
@property (nonatomic, strong) IBOutlet UITextField *geofenceDescriptionField;
@property (nonatomic, strong) IBOutlet UITextField *addressField;
@property (nonatomic, strong) CLLocationManager *GPSManager;
@property (nonatomic, strong) CLCircularRegion *monitoredRegion;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) GeofenceManager *geofenceManager;
@property (nonatomic, assign) double radius;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end
