#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>

@protocol PCHSwitchTableViewCellDelegate <NSObject>
- (void)key:(NSString *)key didChangeTo:(BOOL)value needingRestart:(BOOL)restart;
@end

@interface PCHSwitchTableViewCell : UITableViewCell
@property (nonatomic, weak) id<PCHSwitchTableViewCellDelegate> delegate;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, assign) BOOL major;
-(void)configureCellWithLabel:(NSString *)label defaultValue:(BOOL)value key:(NSString *)key majorSetting:(BOOL)major;
-(void)valueChanged:(UISwitch *)sender;
@end
