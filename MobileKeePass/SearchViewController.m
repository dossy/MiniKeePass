/*
 * Copyright 2011 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "SearchViewController.h"
#import "MobileKeePassAppDelegate.h"
#import "EntryViewController.h"

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Search";
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.view addSubview:searchBar];
    
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    
    results = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSIndexPath *indexPath = [tableView indexPathForSelectedRow];
    if (indexPath != nil){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)dealloc {
    [searchBar release];
    [searchController release];
    [results release];
    [super dealloc];
}

- (void)clearResults {
    // Clear the search text
    searchBar.text = @"";
    
    // Delete all the rows
    [results removeAllObjects];
    
    // Pop off any entry views
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // Reload the table
    [tableView reloadData];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [results removeAllObjects];
    
    MobileKeePassAppDelegate *appDelegate = (MobileKeePassAppDelegate*)[[UIApplication sharedApplication] delegate];
    DatabaseDocument *databaseDocument = appDelegate.databaseDocument;
    
    if (databaseDocument != nil) {
        // Perform the search
        [databaseDocument searchGroup:databaseDocument.kdbTree.root searchText:searchString results:results];
    }
    
    return YES;
}

- (NSInteger)tableView:(UITableView*)control numberOfRowsInSection:(NSInteger)section {
    return [results count];
}

- (UITableViewCell*)tableView:(UITableView*)control cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [control dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    MobileKeePassAppDelegate *appDelegate = (MobileKeePassAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // Configure the cell.
    KdbEntry *e = [results objectAtIndex:indexPath.row];
    cell.textLabel.text = e.title;
    cell.imageView.image = [appDelegate loadImage:e.image];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KdbEntry *e = [results objectAtIndex:indexPath.row];
    
    EntryViewController *entryViewController = [[EntryViewController alloc] initWithStyle:UITableViewStyleGrouped];
    entryViewController.entry = e;
    entryViewController.title = e.title;
    [self.navigationController pushViewController:entryViewController animated:YES];
    [entryViewController release];
}

@end