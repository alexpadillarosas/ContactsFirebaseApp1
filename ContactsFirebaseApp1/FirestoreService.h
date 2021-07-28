//
//  FirestoreService.h
//  ContactsFirebaseApp1
//
//  Created by alex on 24/7/21.
//

#import <Foundation/Foundation.h>
@import Firebase;
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface FirestoreService : NSObject

@property (nonatomic, strong) FIRFirestore *firestore;

-(BOOL) add: (Contact *) contact;
-(BOOL) update: (Contact*) contact;
-(BOOL) deleteC: (Contact*) contact;
-(void) findContactById: (NSString* ) contactId completeBlock: (void(^)(Contact *)) completion;
-(void) findAll: (void(^)(NSMutableDictionary *)) completion;
-(void) query;

@end

NS_ASSUME_NONNULL_END
