# DTApplicationUpdateManager

[![CI Status](http://img.shields.io/travis/thinhv@metropolia.fi/DTApplicationUpdateManager.svg?style=flat)](https://travis-ci.org/thinhv@metropolia.fi/DTApplicationUpdateManager)
[![Version](https://img.shields.io/cocoapods/v/DTApplicationUpdateManager.svg?style=flat)](http://cocoapods.org/pods/DTApplicationUpdateManager)
[![License](https://img.shields.io/cocoapods/l/DTApplicationUpdateManager.svg?style=flat)](http://cocoapods.org/pods/DTApplicationUpdateManager)
[![Platform](https://img.shields.io/cocoapods/p/DTApplicationUpdateManager.svg?style=flat)](http://cocoapods.org/pods/DTApplicationUpdateManager)

## Introduction
A simple and easy-to-use update manager which checks if there is any new version available to the AppStore

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

DTApplicationUpdateManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DTApplicationUpdateManager'
```

## How to use

You can call, for example:
```objective-c
[[DTApplicationUpdateManager sharedInstance] checkForNewAppVersionWithReminderRoutineType:DTApplicationUpdateRoutineTypeEveryWeek];
```
from `didFinishLaunchingWithOptions` or  `applicationWillEnterForeground` or `applicationDidBecomeActive` in `AppDelegate`  etc, in order to check the new version's availability.
Remember to set the delegate.


The `DTApplicationUpdateRoutineType` is used for the reminder. If user ignores to the new version update message, the delegate method will be called after a certain amount of time which depends on the  `DTApplicationUpdateRoutineType`.  Remember that DTApplicationUpdateManager will not automatically remind its delegate about the new version until its `checkForNewAppVersionWithReminderRoutineType` method is called.

## Pull requests
Pull request are welcomed!

## Author

ducthinh2410@gmail.com

## License

DTApplicationUpdateManager is available under the MIT license. See the LICENSE file for more info.
