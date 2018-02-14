//
//  DTApplicationUpdateManager.h
//  DTApplicationUpdateManager
//
//  Created by Thinh Vo on 28/06/2017.
//

#import <Foundation/Foundation.h>

@class DTApplicationUpdateManager;
@class DTApplicationItunesInformation;

typedef NS_ENUM(NSInteger, DTApplicationUpdateRoutineType) {
    DTApplicationUpdateRoutineTypeEverySecond = 0,
    DTApplicationUpdateRoutineTypeEveryMinute,
    DTApplicationUpdateRoutineTypeEveryHour,
    DTApplicationUpdateRoutineTypeEveryDay,
    DTApplicationUpdateRoutineTypeEveryWeek,
    DTApplicationUpdateRoutineTypeEveryMonth,
    DTApplicationUpdateRoutineTypeEveryYear
};

@interface NSString (DTApplicationUpdateManager)
- (BOOL)isNewerVersionToVersion:(NSString *)version;
@end

@protocol DTApplicationUpdateManagerDelegate  <NSObject>
/**
 @brief
 * This message will only be sent to the delegate if both of the following requirements are met. First, there is a new version available on the AppStore. Second,
 * the time difference between the previous display alert and the moment we send do the check must exceed the specified reminder rountine gap.
 */
@optional
- (void)applicationUpdateManager:(DTApplicationUpdateManager *)applicationUpdateManager shouldDisplayNewVersionUpdateAlertWithInformation:(DTApplicationItunesInformation *)updateInformation;
@end

@interface DTApplicationItunesInformation: NSObject

@property(nonatomic, readonly) NSString *version;
@property(nonatomic, readonly) NSNumber *trackId;
@property(nonatomic, readonly) NSString *trackName;
@property(nonatomic, readonly) NSDate *releasedDate;
@property(nonatomic, readonly) NSString *requiredMinimumOSVersion;
@property(nonatomic, readonly) NSURL *trackViewUrl;

// Application dictionary
+ (DTApplicationItunesInformation *)applicationItunesInformationForDictionary:(NSDictionary *)dictionary;
@end

@interface DTApplicationUpdateManager : NSObject
+ (DTApplicationUpdateManager *)sharedInstance;

@property(nonatomic, weak) id<DTApplicationUpdateManagerDelegate> delegate;
@property(nonatomic, strong) NSString *countryCode;
//@property(nonatomic, strong)

/**
 @brief
 * This method should be called in AppDelegate's didFinishLaunchingWithOption: method.
 * It will check for newer version every time user launch the app.
 * Once a newer version is found user have two options either install the new version or dismiss the alert. If user choose to dismiss the alert, user will be reminded
 * after a period of time. While user is staying in OLD version and ANOTHER NEW version is found(user refused to update to new version and now there is another new version), the alert will be shown immediately, no matter how many days left
 * to show the next alert from previous new version. In other words, whenever a new version is found, the starting reminder date will be set at that moment.
 * If user update the app then the reminder date is ignored
 
 @property reminderRoutineType is used in case user refuses to update. This property is used to determine when should should be the next time to show the alert again
 */
- (void)checkForNewAppVersionWithReminderRoutineType:(DTApplicationUpdateRoutineType)reminderRoutineType;

+ (NSString *)currentOSVersion;
+ (NSString *)currentAppVersion;
+ (NSString *)appBundleID;

@end

