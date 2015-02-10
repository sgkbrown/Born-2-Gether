//  ImprovedChatViewController.m
//  BornTogether
//
//  Created by Stefan Brown on 11/6/14.
//  Copyright (c) 2014 Nutech Systems. All rights reserved.

#import "ImprovedChatViewController.h"
#import <JSQTextMessage.h>
#import <JSQMessagesAvatarImageFactory.h>
#import <JSQMessagesBubbleImageFactory.h>
#import <JSQMessages.h>
#import <Parse/Parse.h>

@interface ImprovedChatViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) NSString *currentUserAlias;
@property (nonatomic, weak) NSString *currentUserObjectID;
//@property (nonatomic, weak) NSString *matchedUserAlias;
@property (nonatomic, strong) JSQMessagesAvatarImage *matchedAvatar;
@property (nonatomic, strong) JSQMessagesAvatarImage *currentAvatar;
@property (nonatomic, strong) JSQMessagesBubbleImageFactory *bubbleFactory;

@property (nonatomic, strong) UIColor *matchedColor;
@property (nonatomic, strong) UIColor *currentColor;

@property (atomic, strong) PFQuery *query;

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSMutableArray *posts;
@property (atomic) BOOL running;

@end

@implementation ImprovedChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _running = YES;
    _className = @"chat";

    self.automaticallyScrollsToMostRecentMessage = YES;
    
    PFUser *currentUser = [PFUser currentUser];
    _currentUserAlias = [currentUser objectForKey:@"Alias"];
    _currentUserObjectID = currentUser.objectId;
    
    if ([currentUser[@"profile"][@"gender"] isEqualToString:@"male"]) {
        _currentColor = [UIColor colorWithRed:51.0/255.0 green:191.75/255.0 blue:255.0/255.0 alpha:1.0];
    } else {
        _currentColor = [UIColor colorWithRed:255.0/255.0 green:96.0/255.0 blue:102.0/255.0 alpha:1.0];
    }
    
    if ([_matchedUser[@"profile"][@"gender"] isEqualToString:@"male"]) {
        _matchedColor = [UIColor colorWithRed:51.0/255.0 green:191.75/255.0 blue:255.0/255.0 alpha:1.0];
    } else {
        _matchedColor = [UIColor colorWithRed:255.0/255.0 green:96.0/255.0 blue:102.0/255.0 alpha:1.0];
    }
    
//    _matchedUserAlias = _matchedUser[@"Alias"];
    
    NSLog(@"User matched with that has same birthday: %@", self.matchedUser);
    NSLog(@"Currently logged in user: %@", currentUser);
    _posts = [[NSMutableArray alloc]init];
    
    _matchedImage = [JSQMessagesAvatarImageFactory circularAvatarImage:_matchedImage withDiameter:_matchedImage.size.width];
    
    _matchedAvatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:_matchedImage diameter:_matchedImage.size.width];
    
    _currentImage = [JSQMessagesAvatarImageFactory circularAvatarImage:_currentImage withDiameter:_currentImage.size.width];
    
    _currentAvatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:_currentImage diameter:_currentImage.size.width];
    
    _bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
    NSString *userID = _currentUserObjectID;
    NSString *matchedID = _matchedUser.objectId;
    
    PFQuery *query1 = [PFQuery queryWithClassName:_className];
    PFQuery *query2 = [PFQuery queryWithClassName:_className];
    
    //find cases where sender is currentUser and matched user is receiver.
    [query1 whereKey:@"sender" equalTo:userID];
    [query1 whereKey:@"receiver" equalTo:matchedID];
    //find cases where receiver is currentUser and matched user is sending.
    [query2 whereKey:@"sender" equalTo:matchedID];
    [query2 whereKey:@"receiver" equalTo:userID];
    
    NSLog(@"Trying to retrieve from cache");
    _query = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    _query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [_query orderByDescending:@"createdAt"];
    _query.limit = 20;
    
    [self loadLocalChat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"You tapped the avatar at: %lu", indexPath.row);
}

#pragma JSQMessagesViewDataSource
-(NSString *)senderDisplayName
{
    return _currentUserAlias;
}

-(NSString *)senderId
{
    return _currentUserObjectID;
}

-(void)viewWillDisappear:(BOOL)animated
{
    _running = NO;
}

-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *post = _posts[indexPath.row];
    PFUser *user = [PFUser currentUser];
    
    NSString *senderID = post[@"sender"];
    NSString *alias;
    if ([user.objectId isEqualToString:senderID]) {
        alias = _currentUserAlias;
    } else {
        alias = _matchedUser[@"Alias"];
    }
    PFFile *imageFile =post[@"imageContent"];

    if (imageFile) {
//        JSQMediaMessage *message;
        NSData *imageData = [imageFile getData];
        UIImage *imageContent = [UIImage imageWithData:imageData];
        JSQPhotoMediaItem *media = [[JSQPhotoMediaItem alloc] initWithImage:imageContent];
        JSQMediaMessage *message = [JSQMediaMessage messageWithSenderId:senderID displayName:alias media:media];
        return message;
    } else {
        NSString *content = post[@"content"];
        JSQTextMessage *message = [JSQTextMessage messageWithSenderId:senderID displayName:alias text:content];
        return message;
    }
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *post = _posts[indexPath.row];
    NSString *senderID = post[@"sender"];
//    NSString *senderGender =
    JSQMessagesBubbleImage *bubble;
    
    
    if ([senderID isEqualToString:_currentUserObjectID]) {
        bubble = [_bubbleFactory outgoingMessagesBubbleImageWithColor:_currentColor];
    } else {
        bubble = [_bubbleFactory incomingMessagesBubbleImageWithColor:_matchedColor];
    }
    return bubble;
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *post = _posts[indexPath.row];
    NSString *userID = post[@"sender"];
    if ([_currentUserObjectID isEqualToString:userID]) {
        return _currentAvatar;
    } else {
        return _matchedAvatar;
    }
}

#pragma JSQMessagesCollectionViewController
-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    PFObject *post = [[PFObject alloc]initWithClassName:_className];
    post[@"sender"] = _currentUserObjectID;
    post[@"receiver"] = _matchedUser.objectId;
    post[@"content"] = text;
    post[@"currentSenderName"] = _currentUserAlias;
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_posts addObject:post];
        [self finishSendingMessage];
    }];
    self.inputToolbar.contentView.textView.text = @"";
}

-(void)didPressAccessoryButton:(UIButton *)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:^{}];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *myImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    PFObject *post = [[PFObject alloc]initWithClassName:_className];
    post[@"sender"] = _currentUserObjectID;
    post[@"receiver"] = _matchedUser.objectId;
    post[@"currentSenderName"] = _currentUserAlias;
    NSData *imageData = UIImageJPEGRepresentation(myImage, 0.05f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [post setObject:imageFile forKey:@"imageContent"];
            [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [_posts addObject:post];
                    [self finishSendingMessage];

                }
            }];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:^{}];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma CollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _posts.count;
}

#pragma mark - Parse
//handles the chat database querying. Polls database on a 5s interval.
- (void)loadLocalChat
{
//    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(backgroundQueue,^{
//        while (_running) {
            [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Successfully retrieved %lu posts from cache.", (unsigned long)objects.count);
                    [_posts removeAllObjects];
                    if (objects.count != 0) {
                        [_posts addObjectsFromArray:[[objects reverseObjectEnumerator] allObjects]];
                    }
                    [self finishReceivingMessage];
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
//            [NSThread sleepForTimeInterval:5];
//        }
////    });
}


@end