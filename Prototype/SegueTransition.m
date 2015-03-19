#import "SegueTransition.h"

@implementation SegueTransition

- (void) perform {
    UIViewController *sourceController = (UIViewController*)self.sourceViewController;
    UIViewController *destinationController = (UIViewController*)self.destinationViewController;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromTop;
    
    [sourceController.navigationController.view.layer addAnimation:transition forKey:@"transitionFade"];
    
    [sourceController.navigationController pushViewController:destinationController animated:NO];
    
}

@end
