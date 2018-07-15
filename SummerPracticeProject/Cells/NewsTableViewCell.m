//
//  NewsTableViewCell.m
//  SummerPracticeProject
//
//  Created by Азат Алекбаев on 14/07/2018.
//  Copyright © 2018 Азат Алекбаев. All rights reserved.
//

#import "NewsTableViewCell.h"
#import "UIKit+AFNetworking.h"
#import "AFNetworking/AFNetworking.h"
#import "Constants.h"

@interface NewsTableViewCell ()
@property (retain, nonatomic) IBOutlet UILabel *newsDateTime;
@property (retain, nonatomic) IBOutlet UILabel *text;

@property (retain, nonatomic) IBOutlet UILabel *showAll;


@end

@implementation NewsTableViewCell

-(void) setupCellForItem:(NewItem *)item {
    //owner
    self.newsDateTime.text = item.formatedDate;
    if (item.text.length > SHORT_TEXT_LENGTH) {
        self.text.text = [[item.text substringToIndex:SHORT_TEXT_LENGTH] stringByAppendingString:@"..."];
        self.showAll.text = @"Показать полностью...";
    } else {
        self.text.text = item.text;
        
    }
    if (item.text.length == 0) {
        self.text.text = @"Текста нет";
    }
}


- (void)dealloc {
    [_newsDateTime release];
    [_showAll release];
    [_text release];
    [super dealloc];
}
@end
