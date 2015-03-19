#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userDefaultsDidChange:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(0, 60);
    
    [self updateGeofenceStatus];
}

-(void) userDefaultsDidChange:(NSNotification *)notification {
    [self updateGeofenceStatus];
}

- (void) updateGeofenceStatus {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.geofence"];
    NSString *status = [sharedDefaults objectForKey:@"geofenceStatus"];
    NSString *geofenceName = [sharedDefaults objectForKey:@"geofenceName"];

    if ([status isEqualToString:@"ON"]) {
        self.geofenceStatusLabel.text = @"Monitoring Geofence";
        self.geofenceStatusView.image = [UIImage imageNamed:@"geofenceStatusUnknow"];
    }
    if ([status isEqualToString:@"IN"]) {
        self.geofenceStatusLabel.text = @"Inside the monitored Geofence";
        self.geofenceStatusView.image = [UIImage imageNamed:@"geofenceStatusIn"];
    }
    if ([status isEqualToString:@"OUT"]) {
        self.geofenceStatusLabel.text = @"Outside the monitored Geofence";
        self.geofenceStatusView.image = [UIImage imageNamed:@"geofenceStatusOut"];
    }
    if ([status isEqualToString:@"OFF"]) {
        self.geofenceStatusLabel.text = @"Geofence monitoring is Off";
        self.geofenceStatusView.image = [UIImage imageNamed:@"geofenceStatusOff"];
    }
    if ([status isEqualToString:@"UNKNOW"]) {
        self.geofenceStatusLabel.text = @"Geofence monitoring is Unknow";
        self.geofenceStatusView.image = [UIImage imageNamed:@"geofenceStatusUnknow"];
    }
    self.geofenceNameLabel.text = geofenceName;
}

- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
   
    completionHandler(NCUpdateResultNewData);
}

@end
