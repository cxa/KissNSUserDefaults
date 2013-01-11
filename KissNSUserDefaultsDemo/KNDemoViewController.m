//
//  KNDemoViewController.m
//  KissNSUserDefaults
//
//  Created by Chen Xian'an on 1/1/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import "KNDemoViewController.h"
#import "NSUserDefaults+KissDemo.h"

static NSString *cellID = @"CELLID";

@interface KNDemoViewController(){
  NSArray *_titles;
  NSString *_userInfoStr;
  id _observer;
}

@end

@implementation KNDemoViewController

- (id)init
{
  if (self = [super initWithStyle:UITableViewStyleGrouped]){
    _titles = @[@".string", @".integer", @".floatValue", @".boolValue", @".doubleValue"];
    _userInfoStr = [NSString stringWithFormat:@".doubleValue is %f, .boolValue via custom getter .isBoolValue is %d", [NSUserDefaults standardUserDefaults].doubleValue, [NSUserDefaults standardUserDefaults].isBoolValue];
    typeof(self) __weak weakSelf = self;
    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:KissNSUserDefaultsDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note){
      typeof(self) restrongSelf = weakSelf;
      if (!restrongSelf)
        return;
      
      restrongSelf->_userInfoStr = [NSString stringWithFormat:NSLocalizedString(@"KissNSUserDefaultsDidChangeNotification user info:\n%@", nil), [[note userInfo] description]];
      [restrongSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }];
  }
  
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (void)loadView
{
  [super loadView];
  
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
}

#pragma mark - table view datasource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
  if (section == 0)
    return [_titles count];
  
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
  if (indexPath.section == 0){
    cell.textLabel.text = _titles[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } else {
    cell.textLabel.text = _userInfoStr;
    cell.textLabel.font = [UIFont fontWithName:@"Courier" size:15.];
    cell.textLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0)
    return 44.;
  
  return 240;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
  if (section == 0)
    return @"NSUserDefaults (KissDemo)";
  
  return nil;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section != 0)
    return;
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  switch (indexPath.row){
    case 0:
      ud.string = @"Bla bla...";
      break;
    case 1:
      ud.integer = 1024;
      break;
    case 2:
      ud.floatValue = 1.024;
      break;
    case 3:
      ud.boolValue = YES;
      break;
    case 4:
      ud.doubleValue = 10.24;
    default:
      break;
  }
}

@end
