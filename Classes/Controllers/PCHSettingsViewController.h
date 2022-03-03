#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import "../Views/Cells/PCHLinkTableViewCell.h"
#import "../Views/Cells/PCHSwitchTableViewCell.h"

@interface UIApplication (Peach)
- (void)suspend;
@end

@interface PCHSettingsViewController : UITableViewController <PCHSwitchTableViewCellDelegate, UIAdaptivePresentationControllerDelegate>
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *pendingPrefs;
@end
