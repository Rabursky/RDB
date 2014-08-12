//
//  KLViewController.m
//  KULE Example
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "KLViewController.h"
#import "RDBObject+Helpers.h"
#import "KLTask.h"
#import "RDBCoreData.h"

@interface KLViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation KLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"KLTask"];
    // Configure the request's entity, and optionally its predicate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    self.fetchController = [[NSFetchedResultsController alloc]
                            initWithFetchRequest:fetchRequest
                            managedObjectContext:[RDBCoreData managedObjectContext]
                            sectionNameKeyPath:nil
                            cacheName:nil];
    self.fetchController.delegate = self;
    NSError *error;
    BOOL success = [self.fetchController performFetch:&error];
    
//    [KLTask allWithCompletionBlock:^(id object, id metadata, NSError *error) {
//        [RDBCoreData saveContext];
//    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addTask:(id)sender {
    if (self.textField.text.length > 0) {
        self.textField.enabled = NO;
        KLTask *newTask = [[KLTask alloc] init];
        newTask.name = self.textField.text;
        newTask.author = @"Me";
        newTask.date = [NSDate date];
        [newTask saveWithCompletionBlock:^(id object, id metadata, NSError *error) {
            self.textField.enabled = YES;
            self.textField.text = @"";
        }];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - TableView Delegate and Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    KLTask *task = [self.fetchController objectAtIndexPath:indexPath];
    cell.textLabel.text = task.name;
    cell.detailTextLabel.text = task.date.description;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        KLTask *task = [KLTask instanceWithManagedObject:[self.fetchController objectAtIndexPath:indexPath]];
        [task remove];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath*)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath*)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
        case NSFetchedResultsChangeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } break;
            
        default:
            break;
    }
}

@end
