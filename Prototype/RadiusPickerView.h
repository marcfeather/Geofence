#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RadiusPickerView : UIViewController <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) IBOutlet UIPickerView *radiusPicker;
@property (nonatomic, strong) IBOutlet UIButton *doneButton;
@property (nonatomic, strong) IBOutlet UISwitch *monitoringKeeper;
@property (nonatomic, strong) NSArray *radiusList;
@property (nonatomic, strong) NSArray *unityList;

@property (nonatomic, assign) double radiusValue;

@end
