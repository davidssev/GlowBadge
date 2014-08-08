#import <Preferences/Preferences.h>

#define kName @"GlowBadge"
#import <Custom/defines.h>

#define kSettingsPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.sassoty.glowbadge.plist"]

@interface GlowBadgeListController: PSListController {
}
- (void)openTwitter;
- (void)openDonate;
- (void)openWebsite;
@end

@implementation GlowBadgeListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"GlowBadge" target:self] retain];
	}
	return _specifiers;
}
- (void)openTwitter {
	url(@"http://twitter.com/Sassoty");
}
- (void)openDonate {
	url(@"http://bit.ly/sassotypp");
}
- (void)openWebsite {
	url(@"http://sassoty.com");
}
@end

// vim:ft=objc

@interface BadgeWhitelistListController: PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *tabView;
    NSMutableArray *appArray;
    int indexPathToUse;
    NSMutableDictionary *prefs;
}
@end

@implementation BadgeWhitelistListController

- (void)viewDidLoad {

    tabView = [[UITableView alloc] initWithFrame:kBounds];

    tabView.delegate = self;
    tabView.dataSource = self;
    [tabView setAlwaysBounceVertical:YES];

    prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:kSettingsPath];
    if(!prefs) prefs = [[NSMutableDictionary alloc] init];
    
    appArray = prefs[@"BadgeWhitelist"];
    if(!appArray)
        appArray = [[NSMutableArray alloc] init];

    [self.view addSubview:tabView];
    [tabView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];

}

- (NSInteger)tableView:(UITableView* )tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0) return 1;
    return [appArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView* )tableView{
    return 2;
}

- (NSString* )tableView:(UITableView* )tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) return @"Add";
    return @"Settings";
}

- (void)tableView:(UITableView* )tableView didSelectRowAtIndexPath:(NSIndexPath* )indexPath {

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if(indexPath.section == 0) {

        if(indexPath.row == 0) {

            UIAlertView* alert = [[UIAlertView alloc] 
            initWithTitle:kName
            message:@"Please enter the display name exactly as it appears:"
            delegate:self
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:@"Save", nil];

            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];

            UITextField* user = [alert textFieldAtIndex:0];
            [user setPlaceholder:@"App Display Name"];

            [alert setTag:1];
            [alert show];
            [alert release];

        }

    }

    if(indexPath.section == 1) {

        indexPathToUse = indexPath.row;

        UIAlertView* alert = [[UIAlertView alloc] 
            initWithTitle:kName
            message:@"Edit name:"
            delegate:self
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:@"Save", nil];

        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];

        UITextField* user = [alert textFieldAtIndex:0];
        [user setPlaceholder:@"App Display Name"];
        [user setText:[appArray objectAtIndex:indexPath.row]];

        [alert setTag:2];
        [alert show];
        [alert release];

    }

}

- (void)alertView:(UIAlertView* )alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) return;

    NSString* app = [alertView textFieldAtIndex:0].text;
    
    prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:kSettingsPath];
    if (alertView.tag == 1 && buttonIndex == 1) {

        [appArray addObject:app];

        prefs[@"BadgeWhitelist"] = appArray;
        [prefs writeToFile:kSettingsPath atomically:YES];

        [tabView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];

        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFSTR("com.sassoty.glowbadge/preferencechanged"),
            NULL,
            NULL,
            true
            );

    }

    if(alertView.tag == 2) {
        if(buttonIndex == 1) {

            [appArray removeObjectAtIndex:indexPathToUse];
            [appArray insertObject:app atIndex:indexPathToUse];

            prefs[@"BadgeWhitelist"] = appArray;
            [prefs writeToFile:kSettingsPath atomically:YES];

            [tabView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];

            CFNotificationCenterPostNotification(
                CFNotificationCenterGetDarwinNotifyCenter(),
                CFSTR("com.sassoty.glowbadge/preferencechanged"),
                NULL,
                NULL,
                true
                );

        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 1) return YES;
	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if(editingStyle == UITableViewCellEditingStyleDelete) {

        NSString* logLog = [NSString stringWithFormat:@"Deleting... %@", [appArray objectAtIndex:indexPath.row]];
        XLog(logLog);

		[appArray removeObjectAtIndex:indexPath.row];

        prefs[@"BadgeWhitelist"] = appArray;
        [prefs writeToFile:kSettingsPath atomically:YES];

        [tabView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];

        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFSTR("com.sassoty.glowbadge/preferencechanged"),
            NULL,
            NULL,
            true
            );

	}
}

- (UITableViewCell* )tableView:(UITableView* )tableView cellForRowAtIndexPath:(NSIndexPath* )indexPath
{
    
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    //cell.textLabel.text = [NSString stringWithFormat:@"%@", str];

    if(indexPath.section == 1) cell.textLabel.text = [appArray objectAtIndex:indexPath.row];
    if(indexPath.section == 0) {
        if(indexPath.row == 0) cell.textLabel.text = @"Add App";
    }

    return cell;
    
}

@end
