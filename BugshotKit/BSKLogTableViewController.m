//  BSKLogTableViewController.m
//  See included LICENSE file for the (MIT) license.
//  Created by Bogdan Poplauschi on 1/31/14.

#import "BSKLogTableViewController.h"
#import "BugshotKit.h"

@interface BSKLogTableViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UITableView *consoleView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *filteredMessages;

@end


@implementation BSKLogTableViewController

- (instancetype)init
{
    if ( (self = [super init]) ) {
        self.title = @"Debug Log";
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateLiveLog:) name:BSKNewLogMessageNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_main_queue(), ^{ [self updateLiveLog:nil]; });
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:BSKNewLogMessageNotification object:nil];
}

- (void)loadView
{
    CGRect frame = UIScreen.mainScreen.applicationFrame;
    frame.origin = CGPointZero;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.autoresizesSubviews = YES;
    
    self.consoleView = [[UITableView alloc] initWithFrame:frame];
    self.consoleView.dataSource = self;
    self.consoleView.delegate = self;
    self.consoleView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self.consoleView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, 44)];
    self.searchBar.placeholder = @"Filter the logs";
    self.searchBar.showsCancelButton = YES;
    self.searchBar.delegate = self;
    
    self.consoleView.tableHeaderView = self.searchBar;
    
    self.view = view;
}

- (void)updateLiveLog:(NSNotification *)n
{
    if (! self.isViewLoaded) return;
    
    NSArray *messages = [BugshotKit sharedManager].formattedConsoleMessages;
    
    NSString *filter = self.searchBar.text;
    if (filter.length) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", filter];
        self.filteredMessages = [messages filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredMessages = messages;
    }
    
    [self.consoleView reloadData];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LogCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.numberOfLines = 0;
    }
    
    cell.textLabel.text = self.filteredMessages[indexPath.row];
    
    return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)inSearchBar {
    [inSearchBar resignFirstResponder];
    [self updateLiveLog:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)inSearchBar {
    [inSearchBar resignFirstResponder];
    [self updateLiveLog:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self updateLiveLog:nil];
}

@end
