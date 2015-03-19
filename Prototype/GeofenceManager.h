#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface GeofenceManager : NSObject

- (MKMapView *) setMapCenterUsingUserRegion:(MKMapView *)map withSpan:(float)span;
- (void) insertGeofence:(CLCircularRegion *)geofence withName:(NSString *)name description:(NSString *)description andRadius:(float)radius intoMap:(MKMapView *)map
   usingLocationManager:(CLLocationManager *)locationManager;
- (void) stopMonitoringAndClearGeofence:(CLCircularRegion *)geofence fromMap:(MKMapView *)map usingLocationManager:(CLLocationManager *)locationManager;
- (BOOL) set3DMapView:(MKMapView *)map :(BOOL)active;
- (void) setMapTypeStandard:(MKMapView *)map;
- (void) setMapTypeHybrid:(MKMapView *)map;
- (void) setMapTypeSatellite:(MKMapView *)map;
- (void) postGeofenceStatusOnTodayWidget:(NSString *)status;
- (void) postGeofenceNameOnTodayWidget:(NSString *)name;
- (void) deleteGeofenceData;


@end
