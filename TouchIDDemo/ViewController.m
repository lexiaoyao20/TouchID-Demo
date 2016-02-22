//
//  ViewController.m
//  TouchIDDemo
//
//  Created by Subo on 16/2/22.
//  Copyright © 2016年 Followme. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "AppDelegate.h"
#import "EditNoteViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,EditNoteViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblNotes;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (nonatomic) NSInteger noteIndexToEdit;
@property (weak, nonatomic) AppDelegate *appDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.noteIndexToEdit = NSNotFound;
    self.appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    self.tblNotes.dataSource = self;
    self.tblNotes.delegate = self;
    [self authenticateUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)authenticateUser {
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    NSString *reasonString = @"Authentication is needed to access your notes.";
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:reasonString reply:^(BOOL success, NSError * _Nullable evalPolicyError) {
                    if (success) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self loadData];
                        }];
                    }else {
                        NSLog(@"%@",evalPolicyError.localizedDescription);
                        switch (evalPolicyError.code) {
                            case LAErrorSystemCancel:
                                NSLog(@"Authentication was cancelled by the system");
                                break;
                            case LAErrorUserCancel:
                                NSLog(@"Authentication was cancelled by the user");
                                break;
                            case LAErrorUserFallback:
                                NSLog(@"User selected to enter custom password");
                                [self showPasswordAlert];
                                break;
                            default:
                                NSLog(@"Authentication failed");
                                [self showPasswordAlert];
                                break;
                        }
                    }
                }];
        
    }else {
        switch (error.code) {
            case LAErrorTouchIDNotEnrolled:
                NSLog(@"TouchID is not enrolled");
                break;
            case LAErrorPasscodeNotSet:
                NSLog(@"A passcode has not been set");
                break;
            default:
                NSLog(@"TouchID not available");
                break;
        }
        NSLog(@"%@",error.localizedDescription);
        [self showPasswordAlert];
    }
}

- (void)showPasswordAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"TouchIDDemo"
                                                                             message:@"Please type your password"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *txtPassword = alertController.textFields[0];
        if ([txtPassword.text isEqualToString:@"app"]) {
            [self loadData];
        }else {
            [self showPasswordAlert];
        }
    }];
    [alertController addAction:OKAction];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)loadData {
    if ([self.appDelegate checkIfDataFileExists]) {
        self.dataArray = [NSMutableArray arrayWithContentsOfFile:[self.appDelegate dataFilePath]];
        [self.tblNotes reloadData];
    }else {
        NSLog(@"File does not exist");
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"idSegueEditNote"]) {
        EditNoteViewController *editNoteController = segue.destinationViewController;
        editNoteController.delegate = self;
        if (self.noteIndexToEdit != NSNotFound) {
            editNoteController.indexOfEditedNote = self.noteIndexToEdit;
            self.noteIndexToEdit = NSNotFound;
        }
    }
}

#pragma mark - ......::::::: TableView DataSource :::::::......

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCell" forIndexPath:indexPath];
    NSDictionary *currentNote = self.dataArray[indexPath.row];
    cell.textLabel.text = currentNote[@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.dataArray writeToFile:[self.appDelegate dataFilePath] atomically:YES];
        [self.tblNotes reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - ......::::::: TableView Delegate :::::::......

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.noteIndexToEdit = indexPath.row;
    
    [self performSegueWithIdentifier:@"idSegueEditNote" sender:self];
}

#pragma mark - ......::::::: EditNoteViewControllerDelegate :::::::......

- (void)noteWasSaved {
    [self loadData];
}

@end
