//
//  RootViewController.h
//  iSprinkle
//
//  Created by Grown-ups on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
    NSMutableArray *_waterings;
    NSMutableData *receivedData;
}

@property (retain) NSMutableArray *waterings;

@end
