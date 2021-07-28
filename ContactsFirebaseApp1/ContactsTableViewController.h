//
//  ContactsTableViewController.h
//  ContactsFirebaseApp1
//
//  Created by alex on 25/7/21.
//

#import <UIKit/UIKit.h>
@import Firebase;

NS_ASSUME_NONNULL_BEGIN

@interface ContactsTableViewController : UITableViewController
    
@property (nonatomic, strong) FIRFirestore *firestore;
@property (strong, nonatomic) IBOutlet UITableView *contactsTableView;
@property (strong, nonatomic) NSMutableDictionary *contactsDictionary;


@end

NS_ASSUME_NONNULL_END
