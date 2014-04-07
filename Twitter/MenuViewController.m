//
//  MenuViewController.m
//  Twitter
//
//  Created by Tripta Gupta on 4/6/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import "MenuViewController.h"
#import "ProfileViewController.h"
#import "TimelineViewController.h"
#import "ComposeViewController.h"
#import "User.h"

@interface MenuViewController ()

@property (nonatomic, strong) NSArray *viewControllers;
@property (weak, nonatomic) IBOutlet UIView *containerView;

- (IBAction)onProfileButton:(id)sender;
- (IBAction)onTimelineButton:(id)sender;
- (IBAction)onMentionsButton:(id)sender;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // non-working version: self.viewControllers = @[[[ProfileViewController alloc] init], [[TimelineViewController alloc] init], [[TimelineViewController alloc] init]];
        self.viewControllers = @[[[ProfileViewController alloc] init], [[TimelineViewController alloc] initWithShowMentions:NO], [[TimelineViewController alloc] initWithShowMentions:YES]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Setting navigation buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStyleDone target:self action:@selector(onSignOutButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onComposeButton)];
    
    // Setting toolbar items on bottom
    UIBarButtonItem *signOutButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Sign Out"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(onSignOutButton)];
    
    UIBarButtonItem *spaceBarButton = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                       target:nil
                                       action:nil];
    
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Compose"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(onComposeButton)];
    
    
    NSArray *toolbarButtons = @[signOutButton, spaceBarButton, composeButton];
    [self setToolbarItems:toolbarButtons];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
    [self.containerView addGestureRecognizer:panGestureRecognizer];
    
    UIView *profileView = ((UIViewController *)self.viewControllers[0]).view;
    profileView.frame = self.containerView.frame;
    
    UIView *timelineView = ((UIViewController *)self.viewControllers[1]).view;
    timelineView.frame = self.containerView.frame;
    
    UIView *mentionsView = ((UIViewController *)self.viewControllers[2]).view;
    mentionsView.frame = self.containerView.frame;
    
    [self.containerView addSubview:profileView];
    [self.containerView addSubview:mentionsView];
    [self.containerView addSubview:timelineView];
}

- (void)onPan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    // Gets distance moved x,y
    CGPoint translation = [panGestureRecognizer translationInView:self.view.superview];
    
    // sets the center as old center plus amount moved in each direction
    panGestureRecognizer.view.center = CGPointMake(panGestureRecognizer.view.center.x + translation.x, 284);
    
    // Prevents view from moving offscreen to the left
    if (panGestureRecognizer.view.center.x < 160) {
        panGestureRecognizer.view.center = CGPointMake(160, 284);
        
    // Prevents view from moving too far to the right
    } else if (panGestureRecognizer.view.center.x > 450) {
        panGestureRecognizer.view.center = CGPointMake(450, 284);
    }
    
    // Resets the translation property for next use
    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onProfileButton:(id)sender
{
    NSLog(@"profile button");
    UIView *profileView = ((UIViewController *)self.viewControllers[0]).view;
    [self.containerView bringSubviewToFront:profileView];
}

- (IBAction)onTimelineButton:(id)sender
{
    NSLog(@"timeline button");
    UIView *timelineView = ((UIViewController *)self.viewControllers[1]).view;
    [self.containerView bringSubviewToFront:timelineView];
}

- (IBAction)onMentionsButton:(id)sender
{
    NSLog(@"mention button");
    UIView *mentionsView = ((UIViewController *)self.viewControllers[2]).view;
    [self.containerView bringSubviewToFront:mentionsView];
}

- (void)onSignOutButton
{
    [User setCurrentUser:nil];
}

- (void)onComposeButton
{
    NSLog(@"Compose Button Clicked");
    ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController: composeVC];
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
