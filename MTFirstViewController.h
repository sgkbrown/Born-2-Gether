//
//  MTFirstViewController.h
//  FBAPIPractice
//
//  Created by Michael Thomas on 7/16/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "birthDateViewController.h"


@interface MTFirstViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, birthdateDelegate>

@property (weak) id <birthdateDelegate> delegate;

@property (strong, nonatomic) UIImage *profileImage;

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextView *aboutMeTextField;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UIButton *imageButtonLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;

@property (strong, nonatomic) IBOutlet UIButton *updateInfoButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteAccountButton;

@property (strong, nonatomic) IBOutlet UILabel *includeInSearchLabel;
@property (strong, nonatomic) IBOutlet UIButton *birthYearLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthLabelStatic;

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatiorView;

@property (strong, nonatomic) IBOutlet UISwitch *yearSwitchProp;

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)updateInfoButtonPressed:(UIButton *)sender;
- (IBAction)deleteButtonPressed:(UIButton *)sender;
- (IBAction)logoutButtonPressed:(UIButton *)sender;
- (IBAction)imageButtonPressed:(UIButton *)sender;
- (IBAction)updateBirthday:(id)sender;



@end
