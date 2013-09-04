//
//  KLViewController.m
//  KULE Example
//
//  Created by Marcin Raburski on 04.09.2013.
//  Copyright (c) 2013 Marcin Raburski. All rights reserved.
//

#import "KLViewController.h"
#import "RDB.h"
#import "KLTask.h"

@interface KLViewController ()

@property (nonatomic, strong) NSArray *tasks;

@end

@implementation KLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [RDB sharedDB].url = [NSURL URLWithString:@"http://localhost:8000"];
    [KLTask allWithCompletionBlock:^(id object, id metadata, NSError *error) {
        self.tasks = object;
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
    
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
        [newTask updateWithCompletionBlock:^(id object, id metadata, NSError *error) {
            self.textField.enabled = YES;
            self.textField.text = @"";
            self.tasks = [self.tasks arrayByAddingObject:newTask];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }];
    }
}

#pragma mark - TableView Delegate and Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tasks.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    KLTask *task = [self.tasks objectAtIndex:indexPath.row];
    cell.textLabel.text = task.name;
    cell.detailTextLabel.text = task.author;
    return cell;
}

@end
