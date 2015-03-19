#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import "GeofenceManager.h"

@interface GeofenceView : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *geofenceMap;
@property (nonatomic, strong) IBOutlet UIView *stateInfoView;
@property (nonatomic, strong) IBOutlet UISwitch *regionMonitoring;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedMapType;
@property (nonatomic, strong) IBOutlet UIView *pullView;
@property (nonatomic, strong) CLLocationManager *GPSManager;
@property (nonatomic, strong) CLCircularRegion *locationUsedRegion;
@property (nonatomic, strong) NSString *locationUsedAddress;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic, strong) NSTimer *heartbeatTimer;
@property (nonatomic, strong) NSString *currentTimeString;
@property (nonatomic, strong) NSMutableArray *logNotification;
@property (nonatomic, strong) NSMutableArray *logTime;
@property (nonatomic, strong) NSString *geofenceName;
@property (nonatomic, strong) NSString *ETAMessage;
@property (nonatomic, strong) NSString *geofenceDescription;
@property (nonatomic, strong) UIBarButtonItem *monitoringStatusButton;
@property (nonatomic, strong) UISwipeGestureRecognizer *callMenu;
@property (nonatomic, strong) GeofenceManager *geofenceManager;
@property (nonatomic, assign) double regionRadius;
@property (nonatomic, assign) float regionLatitude;
@property (nonatomic, assign) float regionLongitude;

@end
