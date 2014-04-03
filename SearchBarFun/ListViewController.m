//
//  ListViewController.m
//  SearchBarFun
//
//  Created by Shaun Ervine on 3/04/2014.
//  Copyright (c) 2014 Shaun Ervine. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@end

@implementation ListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.items = [NSMutableArray array];
    for (int i = 1; i <= 50; i++) {
      [self.items addObject:[NSString stringWithFormat:@"item %d", i]];
    }
  }
  return self;
}

- (void)loadView
{
  self.view = [UIView new];
  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
  self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.tableView.backgroundColor = [UIColor whiteColor];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  
  // place search bar coordinates where the navbar is position - offset by statusbar
  self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
  
  [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"List";
  
  UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(toggleSearch)];
  self.navigationItem.rightBarButtonItem = searchButton;

  // only here to simulate nav stack
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
  self.navigationItem.leftBarButtonItem = backButton;
  
  self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
  self.searchController.searchResultsDataSource = self;
  self.searchController.searchResultsDelegate = self;
  self.searchController.delegate = self;
}

#pragma mark - Search controller

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
  // force tableview to top
  int heightOfSearchBar = 44;
  int yOffset = -([self.topLayoutGuide length] + heightOfSearchBar); // toplayout guide + ios 7 assumes searchbar displayed
  self.tableView.contentOffset = CGPointMake(0, yOffset);
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
  // reposition the table where we want after search has completed
  // need to reschedule on runloop to rejig the table layout and correct the
  // offset and insets given no search bar will be displayed at the top of the controller
  // as we remove it
  dispatch_async(dispatch_get_main_queue(), ^{
    self.tableView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length], 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(0, -[self.topLayoutGuide length]);
  });
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
  [self.searchBar removeFromSuperview];
}

- (void)toggleSearch
{
  [self.view addSubview:self.searchBar];
  [self.searchController setActive:YES animated:YES];
  [self.searchBar becomeFirstResponder];
}

#pragma mark - Tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identifier = @"cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }
  cell.textLabel.text = self.items[indexPath.row];
  
  return cell;
}

@end
