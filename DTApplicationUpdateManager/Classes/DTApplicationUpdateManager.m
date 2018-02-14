//
//  DTApplicationUpdateManager.m
//  DTApplicationUpdateManager
//
//  Created by Thinh Vo on 28/06/2017.
//

@import UIKit;
#import "DTApplicationUpdateManager.h"

static NSString * const kApplicationUpdateManagerKey = @"ApplicationUpdateManagerKey";
static NSString * const kApplicationUpdateManagerLastCheckingDateKey = @"ApplicationUpdateManagerLastCheckingDateKey";
static NSString * const kLastShowingAlertDateKey = @"LastShowingAlertDateKey";
static NSString * const kNewVersionAvailableKey = @"NewVersionAvailableKey";
static NSString * const kPreviousNewVersionKey = @"PreviousNewVersionKey";
static NSString * const kLastFoundNewVersionKey = @"LastFoundNewVersionKey";

@implementation NSString (DTApplicationUpdateManager)

- (BOOL)isNewerVersionToVersion:(NSString *)version
{
    return [self compare:version options:NSNumericSearch] == NSOrderedDescending;
}

@end

@interface DTApplicationItunesInformation()
@property(nonatomic, strong, readwrite) NSString *version;
@property(nonatomic, strong, readwrite) NSNumber *trackId;
@property(nonatomic, strong, readwrite) NSString *trackName;
@property(nonatomic, strong, readwrite) NSDate *releasedDate;
@property(nonatomic, strong, readwrite) NSString *requiredMinimumOSVersion;
@property(nonatomic, strong, readwrite) NSURL *trackViewUrl;
@end

@implementation DTApplicationItunesInformation
+ (DTApplicationItunesInformation *)applicationItunesInformationForDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) { return nil; }
    DTApplicationItunesInformation *informationObject = [[DTApplicationItunesInformation alloc] init];
    
    [informationObject mapWithDictionary:dictionary];
    
    return informationObject;
}

#pragma mark - Internal methods
- (void)mapWithDictionary:(NSDictionary *)dictionary
{
    self.version = [dictionary objectForKey:@"version"];
    self.trackId = [dictionary objectForKey:@"trackId"];
    self.trackName = [dictionary objectForKey:@"trackName"];
    self.requiredMinimumOSVersion = [dictionary objectForKey:@"minimumOsVersion"];
    self.trackViewUrl = [NSURL URLWithString:[dictionary objectForKey:@"trackViewUrl"]];
}
@end

@implementation DTApplicationUpdateManager
{
    DTApplicationUpdateRoutineType _rountineType;
    NSDate *_lastCheckingDate;
    DTApplicationItunesInformation *_downloadedApplicationItunesInfo;
}

#pragma mark - Class methods
+ (instancetype)sharedInstance
{
    static id _instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self class] new];
    });
    
    return _instance;
}

+ (NSString *)currentOSVersion
{
    return [UIDevice currentDevice].systemVersion;
}

+ (NSString *)currentAppVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBundleID
{
    return [NSBundle mainBundle].bundleIdentifier;
}

#pragma mark - Public methods
- (void)checkForNewAppVersionWithReminderRoutineType:(DTApplicationUpdateRoutineType)routineType
{
    _rountineType = routineType;
    
    [self performCheck];
}

#pragma mark - Helper methods
- (void)performCheck
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[self iTunesURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ([data length] > 0 && error == nil) {
            // Download successfully
            [self handleDownloadedData:data];
        }
    }];
    
    [dataTask resume];
}

- (NSURL *)iTunesURL
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    
    components.scheme = @"https";
    components.host = @"itunes.apple.com";
    
    NSString *path = self.countryCode ? [NSString stringWithFormat:@"%@/lookup", self.countryCode] : @"/lookup";
    components.path = path;
    
    NSMutableArray<NSURLQueryItem *> *queryItems = [[NSMutableArray alloc] initWithObjects:
                                                    [NSURLQueryItem queryItemWithName:@"bundleId" value:[DTApplicationUpdateManager appBundleID]], nil];
    
    components.queryItems = queryItems;
    
    return components.URL;
}

- (void)handleDownloadedData:(NSData *)data
{
    NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *infoDict = ((NSArray *)[dataDict objectForKey:@"results"])[0];
    
    _downloadedApplicationItunesInfo = [DTApplicationItunesInformation applicationItunesInformationForDictionary:infoDict];
    
    if (_downloadedApplicationItunesInfo == nil) { return; }
    
    NSString *downloadedVersion = _downloadedApplicationItunesInfo.version;
    NSString *currentVersion = [DTApplicationUpdateManager currentAppVersion];
    
    if (![downloadedVersion isNewerVersionToVersion:currentVersion]) { return; }
    
    // There is a new version available
    NSString *downloadedRequiredMinimumOSVersion = _downloadedApplicationItunesInfo.requiredMinimumOSVersion;
    NSString *currentOSVersion = [DTApplicationUpdateManager currentOSVersion];
    
    if (![downloadedRequiredMinimumOSVersion isNewerVersionToVersion:currentOSVersion]) {
        // The new app version is allowed to update on the current device
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL shouldShowAlertNow = NO;
        
        NSDate *lastShowingAlertDate = [userDefaults objectForKey:kLastShowingAlertDateKey];
        if (!lastShowingAlertDate) {
            // This is the first time we download/receive the app info, ask the delegate to show the alert rightaway
            shouldShowAlertNow = YES;
        } else {
            // Should perform the check if it is the time to show the alert again
            NSString *lastFoundNewVersion = [userDefaults objectForKey:kLastFoundNewVersionKey];
            if (lastFoundNewVersion) {
                if ([downloadedVersion isNewerVersionToVersion:lastFoundNewVersion]) {
                    // There is newer version to the last found new version. Ask the delegate to show the alert although there is still time remaining to display the next alert.
                    shouldShowAlertNow = YES;
                } else {
                    // The newly downloaded version is the same as the previous new downloaded one. Should only display alert when the remaining time is zero.
                    unsigned int unitFlags = NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitMonth | NSCalendarUnitYear;
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    NSDateComponents *components = [calendar components:unitFlags fromDate:lastShowingAlertDate toDate:[NSDate new] options:0];
                    
                    switch (_rountineType) {
                        case DTApplicationUpdateRoutineTypeEverySecond:
                            shouldShowAlertNow = components.second >= 1 ? YES : NO;
                            break;
                        case DTApplicationUpdateRoutineTypeEveryMinute:
                            shouldShowAlertNow = components.minute >= 1 ? YES : NO;
                            break;
                        case DTApplicationUpdateRoutineTypeEveryHour:
                            shouldShowAlertNow = components.hour >= 1 ? YES : NO;
                            break;
                        case DTApplicationUpdateRoutineTypeEveryDay:
                            shouldShowAlertNow = components.day >= 1 ? YES : NO;
                            break;
                        case DTApplicationUpdateRoutineTypeEveryWeek:
                            shouldShowAlertNow = components.weekOfMonth >= 1 ? YES : NO;
                            break;
                        case DTApplicationUpdateRoutineTypeEveryMonth:
                            shouldShowAlertNow = components.month >= 1 ? YES : NO;
                            break;
                        case DTApplicationUpdateRoutineTypeEveryYear:
                            shouldShowAlertNow = components.year >= 1 ? YES : NO;
                            break;
                    }
                }
            }
        }
        
        if (shouldShowAlertNow) {
            
            [userDefaults setObject:[NSDate new] forKey:kLastShowingAlertDateKey];
            [userDefaults setObject:_downloadedApplicationItunesInfo.version forKey:kLastFoundNewVersionKey];
            [userDefaults synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate) {
                    [self.delegate applicationUpdateManager:self shouldDisplayNewVersionUpdateAlertWithInformation:_downloadedApplicationItunesInfo];
                }
            });
        }
        
    } else {
        // Send a notification that user need to update the system in order to update the app.
        // Or send a notification that there is an update required for newer system.
    }
}

@end

