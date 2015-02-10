//
//  BTGUserModel.m
//  BornTogether
//
//  Created by Nutech Systems on 11/14/14.
//  Copyright (c) 2014 Stefan Brown. All rights reserved.
//

#import "BTGUserModel.h"
#import "MTConstants.h"

@interface BTGUserModel ()

@property (atomic) NSMutableArray *currentUsers;
@property (nonatomic, weak) PFUser *currentUser;
@property (nonatomic, strong) PFQuery *query;
@property (nonatomic) int count;

@end

@implementation BTGUserModel

-(instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[ bornTogetherUsers]" userInfo:nil];
    return nil;
}

-(void)updateBirthdate{
    [self updateUserList];
}

-(instancetype)initPrivate
{
    self=[super init];
    if (self) {
        _currentUsers = [[NSMutableArray alloc] init];
        _currentUser = [PFUser currentUser];
        _query = [PFUser query];
    }
    return self;
}

+(BTGUserModel *)bornTogetherUsers
{
    static BTGUserModel *sharedUserStore = nil;
    if (!sharedUserStore) {
        sharedUserStore = [[self alloc] initPrivate];
    }
    return sharedUserStore;
}

-(void)updateUserList
{
    NSMutableArray *users = _currentUsers;
    PFQuery *query = [PFUser query];
    
    //remove current user
    [query whereKey:@"objectId" notEqualTo:_currentUser.objectId];
    if (!_currentUser[kCCUserBirthMonth]) {
        return;
    }
    //query for same month.
    [query whereKey:kCCUserBirthMonth equalTo:_currentUser[kCCUserBirthMonth]];
    
    //query for same day
    [query whereKey:kCCUserBirthDay equalTo:_currentUser[kCCUserBirthDay]];
    
    //query for same year
    if ([[[PFUser currentUser]objectForKey:USERYEARSEARCH] boolValue]) {
        [query whereKey:kCCUserBirthYear equalTo:_currentUser[kCCUserBirthYear]];
    }
    
    [query addAscendingOrder:@"Alias"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [users addObjectsFromArray: objects];
        [self.delegate updatedUserList];
    }];
}

-(unsigned long)countOfTotalUsersThatMatchBirthdate{
    unsigned long count = _count;
//    count = _count;
    PFQuery *query = [PFUser query];
    //Don't include current user
    if (!count) {
        [query whereKey:@"objectId" notEqualTo:_currentUser.objectId];
        if (!_currentUser[kCCUserBirthMonth]) {
            return 0;
        }
        //query for same month.
        [query whereKey:kCCUserBirthMonth equalTo:_currentUser[kCCUserBirthMonth]];
        
        //query for same day
        [query whereKey:kCCUserBirthDay equalTo:_currentUser[kCCUserBirthDay]];
        
        //query for same year
        if ([[[PFUser currentUser]objectForKey:USERYEARSEARCH] boolValue]) {
            [query whereKey:kCCUserBirthYear equalTo:_currentUser[kCCUserBirthYear]];
        }
        
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            _count = number;
            [self.delegate updatedUserList];
        }];
    }
    
    return count;
}

-(PFUser *)userAtIndex:(unsigned long)index
{
    if(index >= _currentUsers.count){
        [self updateUserList];
        return nil;
    }
    PFUser *user = _currentUsers[index];
    if (user) {
        return user;
    }
    NSLog(@"No user found at index: %lu", index);
    return [[PFUser alloc]init];
}
@end
