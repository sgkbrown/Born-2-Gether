//
//  MainMenuViewController.m
//  BornTogether
//
//  Created by Michael Thomas on 7/30/14.
//  Copyright (c) 2014 Nutech-Inc. All rights reserved.
//
//  Added ability to post general invitation/app information to feed.
//

#import "MainMenuViewController.h"
#import "MTConstants.h"
#import "ProfileViewController.h"
//#import "AppDelegate.h"
#import "MTFirstViewController.h"

#define InviteName @"BornTogether"
#define InviteCaption @"Link with me on BornTogether"
#define InviteDescription @"Connect with new friends that have the same birthday."
#define InviteLink @"http://nutech-inc.com"

#define InviteParameters [NSMutableDictionary dictionaryWithObjectsAndKeys:InviteName , @"name", InviteCaption, @"caption", InviteDescription, @"description", InviteLink, @"link", nil];
//For image, add prior to nil: <URL>, @"picture",

@interface MainMenuViewController ()

@property (strong, nonatomic) NSMutableData *imageData;

//@property (strong, nonatomic) NSArray *allUsers;

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (strong, nonatomic) UIAlertView *aliasAlert;

@property (strong, nonatomic) UIAlertView *birthdayAlert;

@property (strong, nonatomic) UIAlertView *userErroralert;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingTable;

- (IBAction)showSheet:(UIBarButtonItem *)sender;
@end

@implementation MainMenuViewController

//-(NSArray *)allUsers
//{
//    if (!_allUsers)
//    {
//        _allUsers = [[NSArray alloc]init];
//    }
//    return _allUsers;
//}

-(void)updatedUserList{
    [self.tableView reloadData];
    _loadingTable.hidden = YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)refreshBirthdate
{
    [self getBirthday];
    [self viewWillAppear:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_loadingTable setHidden:NO];
    [_loadingTable startAnimating];

    
    [self getBirthday];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:.9];
    self.tableView.backgroundColor = [UIColor clearColor];
    NSDictionary *profile = [PFUser currentUser][@"profile"];
    NSString *gender = profile[@"gender"];
    UIColor *styleColor;
    
    if ([gender isEqualToString:@"male"]) {
        styleColor = [UIColor colorWithRed:204.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    } else {
        styleColor = [UIColor colorWithRed:255.0/255.0 green:192.0/255.0 blue:203.0/255.0 alpha:1];
    }
    
    [self.navigationController.navigationBar setBarTintColor:styleColor];
    
    [[BTGUserModel bornTogetherUsers] setDelegate:self];
    // Do any additional setup after loading the view.
    
    NSString *Alias =[PFUser currentUser][@"Alias"];
    if (Alias.length < 1)
    {
        if (NSClassFromString(@"UIAlertView"))
        {
            _aliasAlert = [[UIAlertView alloc] initWithTitle:@"Enter an Alias"
                                                     message:@"Welcome to Born Together \n Please enter a username, this will be the name other users know you by."
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"Save",nil];
            
            _aliasAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [_aliasAlert show];
        }
    }
    else
    {
        NSLog(@"There was a user alias found for this user");
    }
    PFUser *currentUser = [PFUser currentUser];
    if (![currentUser valueForKey:@"profile"])
    {
        FBRequest *request = [FBRequest requestForMe];
        
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            
            if (!error){
                NSDictionary *userDictionary = (NSDictionary *)result;
                
                //create URL
                NSString *facebookID = userDictionary[@"id"];
                NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",facebookID]];
                
                NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
                if (userDictionary[@"name"]){
                    userProfile[kCCUserProfileNameKey] = userDictionary[@"name"];
                }
                if (userDictionary[@"first_name"]){
                    userProfile[kCCUserProfileFirstNameKey] = userDictionary[@"first_name"];
                }
                if (userDictionary[@"location"][@"name"]){
                    userProfile[kCCUserProfileLocationKey] = userDictionary[@"location"][@"name"];
                }
                if (userDictionary[@"gender"]){
                    userProfile[kCCUserProfileGenderKey] = userDictionary[@"gender"];
                }
                if (userDictionary[@"birthday"])
                {
                    userProfile[kCCUserProfileBirthdayKey] = userDictionary[@"birthday"];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateStyle:NSDateFormatterShortStyle];
                    NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                    NSDate *now = [NSDate date];
                    NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                    int age = seconds / 31536000;
                    userProfile[kCCUserProfileAgeKey] = @(age);
                }
                
                if (userDictionary[@"interested_in"]){
                    userProfile[kCCUserProfileInterestedInKey] = userDictionary[@"interested_in"];
                }
                if (userDictionary[@"relationship_status"]){
                    userProfile[kCCUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
                }
                if ([pictureURL absoluteString]){
                    userProfile[kCCUserProfilePictureURL] = [pictureURL absoluteString];
                }
                
//                self.helloLabel.text = [NSString stringWithFormat:@"Hello, %@ \nWelcome to Born Together!", userProfile[kCCUserProfileNameKey]];
                
                [[PFUser currentUser]setObject:@YES forKey:USERYEARSEARCH];
                [[PFUser currentUser] setObject:userProfile forKey:kCCUserProfileKey];
                [[PFUser currentUser] saveInBackground];
                
                [self requestImage];
            }
            else {
                NSLog(@"Error in FB request %@", error);
            }
        }];
    }
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    return YES;
//}

-(void)getBirthday
{
    PFUser *user= [PFUser currentUser];
    NSDictionary *userDictionary = (NSDictionary *)[user valueForKey:@"profile"];
    self.helloLabel.text = [NSString stringWithFormat:@"Hello, %@ \nWelcome to Born Together!", userDictionary[kCCUserProfileNameKey]];
    NSString *Alias = user[@"Alias"];
    
    [self.helloLabel setNeedsDisplay];
    
    if (Alias.length < 1) {
        self.helloLabel.text = [self.helloLabel.text stringByAppendingString:@"\nYou should set an Alias"];
        self.helloLabel.textColor = [UIColor redColor];
    } else {
        self.helloLabel.textColor = [UIColor blackColor];
    }
    
    NSString *birthday = userDictionary[@"birthday"];
    NSArray *birthPieces = [birthday componentsSeparatedByString:@"/"];
    NSLog(@"pieces: %@", birthPieces);
    if (birthPieces.count<3) {
        birthPieces = @[@"00", @"00",@"00"];
    }
    if (![user[kCCUserBirthMonth] isEqualToString:birthPieces[0]]||![user[kCCUserBirthDay] isEqualToString:birthPieces[1]]||![user[kCCUserBirthYear] isEqualToString:birthPieces[2]]) {
        [user setObject:birthPieces[0] forKey:kCCUserBirthMonth];
        [user setObject:birthPieces[1] forKey:kCCUserBirthDay];
        [user setObject:birthPieces[2] forKey:kCCUserBirthYear];
        [user saveInBackground];
    }
    
    if ([[PFUser currentUser] valueForKey:@"profile"] && [kCCUserProfileBirthdayKey isEqualToString:@"birthday"] && birthPieces.count<3)
    {
        self.bdayAgeLabel.text = @"Please update your birthday";
    }
    else if ([user valueForKey:@"profile"] && [kCCUserProfileBirthdayKey isEqualToString:@"birthday"] &&birthday)
    {
        NSString *displayDate = [NSString stringWithFormat:@"Interact with other people born on:\n %@/%@", birthPieces[0], birthPieces[1]];
        if ([user[@"EnableYearSearch"] boolValue]) {
            displayDate = [displayDate stringByAppendingFormat:@"/%@", birthPieces[2]];
        }
        self.bdayAgeLabel.text = displayDate;
    }
    
    else if ([user valueForKey:@"profile"] && ![kCCUserProfileBirthdayKey isEqualToString:@"birthday"])
    {
        self.bdayAgeLabel.text = [NSString stringWithFormat:@"Interact with other people born on:\n %@", userDictionary[kCCUserProfileBirthdayKey]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView setHidden:NO];
    [self.noUsersLableHideOrShow setHidden:YES];
    [self.inviteFriendsButtonProperty setHidden:YES];
//    [_loadingTable setHidden:NO];
//    [_loadingTable startAnimating];
    
//    PFUser *currentUser = [PFUser currentUser];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *textField =  [alertView textFieldAtIndex: 0];
    
    if (alertView == _aliasAlert && textField.text && textField.text.length > 0)
    {
        [[PFUser currentUser] setObject:textField.text forKey:@"Alias"];
        [[PFUser currentUser] saveInBackground];
        
        [self viewWillAppear:YES];
    }
    else if(alertView == _aliasAlert && textField.text && textField.text.length == 0)
    {
        _userErroralert = [[UIAlertView alloc] initWithTitle:@"Enter an Alias"
                                                        message:@"A user alias(username) is required to use the application."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Save",nil];
        
        _userErroralert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [_userErroralert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (number == 0)
        {
            PFUser *user = [PFUser currentUser];
            
            self.imageData = [[NSMutableData alloc] init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kCCUserProfileKey][kCCUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if (!urlConnection){
                NSLog(@"Failed to Download Picture");
            }
        }
    }];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"connection did recieve data");
    [self.imageData appendData:data];
    [self uploadImage:self.imageData];
}

-(void)uploadImage:(NSData *)imageData
{
    PFFile *imageFile = [PFFile fileWithName:@"ProfileImage.jpg" data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            // Create a PFObject around a PFFile and associate it with the current user
            [[PFUser currentUser] setObject:imageFile forKey:USERPROFILEIMAGE];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    //[self refresh:nil];
                }
                else
                {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        else
        {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    self.profileImage = [UIImage imageWithData:self.imageData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[BTGUserModel bornTogetherUsers] countOfTotalUsersThatMatchBirthdate];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Born Together";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    
    NSLog(@"%@",[NSString stringWithFormat:@"%lu", (unsigned long)[[BTGUserModel bornTogetherUsers] countOfTotalUsersThatMatchBirthdate]]);
    
    PFObject *user = [[BTGUserModel bornTogetherUsers] userAtIndex:indexPath.row];
    
    NSDictionary *userDict = [user objectForKey:@"profile"];
    
    cell.detailTextLabel.text = userDict[@"gender"];
    
    cell.textLabel.text = user[@"Alias"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"toMatchedProfile" sender:indexPath];
}

#pragma Invitation
-(void)invite
{
    
    if (FBSession.activeSession.isOpen) {
        //The application currently lacks publishing permissions of this sort.
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                  defaultAudience:FBSessionDefaultAudienceFriends
                                                completionHandler:^(FBSession *session, NSError *error) {
                                                    __block NSString *alertText;
                                                    __block NSString *alertTitle;
                                                    if (!error) {
                                                        if ([FBSession.activeSession.permissions
                                                             indexOfObject:@"publish_actions"] == NSNotFound){
                                                            // Permission not granted, tell the user we will not publish
                                                            alertTitle = @"Permission not granted";
                                                            alertText = @"Your action will not be published to Facebook.";
                                                            [[[UIAlertView alloc] initWithTitle:alertTitle
                                                                                        message:alertText
                                                                                       delegate:self
                                                                              cancelButtonTitle:@"OK!"
                                                                              otherButtonTitles:nil] show];
                                                        } else {
                                                            // Permission granted, publish the OG story
                                                            //                                                        [self publishStory];
                                                            [self postInvitation];
                                                        }
                                                        
                                                    } else {
                                                        // There was an error, handle it
                                                        // See https://developers.facebook.com/docs/ios/errors/
                                                    }
                                                }];
        } else {
            [self postInvitation];
        }

    }
}

//posting request invitations requires a native facebook application.
//As such, the application will currently provide the ability to post to the current user's feed. It's also possible to post to other facebook users' walls, but that seems to be limited to one person per post.
- (void) postInvitation
{
    NSDictionary *params = InviteParameters;
    
    //presents the feed dialog. The actual parameters are listed above as a define for the sake of preventing hunting.
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters: params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  if (error) {
                                                      // An error occurred, we need to handle the error
                                                      // See: https://developers.facebook.com/docs/ios/errors
                                                      NSLog(@"Error publishing story: %@", error.description);
                                                  } else {
                                                      if (result == FBWebDialogResultDialogNotCompleted) {
                                                          // User cancelled.
                                                          NSLog(@"User cancelled.");
                                                      } else {
                                                          // Handle the publish feed callback
                                                          //                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                          NSDictionary *urlParams = nil;
                                                          
                                                          if (![urlParams valueForKey:@"post_id"]) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                              
                                                          } else {
                                                              // User clicked the Share button
                                                              NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                              NSLog(@"result %@", result);
                                                          }
                                                      }
                                                  }
                                              }];
}

- (IBAction)inviteFriendsButtonPressed:(UIButton *)sender
{
    [self invite];
}

-(void)showAction
{
    NSString *actionSheetTitle = @"Account Options"; //Action Sheet Title
    NSString *myProfile = @"My Profile";
    NSString *addTwitter = @"Add Twitter";
    //shifted birthday update to MTFirstViewController
    NSString *cancelTitle = @"Cancel Button";

    //for iOS 8+
    if (NSClassFromString(@"UIAlertController")) {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:actionSheetTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *profile = [UIAlertAction actionWithTitle:myProfile style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"toProfile" sender:nil];
        }];
        UIAlertAction *twitter = [UIAlertAction actionWithTitle:addTwitter style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self addTwitter];
        }];
        [actionSheet addAction:cancel];
        [actionSheet addAction:profile];
        [actionSheet addAction:twitter];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
        return;
    }
    
    //prior versions of iOS.
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:myProfile
                                  otherButtonTitles: addTwitter, nil];
    [actionSheet showInView:self.view];
}

-(void)addTwitter
{
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            NSLog (@"%@", error);
        }
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in with Twitter!");
        } else {
            NSLog(@"User logged in with Twitter!");
        }
    }];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [self performSegueWithIdentifier:@"toProfile" sender:nil];
    } else if(buttonIndex == 1)
    {
        //presents the twitter login for authentication.
        [self addTwitter];
    }
}

- (IBAction)inviteButtonPressed:(UIBarButtonItem *)sender
{
    [self invite];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ProfileViewController class]])
    {
        NSIndexPath *path = sender;
        PFUser *matchedUser = [[BTGUserModel bornTogetherUsers] userAtIndex:path.row];
        ProfileViewController *pvc = segue.destinationViewController;
        pvc.matchedUser =  matchedUser;
    } else if ([segue.identifier isEqualToString:@"toProfile"]) {
        MTFirstViewController *fvc = segue.destinationViewController;
        fvc.delegate = self;
    }
}

- (IBAction)showSheet:(UIBarButtonItem *)sender {
    [self showAction];
}

@end
