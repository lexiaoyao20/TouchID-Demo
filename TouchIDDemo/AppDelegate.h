//
//  AppDelegate.h
//  TouchIDDemo
//
//  Created by Subo on 16/2/22.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSString *)dataFilePath;
- (BOOL)checkIfDataFileExists;

@end

