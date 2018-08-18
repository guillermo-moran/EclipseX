#import <Preferences/Preferences.h>

@interface ESCreditsPanel: PSListController {
}

-(void)fr0st;
-(void)krevony;
-(void)andywiik;
-(void)reddit;

@end

@implementation ESCreditsPanel

- (instancetype)init {
	self = [super init];
    
	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Credits" target:self] retain];
	}
    
	return self;
}

- (void)fr0st {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=fr0st"]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=fr0st"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/fr0st"]];
    }
}

- (void)hbang {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=hbangws"]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=hbangws"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/hbangws"]];
    }
}

- (void)krevony {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=krevony"]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=krevony"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/krevony"]];
    }
}

- (void)creaturesurvive {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=CreatureSurvive"]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=CreatureSurvive"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/CreatureSurvive"]];
    }
}

- (void)libcolorpicker {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://bitbucket.org/pixelfiredev/libcolorpicker/"]];
}

- (void)andywiik {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=andywiik"]]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=andywiik"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/andywiik"]];
    }
}

- (void)reddit {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://reddit.com/r/jailbreak"]];
    
}

@end
// vim:ft=objc
