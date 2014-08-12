//
//  KLViewController.h
//  KULE Example
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface KLViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITextField *textField;

- (IBAction)addTask:(id)sender;

@end
