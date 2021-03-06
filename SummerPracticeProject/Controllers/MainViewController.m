//
//  MainViewController.m
//  SummerPracticeProject
//
//  Created by Азат Алекбаев on 14/07/2018.
//  Copyright © 2018 Азат Алекбаев. All rights reserved.
//
#import "Constants.h"
#import "MainViewController.h"
#import "NewsTableViewCell.h"
#import "DetailsViewController.h"
@interface MainViewController ()

@property (strong, nonatomic) NSMutableArray *arrayResults;

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;


@property (strong, nonatomic) VKAPIManager *manager;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createRefreshControl];
    
    
    self.arrayResults = [NSMutableArray array];
    self.manager = [VKAPIManager managerWithDelegate:self];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 140;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

-(void)createRefreshControl {
   _refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshTable {
    [self.arrayResults removeAllObjects];
    [self downloadData];
    
    [_refreshControl endRefreshing];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.arrayResults.count != 0) {
        return;
    }
    [self downloadData];
}

-(void)downloadData {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.manager fetchNews];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        });
    });
}



-(void)manager:(VKAPIManager *)manager didSucceedSearchWithData:(NSArray *)data {
    
    if (!data || data.count == 0) {
        return;
    }
    
    [self.arrayResults addObjectsFromArray:data];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell" forIndexPath:indexPath];
    [cell setupCellForItem:self.arrayResults[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayResults.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:SEQUE_DETAILS sender:nil];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)logoutButtonPressed:(id)sender {
    
    
    
    NSString *logout = @"http://api.vk.com/oauth/logout";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:logout]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:60.0];
   
    NSURLSession *session = [NSURLSession sharedSession];
    __block NSData *responseData;
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *responce, NSError *error) {
        responseData = data;
        
        
        if(error == nil && responseData){
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VKAccessUserId"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VKAccessToken"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"VKAccessTokenDate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }] resume];
    
                                    
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailsViewController *vc = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    vc.item = self.arrayResults[indexPath.row];
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
@end
