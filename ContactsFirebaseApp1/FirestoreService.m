//
//  FirestoreService.m
//  ContactsFirebaseApp1
//
//  Created by alex on 24/7/21.
//

#import "FirestoreService.h"
#import "Contact.h"

@implementation FirestoreService

/**
 * Add a contact document referred to by this `FirestoreService`. If no document exists, it
 * is created. If a document already exists, it is overwritten.
 *
 * @param contact A `Contact` containing the fields that make up the document
 *     to be written.
 * @return A BOOL indicating if the contact was added or not.
 */
-(BOOL) add: (Contact *) contact{
    //https://cloud.google.com/firestore/docs/manage-data/add-data
    __block BOOL added = YES;
    @try {
        //Returns a FIRDocumentReference pointing to a new document with an auto-generated ID.
        FIRDocumentReference *newContactReference = [[[self firestore] collectionWithPath:@"Contacts"] documentWithAutoID];
        //Do something with the new contact and then, send it to the DB by calling setData
        
        [newContactReference setData:@{
            @"name": [contact name],
            @"email": [contact email],
            @"phone": [contact phone],
            @"photo": [contact photo],
            @"position": [contact position]
        } completion:^(NSError * _Nullable error) {
            if(error != nil){
                NSLog(@"Error adding document: %@", error);
                added = NO;
            }else {
                NSLog(@"all good...");
            }
        }];
    } @catch (NSException *exception) {
        added = NO;
    }
    return added;
}

/**
    Given a contactId this method will search Contacts collection to retrieve the correspondent document passed in a complete block
    Returns nil if the contact was not found in the database collection
 */
-(void) findContactById: (NSString* ) contactId completeBlock: (void(^)(Contact *)) completion{
    
    __block Contact *contactFound;
    
    FIRDocumentReference *contactReference = [[[self firestore] collectionWithPath:@"Contacts"] documentWithPath:contactId];
    
    [contactReference getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if([snapshot exists]){

            NSDictionary<NSString *,id> *contactDictionary = [snapshot data];
            NSString* idFound = [snapshot documentID];
            
            contactFound = [[Contact alloc] initWithDictionary:contactDictionary];
            [contactFound setAutoId:idFound];
            
            if(completion){
                NSLog(@"contact found in complete block: %@", contactFound);
                completion(contactFound);
            }
            NSLog(@"contact found");

        }else{
            NSLog(@"Document does not exist");
        }
    }];
}

/**
 * Updates fields in the document referred to by this `FirestoreService`. If the document
 * does not exist, the update fails and the specified completion block receives an error.
 *
 * @param contact A `Contact` containing the fields and values with which to update the document.
 * @return A BOOL indicating if the contact was updated or not.
 */
-(BOOL) update: (Contact*) contact{
    __block BOOL updated = YES;
    
    //Fetch the document by using the Id
    FIRDocumentReference *contactReference = [[[self firestore] collectionWithPath:@"Contacts"] documentWithPath:[contact autoId]];
    /**
            To update some fields of a document without overwriting the entire document, use the update() method.
            Else use setData with the merge property, in this case setData is recommended, I'm using update as demonstration
    */
    [contactReference updateData:@{
        @"name": [contact name],
        @"email": [contact email],
        @"phone": [contact phone],
        @"photo": [contact photo],
        @"position": [contact position]
    } completion:^(NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"Error updating document: %@", error);
            updated = NO;
        }else{
            NSLog(@"Document successfully updated");
        }
    }];
    return updated;
}

/**
 * Delete a document referred to by this `FirestoreService`. If the document
 * does not exist, the delete fails and the returns NO.
 *
 * @param contact A `Contact` containing the autoId of the document to delete.
 * @return A BOOL indicating if the contact was deleted or not.
 */
-(BOOL) deleteC: (Contact*) contact{
    /**
        https://firebase.google.com/docs/firestore/manage-data/delete-data
         Warning: Deleting a document does not delete its subcollections!
     
         When you delete a document, Cloud Firestore does not automatically delete the documents within its subcollections.
         You can still access the subcollection documents by reference. For example, you can access the document at path /mycoll/mydoc/mysubcoll/mysubdoc even if you delete the ancestor document at /mycoll/mydoc.

         Non-existent ancestor documents appear in the console, but they do not appear in query results and snapshots.
         If you want to delete a document and all the documents within its subcollections, you must do so manually. For more information, see Delete Collections.
     */
    __block BOOL deleted = YES;
    FIRDocumentReference *contactReference = [[[self firestore] collectionWithPath:@"Contacts"] documentWithPath:[contact autoId]];
    
    [contactReference deleteDocumentWithCompletion:^(NSError * _Nullable error) {
            if(error != nil){
                NSLog(@"Error removing contact: %@", error);
                deleted = NO;
            }
    }];
    return deleted;
}


- (void) query{
    
    FIRCollectionReference *contactsCollectionRef = [[self firestore] collectionWithPath:@"Contacts"];
    //create a query to play with data already registered in the database
    FIRQuery *query = [contactsCollectionRef queryWhereField:@"position" isEqualTo:@"HR"];
    //execute the query
    [query getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"Error retrieving documents: %@", error);
        }else{
            //FIRDocumentSnapshot *document = snapshot.documents.firstObject;
            for (FIRDocumentSnapshot *document in [snapshot documents]) {
                NSLog(@"DocumentId: %@", [document documentID]);
                NSDictionary *myContacts123 = [document data];
                NSLog(@"contact123: %@", myContacts123);
            }
        }
        
    }];
}



/**
 * Reads Documents from a collection referred to by this `FirestoreService`. If no documents exists, it
 * returns nil, else a NSMutableDictionary with the documents found.
 *
 * @param completion A block to execute once the documents have been successfully read from the
 *     server. This block will not be called while the client is offline, though local
 *     changes will be visible immediately.
 */
-(void) findAll: (void(^)(NSMutableDictionary *)) completion{
    //https://firebase.google.com/docs/firestore/query-data/listen
    [[self.firestore collectionWithPath:@"Contacts"] addSnapshotListener:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        
        if(snapshot != nil){
            NSLog(@"Found %li documents in the db", [snapshot count]);
            if(completion){
                NSMutableDictionary *contactsDictionary = [NSMutableDictionary new];
                for (FIRQueryDocumentSnapshot* snap in [snapshot documents]) {
                    NSDictionary *contactDataDictionary = [snap data];
                    NSString *contactId = [snap documentID];
                    
                    [contactsDictionary setObject:contactDataDictionary forKey:contactId];
                }
                completion(contactsDictionary);
            }
        }else{
            NSLog(@"there is no data");
        }
        
    }];
}


 

@end
