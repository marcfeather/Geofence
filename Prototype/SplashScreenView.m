#import "SplashScreenView.h"

@interface SplashScreenView ()

@end

@implementation SplashScreenView

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self performSelector:@selector(goToGeofenceView) withObject:self afterDelay:3];
}

- (void) goToGeofenceView {
    [self performSegueWithIdentifier:@"geofenceView" sender:self];
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end
