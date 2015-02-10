//
//  ProfileViewController.h
//  BornTogether
//
//  Created by Michael Thomas on 8/5/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) PFUser *matchedUser;

@property (strong, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (strong, nonatomic) IBOutlet UITextView *aboutmeLabel;

- (IBAction)chatButtonClicked:(UIBarButtonItem *)sender;

@end
