//
//  EditNoteViewController.h
//  TouchIDDemo
//
//  Created by Subo on 16/2/22.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditNoteViewControllerDelegate <NSObject>

- (void)noteWasSaved;

@end

@interface EditNoteViewController : UIViewController

@property (weak, nonatomic) id<EditNoteViewControllerDelegate> delegate;
@property (nonatomic) NSInteger indexOfEditedNote;

@end
