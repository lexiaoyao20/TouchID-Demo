//
//  EditNoteViewController.m
//  TouchIDDemo
//
//  Created by Subo on 16/2/22.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import "EditNoteViewController.h"
#import "AppDelegate.h"

@interface EditNoteViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtNoteTitle;
@property (weak, nonatomic) IBOutlet UITextView *txNoteBody;
@property (weak, nonatomic) AppDelegate *appDelegate;

@end

@implementation EditNoteViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.indexOfEditedNote = NSNotFound;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    self.txtNoteTitle.delegate = self;
    [self.txtNoteTitle becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.indexOfEditedNote != NSNotFound) {
        [self editNote];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)editNote {
    NSArray *notesArray = [NSArray arrayWithContentsOfFile:[self.appDelegate dataFilePath]];
    NSDictionary *noteDict = notesArray[self.indexOfEditedNote];
    self.txtNoteTitle.text = noteDict[@"title"];
    self.txNoteBody.text = noteDict[@"body"];
}

- (IBAction)saveNOte:(id)sender {
    if (self.txtNoteTitle.text.length == 0) {
        NSLog(@"No title for the note was typed.");
        return;
    }
    
    NSDictionary *noteDict = @{@"title" : self.txtNoteTitle.text, @"body" : self.txNoteBody.text ?: @""};
    NSMutableArray *dataArray;
    if ([self.appDelegate checkIfDataFileExists]) {
        dataArray = [NSMutableArray arrayWithContentsOfFile:[self.appDelegate dataFilePath]];
        
        //check if is editing a note or not.
        if (self.indexOfEditedNote == NSNotFound) {
            [dataArray addObject:noteDict];
        }else {
            [dataArray replaceObjectAtIndex:self.indexOfEditedNote withObject:noteDict];
        }
    }else {
        dataArray = [NSMutableArray arrayWithObject:noteDict];
    }
    
    [dataArray writeToFile:[self.appDelegate dataFilePath] atomically:YES];
    if ([self.delegate respondsToSelector:@selector(noteWasSaved)]) {
        [self.delegate noteWasSaved];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ......::::::: UITextFieldDelegate :::::::......
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.txNoteBody becomeFirstResponder];
    return YES;
}

@end
