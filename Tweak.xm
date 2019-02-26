/*
 _______  _______  _       _________ _______  _______  _______
 (  ____ \(  ____ \( \      \__   __/(  ____ )(  ____ \(  ____ \
 | (    \/| (    \/| (         ) (   | (    )|| (    \/| (    \/
 | (__    | |      | |         | |   | (____)|| (_____ | (__
 |  __)   | |      | |         | |   |  _____)(_____  )|  __)
 | (      | |      | |         | |   | (            ) || (
 | (____/\| (____/\| (____/\___) (___| )      /\____) || (____/\
 (_______/(_______/(_______/\_______/|/       \_______)(_______/

 NIGHT MODE FOR IOS - UIKit Hooks
 COPYRIGHT © 2014 GUILLERMO MORAN

*/

#import <objc/runtime.h>

#import "Interfaces.h"
#include "UIColor+Eclipse.h"
#include "UIImage+Eclipse.h"

#include <notify.h>

/*
d8888b. d8888b. d88888b d88888b .d8888.
88  `8D 88  `8D 88'     88'     88'  YP
88oodD' 88oobY' 88ooooo 88ooo   `8bo.
88~~~   88`8b   88~~~~~ 88~~~     `Y8b.
88      88 `88. 88.     88      db   8D
88      88   YD Y88888P YP      `8888Y'
*/

///

static BOOL isClockApp;

static BOOL shouldOverrideStatusBarStyle = YES;

static NSDictionary *prefs;

extern "C" void BKSTerminateApplicationGroupForReasonAndReportWithDescription(int a, int b, int c, NSString *description);



static void quitAllApps() {

    [[%c(SBSyncController) sharedInstance] _killApplicationsIfNecessary];

    [[[%c(SBAppSwitcherModel) sharedInstance] valueForKey:@"_recentDisplayItems"] removeAllObjects];

}

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

static void quitAppsRequest(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

    /*
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Please Wait"
                         message:@"Killing All Applications..."
                          delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:nil];
    [alert show];
    */

    quitAllApps();

    //[alert dismissWithClickedButtonIndex:0 animated:YES];
}

//Invert Colors Filter
//By Andy Wiik

struct CAColorMatrix {
    float m11, m12, m13, m14, m15;
    float m21, m22, m23, m24, m25;
    float m31, m32, m33, m34, m35;
    float m41, m42, m43, m44, m45;
};

#import "CAFilter.h"

void applyInvertFilter(UIView *view) {

    NSMutableArray *currentFilters = [NSMutableArray new];
    for (CAFilter *filter in view.layer.filters) {
        if ([filter.name isEqualToString:@"invertFilter"]) {
            return;
        } else {
            [filter setValue:[NSNumber numberWithBool:NO] forKey:@"inputReversed"];
            [currentFilters addObject:filter];

        }
    }
     CAFilter *invertFilter = [CAFilter filterWithType:@"colorMatrix"];
      	[invertFilter setValue:[NSValue valueWithCAColorMatrix:(CAColorMatrix){-1,0,0,0,1,0,-1,0,0,1,0,0,-1,0,1,0,0,0,1,0}] forKey:@"inputColorMatrix"];
      	//invertFilter.isDarkModeFilter = YES;
      	[currentFilters addObject:invertFilter];
    [view.layer setFilters:currentFilters];

}

static void wallpaperChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {


    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(PREFS_CHANGED_NOTIF), NULL, NULL, TRUE);


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eclipse 2"
    message:@"Please respring your device for changes to take effect."
    delegate:nil
    cancelButtonTitle:@"OK"
    otherButtonTitles: nil];
    [alert show];

}



static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

    if (prefs) {
        [prefs release];
        prefs = nil;
    }

    //NSArray *keyList = [(NSArray *)CFPreferencesCopyKeyList((CFStringRef)@"com.gmoran.eclipse", kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];

    //prefs = (NSDictionary *)CFPreferencesCopyMultiple((CFArrayRef)keyList, (CFStringRef)@"com.gmoran.eclipse", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

	// reload prefs
	//[prefs release];


    //Delete old prefs file

    prefs = [[NSDictionary alloc] initWithContentsOfFile:PREFS_FILE_PATH];
    //prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_FILE_PATH];

    /*
    if (prefs == nil) {

        NSLog(@"CREATING PREFERENCE FILE");

        prefs = @{@"enabled": @NO,
                  @"themeNPView": @NO,
                  @"colorDetailText": @YES,
                  @"translucentNavbars": @NO,
                  @"replaceSplashScreens": @NO,
                  @"disableInSB": @NO,
                  @"cellSeparatorsEnabled": @NO,
                  @"tintSMSBubbles": @NO,
                  @"tintMessageBubbles": @NO,
                  @"reverseModeEnabled": @NO,

                  //Selections
                  @"selectedTint": @0,
                  @"selectedTheme": @0,
                  @"selectedNavColor": @0,

                  @"selectedKeyboardColor": @0,
                  @"selectedSplashScreenColor": @0,
                  @"selectedDockColor": @0,
                  @"selectedCCColor": @0,

                  //Colors
                  @"customColorsEnabled": @NO,
                  @"customNavBarHex":@"",
                  @"customThemeHex":@"",
                  @"customTintHex":@"",
                  @"customStatusbarHex":@"",
                  @"customTextHex":@"",


                  @"darkenWallpapers": @NO};

		[prefs writeToFile:PREFS_FILE_PATH atomically:NO];
		prefs = [[NSDictionary alloc] initWithContentsOfFile:PREFS_FILE_PATH];

	}
    */

}


static BOOL isTweakEnabled(void) {
	return (prefs) ? [prefs[@"enabled"] boolValue] : NO;

}

static BOOL shouldColorDetailText(void) {
	return (prefs) ? [prefs[@"colorDetailText"] boolValue] : YES;
}

static BOOL translucentNavbarEnabled(void) {
	return (prefs) ? [prefs[@"translucentNavbars"] boolValue] : YES;
}


static BOOL customColorEnabled(void) {
    return (prefs) ? [prefs[@"customColorsEnabled"] boolValue] : YES;
}


static BOOL cellSeparatorsEnabled(void) {
    return (prefs) ? [prefs[@"cellSeparatorsEnabled"] boolValue] : YES;
}

static BOOL tintSMSBubbles(void) {
    return (prefs) ? [prefs[@"tintSMSBubbles"] boolValue] : YES;
}
static BOOL tintMessageBubbles(void) {
    return (prefs) ? [prefs[@"tintMessageBubbles"] boolValue] : YES;
}
static BOOL reverseModeEnabled(void) {
    return (prefs) ? [prefs[@"reverseModeEnabled"] boolValue] : YES;
}

//Custom Colors
static BOOL customNavColorEnabled(void) {
   // if (IS_BETA_BUILD) {
        return (prefs) ? [prefs[@"customNavColorsEnabled"] boolValue] : YES;
   // }

    //return (prefs) ? [prefs[@"customColorsEnabled"] boolValue] : YES;
}

static BOOL customThemeColorEnabled(void) {
   // if (IS_BETA_BUILD) {
        return (prefs) ? [prefs[@"customThemeColorsEnabled"] boolValue] : YES;
   // }

    //return (prefs) ? [prefs[@"customColorsEnabled"] boolValue] : YES;
}

static BOOL customTintColorEnabled(void) {

   // if (IS_BETA_BUILD) {
        return (prefs) ? [prefs[@"customTintColorsEnabled"] boolValue] : YES;
    //}
    //return (prefs) ? [prefs[@"customColorsEnabled"] boolValue] : YES;
}

static BOOL customStatusbarColorEnabled(void) {
    //if (IS_BETA_BUILD) {
        return (prefs) ? [prefs[@"customStatusbarColorsEnabled"] boolValue] : YES;
    //}

    //return (prefs) ? [prefs[@"customColorsEnabled"] boolValue] : YES;
}

static BOOL customTextColorEnabled(void) {
   // if (IS_BETA_BUILD) {
        return (prefs) ? [prefs[@"customTextColorsEnabled"] boolValue] : YES;
    //}

    //return (prefs) ? [prefs[@"customColorsEnabled"] boolValue] : YES;
}

//Installed Checks

static BOOL isMessageCustomiserInstalled() {
     return [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/CustomMessagesColour.dylib"];

}

//Experimental Features
static BOOL darkenKeyboard(void) {
	return (prefs) ? [prefs[@"darkenKeyboard"] boolValue] : NO;
}


static BOOL isEnabled = isTweakEnabled();



//Useful Macros

#define colorWithHexString(h,a) [UIColor colorWithHexString:h alpha:a]
#define darkerColorForColor(c) [UIColor darkerColorForColor:c]


//Selections

static int selectedTheme(void) {
    int selectedTheme = [[prefs objectForKey:@"selectedTheme"] intValue];
    return selectedTheme;
}

static int selectedNavColor(void) {
    int selectedTheme = [[prefs objectForKey:@"selectedNavColor"] intValue];
    return selectedTheme;
}

static int selectedKeyboardColor(void) {
    int selectedTheme = [[prefs objectForKey:@"selectedKeyboardColor"] intValue];
    return selectedTheme;
}

//HEX Colors

/*
 @"customColorEnabled": @NO,
 @"customNavBarHex":@"",
 @"customThemeHex":@"",
 @"customTintHex":@"",
 @"customStatusbarHex":@"",
*/

static UIColor* hexNavColor(void) {

    NSDictionary* prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_FILE_PATH];
    NSString* hex = [prefs objectForKey:@"customNavBarHex"];

    if (![hex isEqualToString:@""]) {
        return colorWithHexString(hex,1);
    }
    return nil;


    //UIColor *color = colorFromDefaultsWithKey(@"com.gmoran.eclipse", @"customNavBarHex", @"#0A0A0A");
    //return color;
}

static UIColor* hexThemeColor(void) {

    NSString* hex = [prefs objectForKey:@"customThemeHex"];

    if (![hex isEqualToString:@""]) {
        return colorWithHexString(hex,1);
    }
    return nil;


    //UIColor *color = colorFromDefaultsWithKey(@"com.gmoran.eclipse", @"customThemeHex", @"#1E1E1E");
    //return color;
}

static UIColor* hexTintColor(void) {

    NSString* hex = [prefs objectForKey:@"customTintHex"];
    hex = [hex stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (![hex isEqualToString:@""]) {
        return colorWithHexString(hex,1);
    }
    return nil;


    //UIColor *color = colorFromDefaultsWithKey(@"com.gmoran.eclipse", @"customTintHex", @"#00A3EB");
    //return color;
}

static UIColor* hexStatusbarColor(void) {

    NSString* hex = [prefs objectForKey:@"customStatusbarHex"];
    hex = [hex stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (![hex isEqualToString:@""]) {
        return colorWithHexString(hex,1);
    }
    return nil;


    //UIColor *color = colorFromDefaultsWithKey(@"com.gmoran.eclipse", @"customStatusbarHex", @"#E6E6E6");
    //return color;
}

static UIColor* hexTextColor(void) {

    NSString* hex = [prefs objectForKey:@"customTextHex"];

    if (![hex isEqualToString:@""]) {
        return colorWithHexString(hex,1);
    }
    return nil;


    //UIColor *color = colorFromDefaultsWithKey(@"com.gmoran.eclipse", @"customTextHex", @"#E6E6E6");
    //return color;
}

/* -------------------------- */


static UIColor* textColor(void) {
    if (customTextColorEnabled()) {
        if (hexTextColor()) {
            return hexTextColor();
        }
    }

    return [UIColor colorWithRed:230.0/255.0f green:230.0/255.0f blue:230.0/255.0f alpha:1.0f];
}


static UIColor* selectedTableColor(void) {
    int number = [[prefs objectForKey:@"selectedTheme"] intValue];

    if (customThemeColorEnabled()) {
        if (hexThemeColor()) {
            return hexThemeColor();
        }
    }

    if (number == -1) {
        return MIDNIGHT_TABLE_COLOR;
    }

    else if (number == 0) {
        return NIGHT_TABLE_COLOR;
    }
    else if (number == 1) {
        return GRAPHITE_TABLE_COLOR;
    }
    else if (number == 2) {
        return SILVER_TABLE_COLOR;
    }
    else if (number == 3) {
        return CRIMSON_TABLE_COLOR;
    }
    else if (number == 4) {
        return ROSE_PINK_TABLE_COLOR;
    }
    else if (number == 5) {
        return GRAPE_TABLE_COLOR;
    }
    else if (number == 6) {
        return WINE_TABLE_COLOR;
    }
    else if (number == 7) {
        return VIOLET_TABLE_COLOR;
    }
    else if (number == 8) {
        return SKY_TABLE_COLOR;
    }
    else if (number == 9) {
        return LAPIS_TABLE_COLOR;
    }
    else if (number == 10) {
        return NAVY_TABLE_COLOR;
    }
    else if (number == 11) {
        return DUSK_TABLE_COLOR;
    }
    else if (number == 12) {
        return JUNGLE_TABLE_COLOR;
    }
    else if (number == 13) {
        return BAMBOO_TABLE_COLOR;
    }
    else if (number == 14) {
        return SAFFRON_TABLE_COLOR;
    }
    else if (number == 15) {
        return CITRUS_TABLE_COLOR;
    }
    else if (number == 16) {
        return AMBER_TABLE_COLOR;
    }

    else {
        return NIGHT_TABLE_COLOR;
    }

}

static UIColor* selectedViewColor(void) {
    int number = [[prefs objectForKey:@"selectedTheme"] intValue];

    if (customThemeColorEnabled()) {
        if (hexThemeColor()) {
            return darkerColorForColor(hexThemeColor());
        }
    }

    if (number == -1) {
        return MIDNIGHT_VIEW_COLOR;
    }
    else if (number == 0) {
        return NIGHT_VIEW_COLOR;
    }
    else if (number == 1) {
        return GRAPHITE_VIEW_COLOR;
    }
    else if (number == 2) {
        return SILVER_VIEW_COLOR;
    }
    else if (number == 3) {
        return CRIMSON_VIEW_COLOR;
    }
    else if (number == 4) {
        return ROSE_PINK_VIEW_COLOR;
    }
    else if (number == 5) {
        return GRAPE_VIEW_COLOR;
    }
    else if (number == 6) {
        return WINE_VIEW_COLOR;
    }
    else if (number == 7) {
        return VIOLET_VIEW_COLOR;
    }
    else if (number == 8) {
        return SKY_VIEW_COLOR;
    }
    else if (number == 9) {
        return LAPIS_VIEW_COLOR;
    }
    else if (number == 10) {
        return NAVY_VIEW_COLOR;
    }
    else if (number == 11) {
        return DUSK_VIEW_COLOR;
    }
    else if (number == 12) {
        return JUNGLE_VIEW_COLOR;
    }
    else if (number == 13) {
        return BAMBOO_VIEW_COLOR;
    }
    else if (number == 14) {
        return SAFFRON_VIEW_COLOR;
    }
    else if (number == 15) {
        return CITRUS_VIEW_COLOR;
    }
    else if (number == 16) {
        return AMBER_VIEW_COLOR;
    }


    else {
        return NIGHT_VIEW_COLOR;
    }

}

static UIColor* selectedBarColor(void) {
    int number = [[prefs objectForKey:@"selectedNavColor"] intValue];

    if (customNavColorEnabled()) {
        if (hexNavColor()) {
            return hexNavColor();
        }
    }

    if (number == -1) {
        return MIDNIGHT_BAR_COLOR;
    }
    else if (number == 0) {
        return NIGHT_BAR_COLOR;
    }
    else if (number == 1) {
        return GRAPHITE_BAR_COLOR;
    }
    else if (number == 2) {
        return SILVER_BAR_COLOR;
    }
    else if (number == 3) {
        return CRIMSON_BAR_COLOR;
    }
    else if (number == 4) {
        return ROSE_PINK_BAR_COLOR;
    }
    else if (number == 5) {
        return GRAPE_BAR_COLOR;
    }
    else if (number == 6) {
        return WINE_BAR_COLOR;
    }
    else if (number == 7) {
        return VIOLET_BAR_COLOR;
    }
    else if (number == 8) {
        return SKY_BAR_COLOR;
    }
    else if (number == 9) {
        return LAPIS_BAR_COLOR;
    }
    else if (number == 10) {
        return NAVY_BAR_COLOR;
    }
    else if (number == 11) {
        return DUSK_BAR_COLOR;
    }
    else if (number == 12) {
        return JUNGLE_BAR_COLOR;
    }
    else if (number == 13) {
        return BAMBOO_BAR_COLOR;
    }
    else if (number == 14) {
        return SAFFRON_BAR_COLOR;
    }
    else if (number == 15) {
        return CITRUS_BAR_COLOR;
    }
    else if (number == 16) {
        return AMBER_BAR_COLOR;
    }


    else {
        return NIGHT_BAR_COLOR;
    }

}

static UIColor* theTableColor(void) {
    if (reverseModeEnabled()) {
        return selectedViewColor();
    }
    else {
        return selectedTableColor();
    }
}

static UIColor* theViewColor(void) {
    if (reverseModeEnabled()) {
        return selectedTableColor();
    }
    else {
        return selectedViewColor();
    }
}

#define TABLE_COLOR theTableColor() //Used for TableView

#define NAV_COLOR selectedBarColor() //Used for NavBars, Toolbars, TabBars

#define VIEW_COLOR theViewColor() //Used for TableCells, UIViews

//Advanced Settings

static UIColor* keyboardColor(void) {
    int number = selectedKeyboardColor();

    /*
    if (customColorEnabled()) {
        if (hexNavColor()) {
            return hexNavColor();
        }
    }
     */

    if (number == -2) {
        return VIEW_COLOR;
    }

    else if (number == -1) {
        return MIDNIGHT_TABLE_COLOR;
    }

    else if (number == 0) {
        return NIGHT_TABLE_COLOR;
    }
    else if (number == 1) {
        return GRAPHITE_TABLE_COLOR;
    }
    else if (number == 2) {
        return SILVER_TABLE_COLOR;
    }
    else if (number == 3) {
        return CRIMSON_TABLE_COLOR;
    }
    else if (number == 4) {
        return ROSE_PINK_TABLE_COLOR;
    }
    else if (number == 5) {
        return GRAPE_TABLE_COLOR;
    }
    else if (number == 6) {
        return WINE_TABLE_COLOR;
    }
    else if (number == 7) {
        return VIOLET_TABLE_COLOR;
    }
    else if (number == 8) {
        return SKY_TABLE_COLOR;
    }
    else if (number == 9) {
        return LAPIS_TABLE_COLOR;
    }
    else if (number == 10) {
        return NAVY_TABLE_COLOR;
    }
    else if (number == 11) {
        return DUSK_TABLE_COLOR;
    }
    else if (number == 12) {
        return JUNGLE_TABLE_COLOR;
    }
    else if (number == 13) {
        return BAMBOO_TABLE_COLOR;
    }
    else if (number == 14) {
        return SAFFRON_TABLE_COLOR;
    }
    else if (number == 15) {
        return CITRUS_TABLE_COLOR;
    }
    else if (number == 16) {
        return AMBER_TABLE_COLOR;
    }

    else {
        return TABLE_COLOR;
    }
}







//Other Colors

//#define ALT_TEXT_COLOR [UIColor colorWithRed:180.0/255.0f green:180.0/255.0f blue:180.0/255.0f alpha:1.0f] //Replaces text colors

#define TEXT_COLOR textColor()

static UIColor* selectedStatusbarTintColor(void) {
    int number = [[prefs objectForKey:@"statusbarTint"] intValue];

    if (customStatusbarColorEnabled()) {
        if (hexStatusbarColor()) {
            return hexStatusbarColor();
        }
    }

    if (number == 0) {
        //return textColor(); //White
        return WHITE_COLOR;
    }
    else if (number == 1) {
        return BABY_BLUE_COLOR;
    }
    else if (number == 2) {
        return DARK_ORANGE_COLOR;
    }
    else if (number == 3) {
        return PINK_COLOR;
    }
    else if (number == 4) {
        return GREEN_COLOR;
    }
    else if (number == 5) {
        return PURPLE_COLOR;
    }
    else if (number == 6) {
        return RED_COLOR;
    }
    else if (number == 7) {
        return YELLOW_COLOR;
    }

    else {
        //return textColor(); //White
        return WHITE_COLOR;
    }

}


static UIColor* selectedTintColor(void) {

    int number = [[prefs objectForKey:@"selectedTint"] intValue];

    if (customTintColorEnabled()) {
        if (hexTintColor()) {
            return hexTintColor();
        }
    }

    if (number == 0) {
        return BABY_BLUE_COLOR;
    }
    if (number == 1) {
        return WHITE_COLOR;
    }
    if (number == 2) {
        return DARK_ORANGE_COLOR;
    }
    if (number == 3) {
        return PINK_COLOR;
    }
    if (number == 4) {
        return GREEN_COLOR;
    }
    if (number == 5) {
        return PURPLE_COLOR;
    }
    if (number == 6) {
        return RED_COLOR;
    }
    if (number == 7) {
        return YELLOW_COLOR;
    }
    if (number == 8) {


        NSArray* availableColors = @[BABY_BLUE_COLOR, PINK_COLOR, DARK_ORANGE_COLOR, GREEN_COLOR, PURPLE_COLOR, RED_COLOR, YELLOW_COLOR];

        UIColor* rand = availableColors.count == 0 ? nil : availableColors[arc4random_uniform(availableColors.count)];

        return rand;

        /*
         CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
         CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
         CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
         UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];

         return color;
         */
    }
    else {
        return BABY_BLUE_COLOR;
    }


}

static UIColor* tableSeparatorColor(void) {
    if (cellSeparatorsEnabled()) {
        return [selectedTintColor() colorWithAlphaComponent:0.3];
    }
    else {
        return TABLE_COLOR;
    }
}

#define TABLE_SEPARATOR_COLOR tableSeparatorColor()

static void setTintColors() {

    [[UINavigationBar appearance] setTintColor:selectedTintColor()];
    [[UISlider appearance] setMinimumTrackTintColor:selectedTintColor()];
    [[UIToolbar appearance] setTintColor:selectedTintColor()];
    [[UITabBar appearance] setTintColor:selectedTintColor()];

    [[UITextView appearance] setTintColor:selectedTintColor()];
    [[UITextField appearance] setTintColor:selectedTintColor()];

    [[UITableView appearance] setTintColor:selectedTintColor()];
    /*
    //Experimental

    [[UIApplication sharedApplication] keyWindow].tintColor = selectedTintColor();

    //[[UIView appearance] setTintColor:selectedTintColor()]; //Buggy?
    [[UITableView appearance] setTintColor:selectedTintColor()];
    [[UITableViewCell appearance] setTintColor:selectedTintColor()];
    [[UIButton appearance] setTintColor:selectedTintColor()];
     */

    //[[UIButton appearance] setTintColor:selectedTintColor()];

}

static BOOL isLightColor(UIColor* color) {


    //BOOL is = NO;

    CGFloat white = 0;
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getWhite:&white alpha:&alpha];
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    //return ((white >= 0.5) && (red >= 0.5) && (green >= 0.5)  && (blue >= 0.5) && (alpha >= 0.4) && (![color isEqual:selectedTintColor()]));

    if ((red <= 0.5) || (green <= 0.5) || (blue <= 0.5)) {
        return NO;
    }
    else if (white >= 0.5 && alpha > 0.7) {
        return YES;
    }
    else {
        return NO;
    }


}

static BOOL isTextDarkColor(UIColor* color) {

    /*
    CGFloat white = 0;
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    [color getWhite:&white alpha:nil];
    [color getRed:&red green:&green blue:&blue alpha:nil];

   return ((white <= 0.5) && (red <= 0.5) && (green <= 0.5)  && (blue <= 0.5) && (![color isEqual:selectedTintColor()]));
     */

    if ([UIColor color:color isEqualToColor:[UIColor blackColor] withTolerance:0.7] && (![color isEqual:selectedTintColor()])) {
        return YES;
    }
    else {
        return NO;
    }

}

//Uniformity Support


static void darkenUIElements() {


    setTintColors();

    //[[UINavigationBar appearance] setBarTintColor:NAV_COLOR];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];

    //[[UISearchBar appearance] setBarTintColor:NAV_COLOR]; //Crashes Dropbox

    //[[UISearchBar appearance] setBarStyle:UIBarStyleBlack];

    [[UIToolbar appearance] setBarTintColor:NAV_COLOR];
    //[[UIToolbar appearance] setBarStyle:UIBarStyleBlack];

    [[UITabBar appearance] setBarTintColor:NAV_COLOR];
    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];

    [[UISwitch appearance] setTintColor:[selectedTintColor() colorWithAlphaComponent:0.6]];
    [[UISwitch appearance] setOnTintColor:[selectedTintColor() colorWithAlphaComponent:0.3]];
    //[[UISwitch appearance] setThumbTintColor:TEXT_COLOR];


}





/*
  .d8b.  db      d88888b d8888b. d888888b .d8888.
 d8' `8b 88      88'     88  `8D `~~88~~' 88'  YP
 88ooo88 88      88ooooo 88oobY'    88    `8bo.
 88~~~88 88      88~~~~~ 88`8b      88      `Y8b.
 88   88 88booo. 88.     88 `88.    88    db   8D
 YP   YP Y88888P Y88888P 88   YD    YP    `8888Y'
*/



%hook _UITextFieldRoundedRectBackgroundViewNeue

-(id)fillColor {
    if (isEnabled) {
        return [UIColor clearColor];
    }
    return %orig;
}

-(id)initWithFrame:(CGRect)arg1 {
    id ok = %orig;
    if (isEnabled) {
        [self setFillColor:[UIColor clearColor]];
    }
    return ok;
}
%end

%hook _UIBackdropViewSettings

-(id)colorTint {
    UIColor* color = %orig;

    id _backdrop = MSHookIvar<id>(self, "_backdrop");

    //if ([[_backdrop superview] isKindOfClass:[UIActionSheet class]] && [self style] != 2060) {


    /* ==== INFORMATION ====

     _UIBackdropViewSettingsAdaptiveLight = 2060 || iOS 7 Control Center

     _UIBackdropViewSettingsUltraLight = 2010 || App Store, iTunes, Action Sheets, and Share Sheets

     _UIBackdropViewSettingsLight = 0, 1000, 1003, 2020, 10090, 10100 || Dock, Spotlight, Folders

     */



    if (isEnabled && [self class] == %c(_UIBackdropViewSettingsUltraLight)) {

        color = [NAV_COLOR colorWithAlphaComponent:0.9];
        [_backdrop setAlpha:0.9];
    }



    if (isEnabled && darkenKeyboard() && [_backdrop isKindOfClass:objc_getClass("UIKBBackdropView")]) {
        color = [keyboardColor() colorWithAlphaComponent:0.9];
        [_backdrop setAlpha:0.9];
    }


    return color;
}

%end

%group EclipseAlerts

//Action Sheets
@interface _UIActivityGroupActivityCellTitleLabel : UILabel
@end

%hook _UIActivityGroupActivityCellTitleLabel

-(void)layoutSubviews {
    %orig;

    if(isEnabled) {
        self.textColor = selectedTintColor();
    }
}

%end

@interface UIActionSheetiOSDismissActionView : UIView
@end

%hook UIActionSheetiOSDismissActionView
-(void)layoutSubviews {
    %orig;

    if(isEnabled) {

        UIButton *button = MSHookIvar<UIButton *>(self, "_dismissButton");
        button.tintColor = selectedTintColor();
    }
}
%end

@interface _UIInterfaceActionGroupHeaderScrollView  : UIView
@end

%hook _UIInterfaceActionGroupHeaderScrollView
-(void)layoutSubviews {
    %orig;

    if(isEnabled){
        UIView *contentView = MSHookIvar<UIView *>(self, "_contentView");

        for (UILabel *subview in contentView.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                subview.textColor = selectedTintColor();
            }
        }
    }
}
%end

/*
@interface _UIInterfaceActionCustomViewRepresentationView  : UIView
@end

%hook _UIInterfaceActionCustomViewRepresentationView

-(void)layoutSubviews {
    %orig;
    if(isEnabled){
        UIView *actionView = MSHookIvar<UIView *>(self, "_actionContentView");
        UILabel *label = MSHookIvar<UILabel *>(actionView, "_label");
        label.tintColor = selectedTintColor();
    }
}

-(void)setHighlighted:(BOOL)arg1{
    %orig;
    if(isEnabled){

        UIView *actionView = MSHookIvar<UIView *>(self, "_actionContentView");
        UILabel *label = MSHookIvar<UILabel *>(actionView, "_label");
        label.tintColor = selectedTintColor();
    }
}

%end
*/


//Alerts

%hook _UIAlertControllerView

- (id)initWithFrame:(CGRect)arg1
 {
    id kek = %orig;
    if (isEnabled) {

        for (UIView* view in [self subviews]) {
            view.tag = VIEW_EXCLUDE_TAG;
        }

        UILabel* _titleLabel = MSHookIvar<id>(self, "_titleLabel");
        [_titleLabel setTextColor:selectedTintColor()];

        UILabel* _detailMessageLabel = MSHookIvar<id>(self, "_detailMessageLabel");
        [_detailMessageLabel setTextColor:TEXT_COLOR];

        UILabel* _messageLabel = MSHookIvar<id>(self, "_messageLabel");
        [_messageLabel setTextColor:TEXT_COLOR];

    }
     return kek;
}

%end

%hook ServiceTouchIDAlertHeaderView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {

        for (UILabel* label in [self subviews]) {
            if ([label respondsToSelector:@selector(setTextColor:)]) {
                [label setTextColor:TEXT_COLOR];
            }
        }

        [self setBackgroundColor:NAV_COLOR];
    }
}

%end

%hook _UIAlertControllerShadowedScrollView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:NAV_COLOR];
    }
}

%end

%hook _UIAlertControllerCollectionViewCell

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:NAV_COLOR];
    }
}

%end

%hook _UIAlertControllerBlendingSeparatorView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:selectedTintColor()];
    }
}

%end

%hook _UIAlertControllerActionView

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:NAV_COLOR];

        UILabel* _label = MSHookIvar<id>(self, "_label");
        [_label setTextColor:selectedTintColor()];
    }
}


%end

%end //End Eclipse Alerts

/*
 d8b   db  .d8b.  db    db      d888888b d888888b d88888b .88b  d88. .d8888.
 888o  88 d8' `8b 88    88        `88'   `~~88~~' 88'     88'YbdP`88 88'  YP
 88V8o 88 88ooo88 Y8    8P         88       88    88ooooo 88  88  88 `8bo.
 88 V8o88 88~~~88 `8b  d8'         88       88    88~~~~~ 88  88  88   `Y8b.
 88  V888 88   88  `8bd8'         .88.      88    88.     88  88  88 db   8D
 VP   V8P YP   YP    YP         Y888888P    YP    Y88888P YP  YP  YP `8888Y'
*/


%hook UINavigationBar

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        shouldOverrideStatusBarStyle = YES;


        @try {
            [self setBarTintColor:NAV_COLOR];
            [self setBarStyle:UIBarStyleBlack];

        }
        @catch (NSException * e) {
            //Nah
        }
        @finally {
            //NSLog(@"Eclipse 3: An error occured while attempting to color the Nav Bar. This application may not support this feature.");
        }


    }
}

-(void)drawRect:(CGRect)arg1 {
    %orig;
    if (isEnabled) {


        shouldOverrideStatusBarStyle = YES;

        @try {
            [self setBarTintColor:NAV_COLOR];
            [self setBarStyle:UIBarStyleBlack];

        }
        @catch (NSException * e) {
            //Nah
        }
        @finally {
            //NSLog(@"Eclipse 3: An error occured while attempting to color the Nav Bar. This application may not support this feature.");
        }
    }
}

-(void)setBounds:(CGRect)arg1 {
    %orig;
    if (isEnabled) {
        shouldOverrideStatusBarStyle = YES;

        @try {
            [self setBarTintColor:NAV_COLOR];
            [self setBarStyle:UIBarStyleBlack];

        }
        @catch (NSException * e) {
            //Nah
        }
        @finally {
            //NSLog(@"Eclipse 3: An error occured while attempting to color the Nav Bar. This application may not support this feature.");
        }
    }
}

-(void)setBarTintColor:(UIColor*)color {
    if (isEnabled) {
        color = NAV_COLOR;
        if (translucentNavbarEnabled()) {
            [self setAlpha:0.9];
        }
    }
    %orig(color);
}

%end

//Tab Bar Stuff

%hook UITabBar

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        self.backgroundColor = NAV_COLOR; //Fuck you, Whatsapp.

    }
}

-(void)setBarTintColor:(id)arg1 {
    if (isEnabled) {
        self.backgroundColor = NAV_COLOR;
        %orig(NAV_COLOR);
        return;
    }
    %orig;
}

%end

%hook SKUITabBarBackgroundView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UIView* eclipseBarView = [[UIView alloc] initWithFrame:[self frame]];
        [eclipseBarView setBackgroundColor:NAV_COLOR];
        [self addSubview:eclipseBarView];
        [eclipseBarView release];

    }
}


%end


%hook UIToolbar


-(void)setBarStyle:(int)arg1 {
    if (isEnabled && !(IsiPad)) {
        [self setBarTintColor:NAV_COLOR];
        return;
    }
    %orig;
}


-(void)setBarTintColor:(id)arg1 {
    if (isEnabled && !(IsiPad)) {
        %orig(NAV_COLOR);
        return;
    }
    %orig;
}

/*
-(void)setTranslucent:(BOOL)arg1 {
    if (isEnabled && !(IsiPad)) {
        %orig(NO);
        return;
    }
    return %orig;
}
-(BOOL)isTranslucent {
    if (isEnabled && !(IsiPad)) {
        return NO;
    }
    return %orig;
}
 */

%end




/*
 db    db d888888b  .o88b.  .d88b.  db       .d88b.  d8888b.
 88    88   `88'   d8P  Y8 .8P  Y8. 88      .8P  Y8. 88  `8D
 88    88    88    8P      88    88 88      88    88 88oobY'
 88    88    88    8b      88    88 88      88    88 88`8b
 88b  d88   .88.   Y8b  d8 `8b  d8' 88booo. `8b  d8' 88 `88.
 ~Y8888P' Y888888P  `Y88P'  `Y88P'  Y88888P  `Y88P'  88   YD
*/


%hook UIColor

+(UIColor*)systemGreenColor {
    if (isEnabled && (selectedTintColor() != WHITE_COLOR)) {
        return selectedTintColor();
    }
    return %orig;
}

+(UIColor*)systemBlueColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}

%end

/*
  .o88b.  .d88b.  db      db           db    db d888888b d88888b db   d8b   db
 d8P  Y8 .8P  Y8. 88      88           88    88   `88'   88'     88   I8I   88
 8P      88    88 88      88           Y8    8P    88    88ooooo 88   I8I   88
 8b      88    88 88      88           `8b  d8'    88    88~~~~~ Y8   I8I   88
 Y8b  d8 `8b  d8' 88booo. 88booo.       `8bd8'    .88.   88.     `8b d8'8b d8'
  `Y88P'  `Y88P'  Y88888P Y88888P         YP    Y888888P Y88888P  `8b8' `8d8'
 */

/*

 Collection View in Videos is 0 alpha BGColor. Figure it out, asshole.

%hook UICollectionView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {

        if (isLightColor(self.backgroundColor) && ![self.backgroundColor isEqual:[UIColor clearColor]] && ![self isKindOfClass:%c(HBFPBackgroundView)]) {

            [self setBackgroundColor:VIEW_COLOR];
        }
    }
}

%end
 */

/*

 UIImageView

*/

%group AutoReplaceColor

%hook UIColor
//such hacky

+(id)blackColor {
    if (isEnabled) {
        return TEXT_COLOR;
    }
    return %orig;
}

+(id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {

    if (isEnabled) {
        if ((red == 0.0) && (green == 0.0) && (blue == 0.0) && (alpha < 0.7)) {
            return TEXT_COLOR;
        }
    }
    return %orig;
}

+(id)colorWithWhite:(float)arg1 alpha:(float)arg2 {

    id color = %orig;

    if (isEnabled) {
        if ((arg1 < .5)) {
            return [TEXT_COLOR colorWithAlphaComponent:0.4];
        }
    }
    return %orig;
}
%end

%hook UIImageView

-(void)layoutSubviews {
    %orig;

    if (isEnabled) {
        if ([UIColor color:[UIColor getDominantColor:self.image] isEqualToColor:[UIColor whiteColor] withTolerance:0.5]) {
            //if ([UIColor color:[self.image averageColor] isEqualToColor:[UIColor whiteColor] withTolerance:0.9]) {

            //self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            //[self setTintColor:VIEW_COLOR];

            [self setAlpha:0.3];
        }

    }

}
%end
%end

//caret

%hook UITextSelectionView

-(id)caretViewColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}

%end

/*
 db    db d888888b db    db d888888b d88888b db   d8b   db
 88    88   `88'   88    88   `88'   88'     88   I8I   88
 88    88    88    Y8    8P    88    88ooooo 88   I8I   88
 88    88    88    `8b  d8'    88    88~~~~~ Y8   I8I   88
 88b  d88   .88.    `8bd8'    .88.   88.     `8b d8'8b d8'
 ~Y8888P' Y888888P    YP    Y888888P Y88888P  `8b8' `8d8'
*/

%hook _UITableViewCellSeparatorView

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setTag:VIEW_EXCLUDE_TAG];
        [self setBackgroundColor:TABLE_SEPARATOR_COLOR];
    }
}

-(void)setBackgroundColor:(UIColor*)color {
    if (isEnabled) {
        %orig(TABLE_SEPARATOR_COLOR);
        return;
    }
    %orig;
}

%end


%hook UIKBBackdropView

-(id)initWithFrame:(CGRect)arg1 style:(long long)arg2 primaryBackdrop:(BOOL)arg3 {
    id kek = %orig;

    if (isEnabled) {
        [self setTag:VIEW_EXCLUDE_TAG];

        for (UIView* view in [self subviews]) {
            [view setTag:VIEW_EXCLUDE_TAG];
        }
    }

    return kek;
}

%end

@interface UIView(Eclipse)
-(void)override;
@end


%hook UIView

//HBFPBackgroundView == FlagPaint

#define FLAGPAINT objc_getClass("HBFPBackgroundView")
#define SC_HEADER objc_getClass("SCBottomBorderedView") //snapchat fix (prevent bans)
#define SC_GRADIENT objc_getClass("SCGradientView")

%new
-(void)override {

    if (isEnabled) {

        if (isLightColor(self.backgroundColor) && ![self.backgroundColor isEqual:[UIColor clearColor]] && ([self class] != FLAGPAINT) && (self.tag != VIEW_EXCLUDE_TAG)) {

            [self setBackgroundColor:VIEW_COLOR];
        }

        //Snapchat fix (prevent ban/connection error)
        if ([self class] == SC_HEADER) {
            [self setBackgroundColor:NAV_COLOR];
        }
        if ([self class] == SC_GRADIENT) {
            [self setAlpha:0.0];
        }

    }


}

-(id)backgroundColor {
    id color = %orig;

    if (isEnabled) {

        if (isLightColor(color) && ![color isEqual:[UIColor clearColor]] && ([self class] != FLAGPAINT) && (self.tag != VIEW_EXCLUDE_TAG)) {

            return VIEW_COLOR;
        }
    }

    return %orig;

}

-(id)initWithCoder:(CGRect)arg1 {
    id ok = %orig;
    [self override];
    return ok;
}

-(id)init {
    id ok = %orig;
    [self override];
    return ok;
}

-(id)initWithFrame:(CGRect)arg1 {
    id ok = %orig;
    [self override];
    return ok;
}

-(id)initWithSize:(CGSize)arg1 {
    id ok = %orig;
    [self override];
    return ok;
}

//#define KB_BG_COLOR [UIColor colorWithRed:1.0f green:0.87f blue:0.87f alpha:0.87] //Fuck You Apple. (Some apps don't use whiteColor)



//if (origColorSpace == tableBGColorSpace || origColorSpace == whiteColorSpace || origColorSpace == cellWhiteColorSpace) {

-(void)setBackgroundColor:(UIColor*)color {

    if (isEnabled) {
        if (isLightColor(color) && ([self class] != FLAGPAINT) && (self.tag != VIEW_EXCLUDE_TAG)) {

            color = VIEW_COLOR;

        }
    }

    %orig(color);
}



-(void)layoutSubviews {

    %orig;

    if (isEnabled && !isClockApp) {


        if (!isLightColor(self.backgroundColor) && ![self.backgroundColor isEqual:[UIColor clearColor]] && (self.tag != VIEW_EXCLUDE_TAG)) {

            for (UILabel* v in [self subviews]){

                if ([(UILabel*)v respondsToSelector:@selector(setTextColor:)] && [(UILabel*)v respondsToSelector:@selector(textColor)]) {

                    if (isTextDarkColor([(UILabel*)v textColor])) {
                        [(UILabel*)v setTag:52961101];
                        [(UILabel*)v setBackgroundColor:[UIColor clearColor]];
                        [(UILabel*)v setTextColor: TEXT_COLOR];
                    }
                }
            }
        }
    }
}

/*

 //Comment to fix crashing on Viber, possibly others.

-(void)didAddSubview:(id)v {
    %orig;

    if (isEnabled) {

        if (!isLightColor(self.backgroundColor) && ![self.backgroundColor isEqual:[UIColor clearColor]] && (self.tag != VIEW_EXCLUDE_TAG)) {

            if ([v respondsToSelector:@selector(setTextColor:)] && [v respondsToSelector:@selector(textColor)]) {

                if (isTextDarkColor([v textColor])) {
                    [v setTag:52961101];
                    [v setBackgroundColor:[UIColor clearColor]];
                    [v setTextColor: TEXT_COLOR];
                }
            }
        }
    }
}

-(void)addSubview:(id)v {
    %orig;

    if (isEnabled) {

        if (!isLightColor(self.backgroundColor) && ![self.backgroundColor isEqual:[UIColor clearColor]] && (self.tag != VIEW_EXCLUDE_TAG)) {

            if ([v respondsToSelector:@selector(setTextColor:)] && [v respondsToSelector:@selector(textColor)]) {

                if (isTextDarkColor([v textColor])) {
                    [v setTag:52961101];
                    [v setBackgroundColor:[UIColor clearColor]];
                    [v setTextColor: TEXT_COLOR];
                }
            }
        }
    }

}

 */

%end


/*
 d888888b db    db d888888b db    db d888888b d88888b db   d8b   db
 `~~88~~' `8b  d8' `~~88~~' 88    88   `88'   88'     88   I8I   88
    88     `8bd8'     88    Y8    8P    88    88ooooo 88   I8I   88
    88     .dPYb.     88    `8b  d8'    88    88~~~~~ Y8   I8I   88
    88    .8P  Y8.    88     `8bd8'    .88.   88.     `8b d8'8b d8'
    YP    YP    YP    YP       YP    Y888888P Y88888P  `8b8' `8d8'
*/

%hook UITextView

-(id)init {
    id  wow = %orig;

    if (isEnabled) {
        if (!isLightColor(self.backgroundColor)) {

            if (![self.superview isKindOfClass:[UIImageView class]]) {

                id balloon = objc_getClass("CKBalloonTextView");

                if ([self class] == balloon) {
                    return wow;
                }
                else {
                    [self setBackgroundColor:[UIColor clearColor]];
                    [self setTextColor:TEXT_COLOR];
                }
            }
        }
    }
    return wow;
}

-(id)initWithFrame:(CGRect)arg1 {
    id  wow = %orig;

    if (isEnabled) {
        if (!isLightColor(self.backgroundColor)) {

            if (![self.superview isKindOfClass:[UIImageView class]]) {

                id balloon = objc_getClass("CKBalloonTextView");

                if ([self class] == balloon) {
                    return wow;
                }
                else {
                    [self setBackgroundColor:[UIColor clearColor]];
                    [self setTextColor:TEXT_COLOR];
                }
            }
        }
    }
    return wow;
}

-(id)initWithCoder:(id)arg1 {
    id  wow = %orig;

    if (isEnabled) {
        if (!isLightColor(self.backgroundColor)) {

            if (![self.superview isKindOfClass:[UIImageView class]]) {

                id balloon = objc_getClass("CKBalloonTextView");

                if ([self class] == balloon) {
                    return wow;
                }
                else {
                    [self setBackgroundColor:[UIColor clearColor]];
                    [self setTextColor:TEXT_COLOR];
                }
            }
        }
    }
    return wow;
}

-(id)initWithFrame:(CGRect)arg1 font:(id)arg2 {

    id  wow = %orig;

    if (isEnabled) {
        if (!isLightColor(self.backgroundColor)) {

            if (![self.superview isKindOfClass:[UIImageView class]]) {

                id balloon = objc_getClass("CKBalloonTextView");

                if ([self class] == balloon) {
                    return wow;
                }
                else {
                    [self setBackgroundColor:[UIColor clearColor]];
                    [self setTextColor:TEXT_COLOR];
                }
            }
        }
    }
    return wow;
}

-(id)initWithFrame:(CGRect)arg1 textContainer:(id)arg2 {
    id  wow = %orig;

    if (isEnabled) {
        if (!isLightColor(self.backgroundColor)) {

            if (![self.superview isKindOfClass:[UIImageView class]]) {

                id balloon = objc_getClass("CKBalloonTextView");

                if ([self class] == balloon) {
                    return wow;
                }
                else {
                    [self setBackgroundColor:[UIColor clearColor]];
                    [self setTextColor:TEXT_COLOR];
                }
            }
        }
    }
    return wow;
}





-(id)backgroundColor {
    UIColor* color = %orig;
    if (isEnabled) {
        if (!isLightColor(color)) {

            color = [UIColor clearColor];
        }
    }
    return color;
}

-(id)textColor {
    if (isEnabled) {
        if (!isLightColor(self.backgroundColor)) {

            if (![self.superview isKindOfClass:[UIImageView class]]) {

                return TEXT_COLOR;

            }
        }
    }
    return %orig;
}
-(void)setFrame:(CGRect)arg1 {
    %orig;

    if (isEnabled) {
        if (!isLightColor(self.backgroundColor)) {

            if (![self.superview isKindOfClass:[UIImageView class]]) {

                id balloon = objc_getClass("CKBalloonTextView");

                if ([self class] == balloon) {
                    return;
                }
                else {
                    [self setBackgroundColor:[UIColor clearColor]];
                    [self setTextColor:TEXT_COLOR];
                }
            }
        }
    }
}

//These methods cause hanging

/*
-(void)setFrame:(CGRect)arg1 {
}
 */
/*
-(void)setBounds:(CGRect)arg1 {
}
*/

/*
-(void)layoutSubviews {
}
 */

%end

%hook MFComposeRecipientTextView

- (void)layoutSubviews {
    %orig;

    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }


}
%end

%hook _MFAtomTextView

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
       [self setTextColor:TEXT_COLOR];
    }

}

%end



/*
 d888888b db    db d888888b d88888b d888888b d88888b db      d8888b.
 `~~88~~' `8b  d8' `~~88~~' 88'       `88'   88'     88      88  `8D
    88     `8bd8'     88    88ooo      88    88ooooo 88      88   88
    88     .dPYb.     88    88~~~      88    88~~~~~ 88      88   88
    88    .8P  Y8.    88    88        .88.   88.     88booo. 88  .8D
    YP    YP    YP    YP    YP      Y888888P Y88888P Y88888P Y8888D'
*/

%hook _MFSearchAtomTextView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }
}

%end

%hook UISearchBar

-(void)drawRect:(CGRect)rect {
    %orig;
    if (isEnabled) {
        [self setBarTintColor:NAV_COLOR];
    }
}

%end

%hook UITextField

%new
-(void)override {
    if (isEnabled) {

        //[self setKeyboardAppearance:UIKeyboardAppearanceDark];
        if (!isLightColor(self.backgroundColor)) {

            //[self setBackgroundColor:[VIEW_COLOR colorWithAlphaComponent:0.4]];

        }

        [self setTextColor:TEXT_COLOR];
        //self.textColor = TEXT_COLOR;
    }
}
/*
 - (void)drawPlaceholderInRect:(CGRect)rect {
 [DARKER_ORANGE_COLOR setFill];
 [[self placeholder] drawInRect:rect withFont:[UIFont systemFontOfSize:12]];
 }
 */

//-(void)setKeyboardAppearance:(int)arg1 ;

-(id)initWithFrame:(CGRect)arg1 {
    id christmasPresents = %orig;
    [self override];
    return christmasPresents;
}


 -(id)initWithCoder:(id)arg1 {
     id christmasPresents = %orig;
     [self override];
     return christmasPresents;
 }

-(id)init {
    id christmasPresents = %orig;
    [self override];
    return christmasPresents;
}
/*
 -(void)setKeyboardAppearance:(int)arg1 {
 if (isEnabled) {
 %orig(UIKeyboardAppearanceDark);
 return;
 }
 %orig;
 }
 */

-(void)setTextColor:(id)arg1 {
    if (isEnabled) {
        if (![self isKindOfClass:%c(SBSearchField)]) {

            if (!isLightColor(self.backgroundColor)) {
                //[self setBackgroundColor:[VIEW_COLOR colorWithAlphaComponent:0.4]];
            }

            %orig(TEXT_COLOR);
            return;
        }
    }
    %orig;
}


-(id)textColor {
    UIColor* color = %orig;
    if (isEnabled) {

        if (![self isKindOfClass:%c(SBSearchField)]) {

            if (!isLightColor(self.backgroundColor)) {

                //[self setBackgroundColor:[VIEW_COLOR colorWithAlphaComponent:0.4]];
            }
            color = TEXT_COLOR;

        }
    }
    return color;
}


-(void)drawRect:(CGRect)arg1 {
    %orig;
    if (isEnabled) {
        if (![self isKindOfClass:%c(SBSearchField)]) {

            if (!isLightColor(self.backgroundColor)) {
                [self setBackgroundColor:[VIEW_COLOR colorWithAlphaComponent:0.4]];
            }


            [self setTextColor:TEXT_COLOR];
            //self.textColor = TEXT_COLOR;

        }
    }
}


%end

/*
 db    db d888888b db       .d8b.  d8888b. d88888b db
 88    88   `88'   88      d8' `8b 88  `8D 88'     88
 88    88    88    88      88ooo88 88oooY' 88ooooo 88
 88    88    88    88      88~~~88 88~~~b. 88~~~~~ 88
 88b  d88   .88.   88booo. 88   88 88   8D 88.     88booo.
 ~Y8888P' Y888888P Y88888P YP   YP Y8888P' Y88888P Y88888P
*/



@interface UILabel(Eclipse)
-(void)override;
@end

%hook UILabel

-(void)drawRect:(CGRect)arg1 {
    %orig;

    if (isEnabled) {
        if (!isLightColor(self.superview.backgroundColor)) {

            if (isTextDarkColor(self.textColor)) {
                //self.tag = 52961101;
                [self setBackgroundColor:[UIColor clearColor]];
                [self setTextColor:TEXT_COLOR];
            }
        }
    }

}

-(void)setFrame:(CGRect)arg1 {
    %orig;

    if (isEnabled) {
        if (!isLightColor(self.superview.backgroundColor)) {

            if (isTextDarkColor(self.textColor)) {
                //self.tag = 52961101;
                [self setBackgroundColor:[UIColor clearColor]];
                [self setTextColor:TEXT_COLOR];
            }
        }
    }

}

-(void)didMoveToSuperview {
    %orig;

    if (isEnabled) {
        if (!isLightColor(self.superview.backgroundColor)) {

            if (isTextDarkColor(self.textColor)) {
                //self.tag = 52961101;
                [self setBackgroundColor:[UIColor clearColor]];
                [self setTextColor:TEXT_COLOR];
            }
        }
    }

}



-(void)setTextColor:(id)color {

    if (isEnabled) {
        if (self.tag == 52961101) {
            color = TEXT_COLOR;
            %orig(color);
            return;
        }
        if (!isLightColor(self.superview.backgroundColor)) {

            if (isTextDarkColor(color)) {
                //self.tag = 52961101;
                self.backgroundColor = [UIColor clearColor];
                color = TEXT_COLOR;
            }
        }
    }


    %orig(color);
}

%end



/*
 d888888b  .d8b.  d8888b. db      d88888b
 `~~88~~' d8' `8b 88  `8D 88      88'
    88    88ooo88 88oooY' 88      88ooooo
    88    88~~~88 88~~~b. 88      88~~~~~
    88    88   88 88   8D 88booo. 88.
    YP    YP   YP Y8888P' Y88888P Y88888P
*/

#define TABLE_BG_COLOR [UIColor colorWithRed:0.937255 green:0.937255 blue:0.956863 alpha:1.0f] //Default Table BG Color

static CGColorSpaceRef tableBGColorSpace = CGColorGetColorSpace([TABLE_BG_COLOR CGColor]);

#define CELL_WHITE [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0f] //Fuck You Apple. (Some apps don't use whiteColor)

static CGColorSpaceRef cellWhiteColorSpace = CGColorGetColorSpace([CELL_WHITE CGColor]);

#define IPAD_CELL_WHITE [UIColor colorWithRed:0.145098 green:0.145098 blue:0.145098 alpha:1.0f]

static CGColorSpaceRef iPadCellWhiteColorSpace = CGColorGetColorSpace([IPAD_CELL_WHITE CGColor]);


static CGColorSpaceRef whiteColorSpace = CGColorGetColorSpace([[UIColor whiteColor] CGColor]);



%hook UITableView


%new
-(void)override {

    @try {

        if (isEnabled) {

            CGColorSpaceRef origColorSpace = CGColorGetColorSpace([self.backgroundColor CGColor]);

            //if (origColorSpace == tableBGColorSpace || origColorSpace == whiteColorSpace || origColorSpace == cellWhiteColorSpace) {

            if ([UIColor color:self.backgroundColor isEqualToColor:[UIColor whiteColor] withTolerance:0.5]) {


                self.sectionIndexBackgroundColor = [UIColor clearColor];




                [self setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
                self.sectionIndexTrackingBackgroundColor = [UIColor clearColor];

                [self setSectionIndexColor:selectedTintColor()];
                self.sectionIndexColor = selectedTintColor();


                [self setBackgroundColor: TABLE_COLOR];
                self.backgroundColor = TABLE_COLOR;

            }
        }


    }


    @catch (NSException* e) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Eclipse 4: Error 4 Occurred"
                                                        message:[e localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }


    }


-(id)initWithFrame:(CGRect)arg1 {
    id itsTenPM = %orig;
    [self override];
    return itsTenPM;
}


-(id)initWithCoder:(id)arg1 {
    id itsTenPM = %orig;
    [self override];
    return itsTenPM;
}



-(id)init {
    id itsTenPM = %orig;
    [self override];
    return itsTenPM;
}



-(void)setBackgroundColor:(id)arg1 {

    if (isEnabled) {
        CGColorSpaceRef argColorSpace = CGColorGetColorSpace([arg1 CGColor]);

        //if (argColorSpace == tableBGColorSpace || [arg1 isEqual:[UIColor whiteColor]] ) {

        if ([UIColor color:arg1 isEqualToColor:[UIColor whiteColor] withTolerance:0.5]) {


            [self setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];

            [self setSectionIndexColor:selectedTintColor()];

            self.sectionIndexBackgroundColor = [UIColor clearColor];
            //[self setTableHeaderBackgroundColor:TABLE_COLOR];


            %orig(TABLE_COLOR);
            return;
        }

        %orig;
        return;
    }
    %orig;
}

-(id)backgroundColor {

    id bgc = %orig;

    if (isEnabled) {

        CGColorSpaceRef origColorSpace = CGColorGetColorSpace([bgc CGColor]);

        //if (origColorSpace == tableBGColorSpace || origColorSpace == whiteColorSpace || origColorSpace == cellWhiteColorSpace) {

        if ([UIColor color:bgc isEqualToColor:[UIColor whiteColor] withTolerance:0.5]) {


            self.sectionIndexBackgroundColor = [UIColor clearColor];



            [self setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
            self.sectionIndexTrackingBackgroundColor = [UIColor clearColor];


            [self setSectionIndexColor:selectedTintColor()];
            self.sectionIndexColor = selectedTintColor();


            //[self sectionBorderColor];
            bgc = TABLE_COLOR;
        }
        return bgc;
    }
    return bgc;
}




/*
-(void)layoutSubviews {
    %orig;

    if (isEnabled) {
        self.sectionIndexBackgroundColor = [UIColor clearColor];


        [self setSeparatorColor:TABLE_SEPARATOR_COLOR];
        //self.separatorColor = TABLE_SEPARATOR_COLOR;

        [self setSectionIndexTrackingBackgroundColor:[UIColor clearColor]];
        //self.sectionIndexTrackingBackgroundColor = [UIColor clearColor];

        [self setSectionIndexColor:selectedTintColor()];
        //self.sectionIndexColor = selectedTintColor();

        //This actually came in handy... Wow.
        if ([UIColor color:self.backgroundColor isEqualToColor:[UIColor whiteColor] withTolerance:2] && ![UIColor color:self.backgroundColor isEqualToColor:[UIColor clearColor] withTolerance:0.2]) {
            [self setBackgroundColor:TABLE_COLOR];
        }

    }


}
 */



-(id)sectionBorderColor {
    if (isEnabled) {
        return [UIColor clearColor];
    }
    return %orig;
}



-(id)sectionIndexTrackingBackgroundColor {
    if (isEnabled) {
        return [UIColor clearColor];
    }
    return %orig;
}
-(void)setSectionIndexTrackingBackgroundColor:(id)arg1 {
    if (isEnabled) {
        %orig ([UIColor clearColor]);
        return;
    }
    %orig;
}

-(void)setSectionIndexColor:(id)arg1 {
    if (isEnabled) {
        self.sectionIndexBackgroundColor = [UIColor clearColor];

        arg1 = selectedTintColor();
    }
    %orig(arg1);
}

-(void)setTableHeaderBackgroundColor:(id)arg1 {
    if (isEnabled) {
        self.sectionIndexBackgroundColor = [UIColor clearColor];
        arg1 = TABLE_COLOR;
    }
    %orig(arg1);
}
-(id)tableHeaderBackgroundColor {
    if (isEnabled) {
        return TABLE_COLOR;
    }
    return %orig;
}



%end

//Selected Background



//Table Index

%hook UITableViewIndex

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setIndexTrackingBackgroundColor:[UIColor clearColor]];
        [self setIndexBackgroundColor:[UIColor clearColor]];
        [self setIndexColor:selectedTintColor()];
    }

}

-(id)initWithFrame:(CGRect)arg1 {
    id k = %orig;

    if (isEnabled) {
        [self setIndexTrackingBackgroundColor:[UIColor clearColor]];
        [self setIndexBackgroundColor:[UIColor clearColor]];
        [self setIndexColor:selectedTintColor()];
    }

    return k;
}

-(void)drawRect:(CGRect)arg1 {
    %orig;

    if (isEnabled) {
        [self setIndexTrackingBackgroundColor:[UIColor clearColor]];
        [self setIndexBackgroundColor:[UIColor clearColor]];
        [self setIndexColor:selectedTintColor()];
    }

}

-(UIColor *)indexTrackingBackgroundColor {
    if (isEnabled) {
        return [UIColor clearColor];
    }
    return %orig;
}
-(UIColor *)indexBackgroundColor {
    if (isEnabled) {
        return [UIColor clearColor];
    }
    return %orig;
}

-(UIColor *)indexColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}

%end



/*
 db   db d88888b db    db d8888b.  d888b
 88   88 88'     88    88 88  `8D 88' Y8b
 88ooo88 88ooo   Y8    8P 88oooY' 88
 88~~~88 88~~~   `8b  d8' 88~~~b. 88  ooo
 88   88 88       `8bd8'  88   8D 88. ~8~
 YP   YP YP         YP    Y8888P'  Y888P
*/

%hook _UITableViewHeaderFooterViewBackground

-(id)initWithFrame:(CGRect)arg1 {
    id bgView = %orig;
    if (isEnabled && ([[self backgroundColor] isEqual:[UIColor clearColor]])) {
        [self setBackgroundColor:VIEW_COLOR];
    }

    return bgView;
}

%end



/*
  .o88b. d88888b db      db      .d8888.
 d8P  Y8 88'     88      88      88'  YP
 8P      88ooooo 88      88      `8bo.
 8b      88~~~~~ 88      88        `Y8b.
 Y8b  d8 88.     88booo. 88booo. db   8D
  `Y88P' Y88888P Y88888P Y88888P `8888Y'
*/


%hook UIGroupTableViewCellBackground

- (id)_fillColor {
    if (isEnabled) {
        return VIEW_COLOR;
    }
    return %orig;
}



%end

@interface UITableViewCell(Eclipse)
-(void)override;
-(BOOL)isLightColor:(id)clr;
-(void)setSelectionTintColor:(id)arg1;
@end

%hook UITableViewCell

/* i made a fucking mess because Clock.app crashes on some devices.
 Now i'm trying to catch the fucking exception.
*/



%new
-(void)override {

    if (isEnabled) {
        if (!isLightColor(self.backgroundColor) && ![self.backgroundColor isEqual:[UIColor clearColor]]) {
            [self setBackgroundColor:VIEW_COLOR];

        }
    }

}

-(void)drawRect:(CGRect)arg1 {
    %orig;

    if (isEnabled) {
        if ([self selectionStyle] != UITableViewCellSelectionStyleNone) {
            [self setSelectionTintColor:[UIColor darkerColorForSelectionColor:selectedTintColor()]];
        }
    }


}


-(id)_detailTextLabel {
    UILabel* label = %orig;

    if (isEnabled) {
        if (shouldColorDetailText()) {
            [label setTextColor:selectedTintColor()];
        }
        else {
            [label setTextColor:TEXT_COLOR];
        }
    }


    return label;
}

-(id)init {
    id iRanOutOfNamesForThisID = %orig;
    [self override];
    return iRanOutOfNamesForThisID;
}


-(void)setBackgroundColor:(id)arg1 {

    if (isEnabled) {

        if (!isLightColor(arg1) && ![arg1 isEqual:[UIColor clearColor]]) {
            //[self.textLabel setTextColor:TEXT_COLOR];

            arg1 = VIEW_COLOR;
        }
    }


        %orig(arg1);
}


-(id)backgroundColor {

    id kitties = %orig;

    if (isEnabled) {

        if (!isLightColor(kitties) && ![kitties isEqual:[UIColor clearColor]]) {
            //[((UITableViewCell*)self).textLabel setTextColor:TEXT_COLOR];
            kitties = VIEW_COLOR;
        }
    }

    return kitties;
}


-(id)selectionTintColor {

    if (isEnabled) {
        return [UIColor darkerColorForSelectionColor:selectedTintColor()];
    }


    return %orig;
}


%end

//Cell Selection


//Cell Edit Control (CONFLICTS WITH WINTERBOARD)
/*
%hook UITableViewCellEditControl

-(id)backgroundColor {

    UIColor* bgColor = %orig;

    if (isEnabled) {
        return VIEW_COLOR;
    }
    return bgColor;
}

%end
*/

/*
 db   dD d88888b db    db d8888b.  .d88b.   .d8b.  d8888b. d8888b.
 88 ,8P' 88'     `8b  d8' 88  `8D .8P  Y8. d8' `8b 88  `8D 88  `8D
 88,8P   88ooooo  `8bd8'  88oooY' 88    88 88ooo88 88oobY' 88   88
 88`8b   88~~~~~    88    88~~~b. 88    88 88~~~88 88`8b   88   88
 88 `88. 88.        88    88   8D `8b  d8' 88   88 88 `88. 88  .8D
 YP   YD Y88888P    YP    Y8888P'  `Y88P'  YP   YP 88   YD Y8888D'
*/


%hook UITextInputTraits


-(int)keyboardAppearance {
    if (isEnabled && darkenKeyboard()) {
        return 0;
    }
    return %orig;
}


%end


%hook UIKBRenderConfig

-(BOOL)lightKeyboard {
    if (isEnabled && darkenKeyboard()) {
        return NO;
    }
    return %orig;
}


%end


%hook UIKeyboard

-(id)initWithFrame:(CGRect)arg1 {
    id meow = %orig;
    if (isEnabled && darkenKeyboard()) {
        [self setBackgroundColor:keyboardColor()];
    }
    return meow;
}

%end






/*
 .d8888. d888888b  .d8b.  d888888b db    db .d8888. d8888b.  .d8b.  d8888b.
 88'  YP `~~88~~' d8' `8b `~~88~~' 88    88 88'  YP 88  `8D d8' `8b 88  `8D
 `8bo.      88    88ooo88    88    88    88 `8bo.   88oooY' 88ooo88 88oobY'
 `  Y8b.    88    88~~~88    88    88    88   `Y8b. 88~~~b. 88~~~88 88`8b
 db   8D    88    88   88    88    88b  d88 db   8D 88   8D 88   88 88 `88.
 `8888Y'    YP    YP   YP    YP    ~Y8888P' `8888Y' Y8888P' YP   YP 88   YD
 */

%hook UIStatusBar

-(id)foregroundColor {
    UIColor* color = %orig;
    if (isEnabled && shouldOverrideStatusBarStyle) {
        color = selectedStatusbarTintColor();
    }
    return color;
}
%end



/*
 d8888b. db   db  .d88b.  d8b   db d88888b
 88  `8D 88   88 .8P  Y8. 888o  88 88'
 88oodD' 88ooo88 88    88 88V8o 88 88ooooo
 88~~~   88~~~88 88    88 88 V8o88 88~~~~~
 88      88   88 `8b  d8' 88  V888 88.
 88      YP   YP  `Y88P'  VP   V8P Y88888P
*/

@interface PhoneViewController : UIViewController{}
@end

%group PhoneApp


%hook TSSuperBottomBarButton

-(id)init {
    id meh = %orig;
    if (isEnabled) {
        [self setBackgroundColor:selectedTintColor()];
    }
    return meh;
}

%end


%hook PhoneViewController

- (void)viewDidLoad {
    %orig;
    if (isEnabled) {
        [self.view setBackgroundColor:selectedTintColor()];
    }
}

%end


%hook PHHandsetDialerView

- (id)dialerColor {
    if (isEnabled) {
        return VIEW_COLOR;
    }
    return %orig;
}

%end



%hook TPNumberPadButton

+(id)imageForCharacter:(unsigned)arg1 highlighted:(BOOL)arg2 whiteVersion:(BOOL)arg3 {

    if (isEnabled) {
        return %orig(arg1, arg2, YES);
    }
    return %orig;
}

%end
%end

//Disable in Emergency Dial

 %hook PHEmergencyHandsetDialerView


 - (id)initWithFrame:(struct CGRect)arg1 {
 isEnabled = NO;
 id meow = %orig;
 isEnabled = isTweakEnabled();
 return meow;

 }

 %end



/*
  .d8b.  d8888b. d8888b. d8888b. d88888b .d8888. .d8888. d8888b. db   dD
 d8' `8b 88  `8D 88  `8D 88  `8D 88'     88'  YP 88'  YP 88  `8D 88 ,8P'
 88ooo88 88   88 88   88 88oobY' 88ooooo `8bo.   `8bo.   88oooY' 88,8P
 88~~~88 88   88 88   88 88`8b   88~~~~~   `Y8b.   `Y8b. 88~~~b. 88`8b
 88   88 88  .8D 88  .8D 88 `88. 88.     db   8D db   8D 88   8D 88 `88.
 YP   YP Y8888D' Y8888D' 88   YD Y88888P `8888Y' `8888Y' Y8888P' YP   YD
*/

%group ContactsApp

%hook UITextView

-(void)drawRect:(CGRect)arg1 {
    %orig;
    if (isEnabled) {
        if (!isLightColor(self.backgroundColor)) {

            if (![self.superview isKindOfClass:[UIImageView class]]) {

                id balloon = objc_getClass("CKBalloonTextView");

                if ([self class] == balloon) {
                    return;
                }
                else {
                    [self setBackgroundColor:[UIColor clearColor]];
                    [self setTextColor:TEXT_COLOR];
                }
            }
        }
    }
}

%end
%end

//DO NOT GROUP THIS.


//iOS 7.1+
%hook ABStyleProvider

- (id)membersBackgroundColor {
    if (isEnabled) {
        return VIEW_COLOR;
    }
    return %orig;
}

- (id)memberNameTextColor {
    if (isEnabled) {
        return TEXT_COLOR;
    }
    return %orig;

}

- (id)membersHeaderContentViewBackgroundColor {
    if (isEnabled) {
        return NAV_COLOR;
    }
    return %orig;
}


%end

%hook ABContactView

-(id)backgroundColor {
    if (isEnabled) {
        return TABLE_COLOR;
    }
    return %orig;
}

%end

/*
 .d8888. .88b  d88. .d8888.
 88'  YP 88'YbdP`88 88'  YP
 `8bo.   88  88  88 `8bo.
   `Y8b. 88  88  88   `Y8b.
 db   8D 88  88  88 db   8D
 `8888Y' YP  YP  YP `8888Y'
*/

//Do not group (text bubbles in compose views system-wide)

/*
%subclass CKUIThemeEclipse : CKUITheme

-(UIColor *)transcriptBackgroundColor;
-(UIColor *)messagesControllerBackgroundColor;
-(UIColor *)conversationListBackgroundColor;
-(UIColor *)dimmingViewBackgroundColor;
-(UIColor *)searchResultsBackgroundColor;
-(UIColor *)searchResultsCellBackgroundColor;
-(UIColor *)searchResultsCellSelectedColor;
-(UIColor *)searchResultsSeperatorColor;
-(UIColor *)entryFieldBackgroundColor;

%end
 */

//static CKUIThemeDark *darkTheme;

%subclass CKUIThemeEclipse : CKUIThemeDark

-(id)conversationListBackgroundColor {
    //if (isEnabled) {
        return VIEW_COLOR;
    //}
    //return %orig;
}
-(id)conversationListCellColor {
    //if (isEnabled) {
        return TABLE_COLOR;
    //}
    //return %orig;
}

-(id)transcriptBackgroundColor {
    //if (isEnabled) {
        return VIEW_COLOR;
    //}
    //return %orig;
}

-(id)blue_balloonColors {
    if (tintMessageBubbles() && isEnabled) {

        int number = [[prefs objectForKey:@"selectedTint"] intValue];

        if (number == 1) {

            NSArray* color = @[darkerColorForColor([selectedTintColor() colorWithAlphaComponent:0.7]), [selectedTintColor() colorWithAlphaComponent:0.7]];
            return color;
        }

        else {
            NSArray* color = @[darkerColorForColor([selectedTintColor() colorWithAlphaComponent:0.8]),selectedTintColor()];
            return color;
        }
    }
    //Disabled, but this fixes a stupid bug that I created by replacing systemBlueColor. So instead of properly tinting everything, I just assign a new blue.

    NSArray* originalColor = @[darkerColorForColor([BABY_BLUE_COLOR colorWithAlphaComponent:0.8]),BABY_BLUE_COLOR];

    return originalColor;
}

-(id)green_balloonColors {
    int number = [[prefs objectForKey:@"selectedTint"] intValue];
    if (isEnabled && (number == 1) && tintSMSBubbles()) {

        id _textView = MSHookIvar<id>(self, "_textView");
        return [UIColor blackColor];
    }
    return %orig;
}

/*

-(id)gray_balloonColors {
    if (isEnabled) {
        return @[VIEW_COLOR, NIGHT_VIEW_COLOR];
    }
    return %orig;
}
*
-(id)siri_balloonColors {
    if (isEnabled) {
        return @[VIEW_COLOR, NIGHT_VIEW_COLOR];
    }
    return %orig;
}

-(id)red_balloonColors {
    if (isEnabled) {
        return @[VIEW_COLOR, NIGHT_VIEW_COLOR];
    }
    return %orig;
}
 */

- (id)blue_balloonTextColor {
    int number = [[prefs objectForKey:@"selectedTint"] intValue];
    if (isEnabled && (number == 1) && tintMessageBubbles()) {

        id _textView = MSHookIvar<id>(self, "_textView");
        return [UIColor blackColor];
    }
    return %orig;
}

- (id)green_balloonTextColor {
    int number = [[prefs objectForKey:@"selectedTint"] intValue];
    if (isEnabled && (number == 1) && tintSMSBubbles()) {

        id _textView = MSHookIvar<id>(self, "_textView");
        return [UIColor blackColor];
    }
    return %orig;
}

%end

static CKUIThemeEclipse* eclipseTheme;


%hook CKUIBehaviorPhone
- (id)theme {
    if (isEnabled) {
        eclipseTheme = [[%c(CKUIThemeEclipse) alloc] init];
        return eclipseTheme;
    }
    return %orig;
}
%end



%hook CKUIBehaviorPad
- (id)theme {
    if (isEnabled) {
        eclipseTheme = [[%c(CKUIThemeEclipse)  alloc] init];
        return eclipseTheme;
    }
    return %orig;
}
%end



%hook CKConversationListCell

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        id _dateLabel = MSHookIvar<id>(self, "_dateLabel");
        id _summaryLabel = MSHookIvar<id>(self, "_summaryLabel");

        if (shouldColorDetailText()) {
            [_dateLabel setTextColor:selectedTintColor()];
            [_summaryLabel setTextColor:selectedTintColor()];
        }
        else {
            [_dateLabel setTextColor:TEXT_COLOR];
            [_summaryLabel setTextColor:TEXT_COLOR];
        }
    }

}

%end


%hook CKTextBalloonView

-(void)layoutSubviews {
    %orig;

    int number = [[prefs objectForKey:@"selectedTint"] intValue];
    if (isEnabled && (number == 1)) {

        id _textView = MSHookIvar<id>(self, "_textView");
        [_textView setTextColor:[UIColor blackColor]];
    }
}

-(void)setCanUseOpaqueMask:(BOOL)canit {
    if (isEnabled) {
        %orig(NO);
        return;
    }
    %orig;
}


%end

%hook CKImageBalloonView

-(void)setCanUseOpaqueMask:(BOOL)canit {
    if (isEnabled) {
        %orig(NO);
        return;
    }
    %orig;
}

%end


%hook CKColoredBalloonView

-(void)setCanUseOpaqueMask:(BOOL)arg1 {
    if (isEnabled) {
        %orig(NO);
        return;
    }
    %orig;
}

%end
/*
@interface _UITextFieldRoundedRectBackgroundViewNeue : NSObject
-(void)setFillColor:(UIColor*)color ;
@end
 */

%hook CKMessageEntryView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UIView* _contentView = MSHookIvar<UIView*>(self, "_contentView");

        [_contentView setBackgroundColor:VIEW_COLOR];

    }
}

%end

%hook CKMessageEntryContentView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        id textView = MSHookIvar<id>(self, "_textView");
        [textView setTextColor:TEXT_COLOR];
    }
}

%end

%hook _MFAtomTextView

- (void)drawRect:(CGRect)rect  {
    %orig;
    if (isEnabled) {
        [self setTextColor:TEXT_COLOR];
    }
}

%end



/*
 .88b  d88.  .d8b.  d888888b db
 88'YbdP`88 d8' `8b   `88'   88
 88  88  88 88ooo88    88    88
 88  88  88 88~~~88    88    88
 88  88  88 88   88   .88.   88booo.
 YP  YP  YP YP   YP Y888888P Y88888P
*/

%group MailApp

%hook MailboxContentViewCell
-(UIColor*)deselectedBackgroundColor {
    if (isEnabled) {
        return VIEW_COLOR;
    }
    return %orig;
}

%end

%hook UITableViewCellSelectedBackground

- (void)drawRect:(CGRect)arg1 {
    %orig;
    if (isEnabled) {
        UIView* fixView = [[UIView alloc] init];
        fixView.frame = [self frame];
        fixView.backgroundColor = VIEW_COLOR;
        [self addSubview:fixView];
        [fixView release];
    }
    //I'm lazy as fuck.
}



%end

%hook MFMessageWebLayer

static NSString* css = @"font-face { font-family: 'Chalkboard'; src: local('ChalkboardSE-Regular'); } body { background-color: none; color: #C7C7C7; font-family: Chalkboard;} a { color: #3E98BD; text-decoration: none;}";

-(void)setFrame:(CGRect)arg1 {
    %orig;
    if (isEnabled) {
        [self setOpaque:NO];

    }
}

- (void)_webthread_webView:(id)arg1 didFinishDocumentLoadForFrame:(id)arg2 {
    if (isEnabled) {
        [self setUserStyleSheet:css];
    }
    %orig;

}

- (void)_webthread_webView:(id)arg1 didFinishLoadForFrame:(id)arg2 {
    if (isEnabled) {
        [self setUserStyleSheet:css];
    }
    %orig;
}

- (void)webView:(id)arg1 didFinishLoadForFrame:(id)arg2 {
    if (isEnabled) {
        [self setUserStyleSheet:css];
    }
    %orig;
}

- (void)webThreadWebView:(id)arg1 resource:(id)arg2 didFinishLoadingFromDataSource:(id)arg3 {
    if (isEnabled) {
        [self setUserStyleSheet:css];
    }
    %orig;
}

%end


%hook MFSubjectWebBrowserView


-(void)loadHTMLString:(id)arg1 baseURL:(id)arg2 {

    if (isEnabled) {
        arg1 = [arg1 stringByReplacingOccurrencesOfString:@"color: #000"
                                               withString:@"color: #C7C7C7"];
        [self setOpaque:NO];
    }


    %orig(arg1, arg2);
}

%end

%hook _CellStaticView

- (void)layoutSubviews {
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }
}

%end

%end

//Do not group (Body compose view)

%hook MFMailComposeView

-(id)bodyTextView {
    id view = %orig;
    if (isEnabled) {
        [view setTextColor:TEXT_COLOR];
    }
    return view;
}

%end


/*
 .d8888.  .d8b.  d88888b  .d8b.  d8888b. d888888b
 88'  YP d8' `8b 88'     d8' `8b 88  `8D   `88'
 `8bo.   88ooo88 88ooo   88ooo88 88oobY'    88
 `Y8b. 88~~~88 88~~~   88~~~88 88`8b      88
 db   8D 88   88 88      88   88 88 `88.   .88.
 `8888Y' YP   YP YP      YP   YP 88   YD Y888888P
 */


@interface NavigationBarBackdrop : _UIBackdropView
- (void)applySettings:(id)arg1;
@end


@interface DimmingButton : UIButton
-(UIImage *)maskImage:(UIImage*)image withColor:(UIColor *)color;
@end



%group SafariApp


%hook _SFNavigationBar

/*
 -(void)tintColorDidChange {
 if (isEnabled) {
 return;
 }
 %orig;
 }
 -(void)_updateControlTints {
 if (isEnabled) {
 return;
 }
 %orig;
 }
 */
-(void)_updateTextColor {
    if (isEnabled) {
        return;
    }
    %orig;
}

-(void)setPreferredControlsTintColor:(id)arg1 {
    if (isEnabled) {
        arg1 = selectedTintColor();
    }
    %orig(arg1);
}

-(id)_EVCertLockAndTextColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}
-(id)_tintForLockImage:(bool)arg1 {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}


-(id)_URLTextColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}

-(id)_placeholderColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}

-(id)preferredBarTintColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}
-(id)preferredControlsTintColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
    
}

-(id)_URLControlsColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}

-(id)reloadButton {
    id x = %orig;
    
    if (isEnabled) {
        [x setTintColor:selectedTintColor()];
    }
    
    return x;
}
-(id)readerButton {
    id x = %orig;
    
    if (isEnabled) {
        [x setTintColor:selectedTintColor()];
    }
    
    return x;
}

%end

%hook TabBar

- (void)layoutSubviews {
    
    %orig;
    
    if (isEnabled) {
        
        UIView *_leadingContainer = MSHookIvar<UIButton*>(self, "_leadingContainer");
        
        UIView *_leadingBackgroundOverlayView = MSHookIvar<UIButton*>(self, "_leadingBackgroundOverlayView");
        
        UIView *_leadingBackgroundTintView = MSHookIvar<UIButton*>(self, "_leadingBackgroundTintView");
        
        _leadingContainer.alpha = 0.1;
        
        
        
    }
}

%end

%hook _SFToolbar

- (void)layoutSubviews {
    %orig;
    
    if (isEnabled) {
        _UIBackdropView* backdropView = MSHookIvar<_UIBackdropView*>(self, "_backgroundView");
        
        //_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:2030];
        //[settings setColorTint:RED_COLOR];
        //[backdropView applySettings:settings];
        
        UIView* toolbarBackground = [[UIView alloc] initWithFrame:backdropView.frame];
        [toolbarBackground setBackgroundColor:NAV_COLOR];
        [backdropView addSubview:toolbarBackground];
        [toolbarBackground release];
        
        //backdropView.hidden = YES;
    }
}

%end

%end


/*
 d8888b.  .d8b.  .d8888. .d8888. d8888b.  .d88b.   .d88b.  db   dD
 88  `8D d8' `8b 88'  YP 88'  YP 88  `8D .8P  Y8. .8P  Y8. 88 ,8P'
 88oodD' 88ooo88 `8bo.   `8bo.   88oooY' 88    88 88    88 88,8P
 88~~~   88~~~88   `Y8b.   `Y8b. 88~~~b. 88    88 88    88 88`8b
 88      88   88 db   8D db   8D 88   8D `8b  d8' `8b  d8' 88 `88.
 88      YP   YP `8888Y' `8888Y' Y8888P'  `Y88P'   `Y88P'  YP   YD
*/

%group PassbookApp

%hook WLEasyToHitCustomView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        for (UIView* button in [self subviews]) {
            if ([button isKindOfClass:[UIButton class]]) {
                [button setBackgroundColor:[UIColor clearColor]];
            }
        }
    }
}

%end

%end

/*
 d8888b. d88888b .88b  d88. d888888b d8b   db d8888b. d88888b d8888b. .d8888.
 88  `8D 88'     88'YbdP`88   `88'   888o  88 88  `8D 88'     88  `8D 88'  YP
 88oobY' 88ooooo 88  88  88    88    88V8o 88 88   88 88ooooo 88oobY' `8bo.
 88`8b   88~~~~~ 88  88  88    88    88 V8o88 88   88 88~~~~~ 88`8b     `Y8b.
 88 `88. 88.     88  88  88   .88.   88  V888 88  .8D 88.     88 `88. db   8D
 88   YD Y88888P YP  YP  YP Y888888P VP   V8P Y8888D' Y88888P 88   YD `8888Y'
*/

%group RemindersApp

%hook RemindersSearchView

#warning Reminders needs work
-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UIView* searchView = MSHookIvar<UIView*>(self, "_searchResultsView");
    }

}

%end

%hook RemindersCardBackgroundView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setAlpha:0.9];
        for (UIView* view in [self subviews]) {

            //[view setAlpha:0.7];
            [view setBackgroundColor:[VIEW_COLOR colorWithAlphaComponent:0.8]];
        }
    }
}

%end

%end

/*
 .88b  d88. db    db .d8888. d888888b  .o88b.
 88'YbdP`88 88    88 88'  YP   `88'   d8P  Y8
 88  88  88 88    88 `8bo.      88    8P
 88  88  88 88    88   `Y8b.    88    8b
 88  88  88 88b  d88 db   8D   .88.   Y8b  d8
 YP  YP  YP ~Y8888P' `8888Y' Y888888P  `Y88P'
*/

%group MusicApp


/*
%hook UIColor
//such hacky

+(id)blackColor {
    if (isEnabled) {
        return TEXT_COLOR;
    }
    return %orig;
}

+(id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {

    if (isEnabled) {
        if ((red == 0.0) && (green == 0.0) && (blue == 0.0) && (alpha < 0.7)) {
            return TEXT_COLOR;
        }
    }
    return %orig;
}

+(id)colorWithWhite:(float)arg1 alpha:(float)arg2 {

    id color = %orig;

    if (isEnabled) {
        if ((arg1 < .5)) {
            return [TEXT_COLOR colorWithAlphaComponent:0.4];
        }
    }
    return %orig;
}
%end
*/

/*
%hook CALayer

-(CGColorRef)contentsMultiplyColor {
    return [selectedTintColor() CGColor];
}

%end
 */

/*
%hook UITableViewCellContentView

-(void)layoutSubviews {
    %orig;

    if (isEnabled) {
        for (UIView* view in [self subviews]) {
            for (id textLabel in [view subviews]) {
                if ([textLabel respondsToSelector:@selector(text)]) {



                    //UILabel* replacementLabel = [[UILabel alloc] initWithFrame:[textLabel frame]];
                    //replacementLabel.text = [textLabel text];
                    //[textLabel removeFromSuperview];
                    //replacementLabel.textColor = TEXT_COLOR;
                    //[view addSubview:replacementLabel];
                    //[replacementLabel release];

                }
            }
        }
    }

}


%end
 */

/*
%hook UIButton

-(void)setBounds:(CGRect)arg1 {
    %orig;

    if (isEnabled) {
        [self setTintColor:TEXT_COLOR];
    }
}

-(void)setFrame:(CGRect)arg1 {
    %orig;
    [self setTintColor:TEXT_COLOR];

}

- (id)initWithFrame:(struct CGRect)arg1 {
    id kek = %orig;

    [self setTintColor:TEXT_COLOR];

    return kek;
}




%end
*/

%hook UIStackView

- (id)initWithCoder:(id)arg1 {
    id x = %orig;
    applyInvertFilter(self);
    return x;

}



%end

%hook UIImageView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        if ([NSStringFromClass([self.superview class]) isEqualToString:@"Music.ArtworkComponentImageView"]) {
            [self setHidden:YES];
        }
        /*
        //Fix Controls
        if ([NSStringFromClass([self.superview class]) isEqualToString:@"Music.NowPlayingTransportButton"]) {

            applyInvertFilter(self);
            //[self setHidden:YES];
        }
        */
    }

}

-(void)setTintColor:(UIColor*)color {
    if (isEnabled) {
        %orig(selectedTintColor());
        return;
    }
    %orig;

}
-(UIColor*)tintColor {
    if (isEnabled) {
        return selectedTintColor();
    }
    return %orig;
}

/*
 -(void)didMoveToSuperview {

 //Fix Controls
 if ([NSStringFromClass([self.superview class]) isEqualToString:@"Music.NowPlayingTransportButton"]) {

 applyInvertFilter(self);
 [self setTintColor:WHITE_COLOR]
 //[self setHidden:YES];
 }
 %orig;
 }
 */

%end

%hook UILabel

-(void)layoutSubviews {

    %orig;
    if (isEnabled) {
        if ([NSStringFromClass([self.superview class]) isEqualToString:@"Music.MiniPlayerButton"]) {
            [self setHidden:YES];
        }
        /*
         //Fix Controls
         if ([NSStringFromClass([self.superview class]) isEqualToString:@"Music.NowPlayingTransportButton"]) {

         applyInvertFilter(self);
         //[self setHidden:YES];
         }
         */
    }

}


%end






%hook _TtCVV5Music4Text7Drawing4View

-(id)init {

    id x = %orig;
    applyInvertFilter((UIView*)self);
    return x;

}

%end



%end

/*
 d8b   db  .d88b.  d888888b d88888b .d8888.
 888o  88 .8P  Y8. `~~88~~' 88'     88'  YP
 88V8o 88 88    88    88    88ooooo `8bo.
 88 V8o88 88    88    88    88~~~~~   `Y8b.
 88  V888 `8b  d8'    88    88.     db   8D
 VP   V8P  `Y88P'     YP    Y88888P `8888Y'
*/

%group NotesApp



%end

/*
%group NotesApp

%hook UIColor
//such hacky

+(id)colorWithWhite:(float)arg1 alpha:(float)arg2 {

    id color = %orig;

    if (isEnabled) {
        if (arg1 < .5) {
            return TEXT_COLOR;
        }
    }
    return %orig;
}
%end

%hook _UINavigationBarBackground

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:NAV_COLOR];
    }
}

%end

%hook NotesTextureView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self removeFromSuperview];
    }
}

%end

%end
*/
/*
  .d8b.  d8888b. d8888b. .d8888. d888888b  .d88b.  d8888b. d88888b
 d8' `8b 88  `8D 88  `8D 88'  YP `~~88~~' .8P  Y8. 88  `8D 88'
 88ooo88 88oodD' 88oodD' `8bo.      88    88    88 88oobY' 88ooooo
 88~~~88 88~~~   88~~~     `Y8b.    88    88    88 88`8b   88~~~~~
 88   88 88      88      db   8D    88    `8b  d8' 88 `88. 88.
 YP   YP 88      88      `8888Y'    YP     `Y88P'  88   YD Y88888P
*/

%group MobileStoreApp

%hook UIColor
//such hacky

+(id)blackColor {
    if (isEnabled) {
        return TEXT_COLOR;
    }
    return %orig;
}

+(id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {

    if (isEnabled) {
        if ((red == 0.0) && (green == 0.0) && (blue == 0.0) && (alpha < 0.7)) {
            return TEXT_COLOR;
        }
    }
    return %orig;
}

+(id)colorWithWhite:(float)arg1 alpha:(float)arg2 {

    id color = %orig;

    if (isEnabled) {
        if ((arg1 < .5)) {
            return TEXT_COLOR;
        }
    }
    return %orig;
}
%end



%end

%group AppstoreApp

/*
%hook UIColor
//such hacky

+(id)blackColor {
    if (isEnabled) {
        return TEXT_COLOR;
    }
    return %orig;
}

+(id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {

    if (isEnabled) {
        if ((red == 0.0) && (green == 0.0) && (blue == 0.0) && (alpha < 0.7)) {
            return TEXT_COLOR;
        }
    }
    return %orig;
}

+(id)colorWithWhite:(float)arg1 alpha:(float)arg2 {

    id color = %orig;

    if (isEnabled) {
        if ((arg1 < .5)) {
            return [TEXT_COLOR colorWithAlphaComponent:0.4];
        }
    }
    return %orig;
}
%end
*/

%hook SKUIStackedBarCell

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:NAV_COLOR];

    }
}
%end


%hook SKUITableViewCell

-(void)layoutSubviews {
    %orig;
    [self setBackgroundColor:VIEW_COLOR];
}

%end

%hook SKUITextBoxView

-(id)initWithFrame:(CGRect)arg1 {
    id frame = %orig;
    if (isEnabled) {


        applyInvertFilter((UIView*)self);

        //id _colorScheme = MSHookIvar<id>(self, "_colorScheme");
        //id colorScheme = [[[%c(SKUIColorScheme) alloc] init] autorelease];
        //[colorScheme setPrimaryTextColor:TEXT_COLOR];
        //[colorScheme setSecondaryTextColor:selectedTintColor()];

        //_colorScheme = colorScheme;

        //[self setColorScheme:_colorScheme];

    }
    return frame;
}

- (void)setColorScheme:(id)arg1 {

    //id _colorScheme = MSHookIvar<id>(self, "_colorScheme");
    id colorScheme = [[%c(SKUIColorScheme) alloc] initWithCoder:nil];
    [colorScheme setBackgroundColor:TEXT_COLOR];
    [colorScheme setSecondaryTextColor:selectedTintColor()];

    //_colorScheme = colorScheme;

    HBLogInfo(@"COLOR SCHEME: %@",colorScheme);
    %orig(colorScheme);
}

-(UIColor*)backgroundColor {
    if (isEnabled) {
        return [UIColor clearColor];
    }
    return %orig;
}

-(void)setBackgroundColor:(UIColor*)color {
    if (isEnabled) {
        %orig([UIColor clearColor]);
        return;
    }
    %orig;

}


%end

%hook SKUIStyledButton

- (id)_textColor {
    return RED_COLOR;
}

- (BOOL)_usesTintColor {
    return YES;
}


%end

/*
 %hook SKUIAttributedStringLayout

 -(NSAttributedString*)attributedString {

 NSAttributedString* originalAttributedString = %orig;
 NSString* originalString = [originalAttributedString string];

 NSMutableAttributedString* newAttributedString = [originalAttributedString mutableCopy];

 [newAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0, originalString.length)];


 return newAttributedString;
 }

 %end
 */

%hook SKUIAttributedStringView

-(id)init {
    id string = %orig;
    if (isEnabled) {


        //[self setTextColor:TEXT_COLOR];
        applyInvertFilter((UIView*)self);

    }
    return string;
}

-(UIColor*)backgroundColor {
    if (isEnabled) {
        return [UIColor clearColor];
    }
    return %orig;
}

-(void)setBackgroundColor:(UIColor*)color {
    if (isEnabled) {
        %orig([UIColor clearColor]);
        return;
    }
    %orig;

}

%end

%hook SKUIProductPageHeaderLabel

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setTextColor:TEXT_COLOR];
    }
}

%end


%end






//Watch App

%group WatchApp

%hook UIColor
//such hacky

+(id)blackColor {
    if (isEnabled) {
        return TEXT_COLOR;
    }
    return %orig;
}

+(id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {

    if (isEnabled) {
        if ((red == 0.0) && (green == 0.0) && (blue == 0.0) && (alpha < 0.7)) {
            return TEXT_COLOR;
        }
    }
    return %orig;
}

+(id)colorWithWhite:(float)arg1 alpha:(float)arg2 {

    id color = %orig;

    if (isEnabled) {
        if ((arg1 < .5)) {
            return [TEXT_COLOR colorWithAlphaComponent:0.4];
        }
    }
    return %orig;
}
%end

%end

//Calendar

%group CalendarApp
%hook UIColor

//such hacky

+(id)whiteColor {
    if (isEnabled) {
        return VIEW_COLOR;
    }
    return %orig;
}

+(id)blackColor {
    if (isEnabled) {
        return TEXT_COLOR;
    }
    return %orig;
}

+(id)colorWithWhite:(float)arg1 alpha:(float)arg2 {
    UIColor* color = %orig;
    if (![color isEqual:TEXT_COLOR] && (isLightColor(color)) && (IsiPad)) {
        return VIEW_COLOR;
    }
    return color;
}

%end
%end

%group CalendarFix
%hook UIStatusBar

-(id)foregroundColor {
    UIColor* color = %orig;
    if (isEnabled) {
        if ([selectedStatusbarTintColor() isEqual:WHITE_COLOR]) {
            color = [UIColor lightGrayColor];
        }
        else {
            color = selectedStatusbarTintColor();
        }
    }
    return color;
}
%end
%end


@interface PFColorViewController : UIViewController{}
@end

%hook PFColorViewController

- (id)initForContentSize:(CGSize)size {
    id cat = %orig;

    UIView* _pushedView = MSHookIvar<UIView*>(self, "_pushedView");
    UIView* transparent = MSHookIvar<UIView*>(self, "transparent");
    UIView* controlsContainer = MSHookIvar<UIView*>(self, "controlsContainer");

    _pushedView.tag = VIEW_EXCLUDE_TAG;
    transparent.tag = VIEW_EXCLUDE_TAG;
    controlsContainer.tag = VIEW_EXCLUDE_TAG;

    self.view.tag = VIEW_EXCLUDE_TAG;
    return cat;
}
%end

//Maps App

%group MapsApp

%hook BlurView

- (id)initWithFrame:(struct CGRect)arg1 privateStyle:(long long)arg2 {
    id blurView = %orig;

    if (isEnabled) {
        id _backdrop = MSHookIvar<id>(self, "_backdrop");
        UIView* fixView = [[UIView alloc] init];
        fixView.frame = [_backdrop frame];
        [fixView setBackgroundColor:VIEW_COLOR];
        [_backdrop addSubview:fixView];
        [fixView release];
    }
    return blurView;
}

%end

%end


/*
 _____         _                    _
 |____ |       | |                  | |
     / /_ __ __| |  _ __   __ _ _ __| |_ _   _
     \ \ '__/ _` | | '_ \ / _` | '__| __| | | |
 .___/ / | | (_| | | |_) | (_| | |  | |_| |_| |
 \____/|_|  \__,_| | .__/ \__,_|_|   \__|\__, |
                   | |                    __/ |
                   |_|                   |___/
*/



/*
  .o88b.  .d88b.  db    db d8888b. d888888b  .d8b.
 d8P  Y8 .8P  Y8. 88    88 88  `8D   `88'   d8' `8b
 8P      88    88 88    88 88oobY'    88    88ooo88
 8b      88    88 88    88 88`8b      88    88~~~88
 Y8b  d8 `8b  d8' 88b  d88 88 `88.   .88.   88   88
`  Y88P'  `Y88P'  ~Y8888P' 88   YD Y888888P YP   YP
 */

%hook CouriaController

-(void)present {
    isEnabled = NO;
    %orig;
}

-(void)dismiss {
    isEnabled = isTweakEnabled();
    %orig;
}

%end

/*
 db   d8b   db db   db  .d8b.  d888888b .d8888.  .d8b.  d8888b. d8888b.
 88   I8I   88 88   88 d8' `8b `~~88~~' 88'  YP d8' `8b 88  `8D 88  `8D
 88   I8I   88 88ooo88 88ooo88    88    `8bo.   88ooo88 88oodD' 88oodD'
 Y8   I8I   88 88~~~88 88~~~88    88      `Y8b. 88~~~88 88~~~   88~~~
 `8b d8'8b d8' 88   88 88   88    88    db   8D 88   88 88      88
  `8b8' `8d8'  YP   YP YP   YP    YP    `8888Y' YP   YP 88      88
 */

%group WhatsappApp

%hook WALabel

-(id)initWithFrame:(CGRect)frame {
    id meh = %orig;

    if (isEnabled) {

        [self setTextColor:RED_COLOR];
    }
    return meh;
}

%end

%hook WATextMessageCell

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        for (UILabel* label in [[self contentView] subviews]) {
            if ([(UILabel*)label respondsToSelector:@selector(setTextColor:)]) {

                //Random Color
                /*
                NSArray* availableColors = @[BABY_BLUE_COLOR, PINK_COLOR, DARK_ORANGE_COLOR, GREEN_COLOR, PURPLE_COLOR, RED_COLOR, YELLOW_COLOR];

                UIColor* rand = availableColors.count == 0 ? nil : availableColors[arc4random_uniform(availableColors.count)];
                 */

                [label setTextColor:RED_COLOR];
            }
        }
    }
}

%end

%hook WAInputTextView

-(void)drawRect:(CGRect)arg1 {
    %orig;

    if (isEnabled) {
        [self setTextColor:TEXT_COLOR];

    }

}

%end


%hook WAChatBar

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UIButton* _sendButton = MSHookIvar<UIButton*>(self, "_sendButton");
        UIButton* _attachMediaButton = MSHookIvar<UIButton*>(self, "_attachMediaButton");
        UIButton* _cameraButton = MSHookIvar<UIButton*>(self, "_cameraButton");
        UIButton* _pttButton = MSHookIvar<UIButton*>(self, "_pttButton");

        [_sendButton setTintColor:selectedTintColor()];
        [_attachMediaButton setTintColor:selectedTintColor()];
        [_cameraButton setTintColor:selectedTintColor()];
        [_pttButton setTintColor:selectedTintColor()];
    }

}

%end

%hook WAMessageFooterView

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UILabel* _timestampLabel = MSHookIvar<UILabel*>(self, "_timestampLabel");
        [_timestampLabel setTextColor:RED_COLOR];
    }
}

%end

%hook WAEventBubbleView

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UILabel* labelEvent = MSHookIvar<UILabel*>(self, "_labelEvent");
        [labelEvent setTextColor:RED_COLOR];
    }
}

%end

%hook WADateBubbleView

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UILabel* titleLabel = MSHookIvar<UILabel*>(self, "_titleLabel");
        [titleLabel setTextColor:RED_COLOR];
    }


}

%end

%hook WAChatButton

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setTintColor:selectedTintColor()];
    }
}

%end

%hook WAChatSessionCell

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UILabel* messageLabel = MSHookIvar<UILabel*>(self, "_messageLabel");
        if (shouldColorDetailText()) {
            //[messageLabel setTextColor:selectedTintColor()];
        }
        else {
            //[messageLabel setTextColor:TEXT_COLOR];
        }
    }
}

%end

%hook WAContactNameLabel

- (id)textColor {
    if (isEnabled) {
        [self setBackgroundColor:[UIColor clearColor]];
        return TEXT_COLOR;
    }
    return %orig;
}

- (void)setTextColor:(id)fp8 {
    if (isEnabled) {
        %orig(TEXT_COLOR);
        [self setBackgroundColor:[UIColor clearColor]];
        return;
    }
    %orig;
}

%end

/*
 %hook _WANoBlurNavigationBar

 - (void)layoutSubviews {
 %orig;
 if (isEnabled) {
 UIView* bgView = MSHookIvar<UIView*>(self, "_grayBackgroundView");
 [bgView setBackgroundColor:NAV_COLOR];
 }

 }

 - (id)initWithFrame:(struct CGRect)arg1 {
 id bar = %orig;
 if (isEnabled) {
 UIView* bgView = MSHookIvar<UIView*>(self, "_grayBackgroundView");
 [bgView setBackgroundColor:NAV_COLOR];
 }
 return bar;
 }

 %end
 */

%end



/*
 d888888b d8b   db .d8888. d888888b  .d8b.   d888b  d8888b.  .d8b.  .88b  d88.
   `88'   888o  88 88'  YP `~~88~~' d8' `8b 88' Y8b 88  `8D d8' `8b 88'YbdP`88
    88    88V8o 88 `8bo.      88    88ooo88 88      88oobY' 88ooo88 88  88  88
    88    88 V8o88   `Y8b.    88    88~~~88 88  ooo 88`8b   88~~~88 88  88  88
   .88.   88  V888 db   8D    88    88   88 88. ~8~ 88 `88. 88   88 88  88  88
 Y888888P VP   V8P `8888Y'    YP    YP   YP  Y888P  88   YD YP   YP YP  YP  YP
*/

@interface IGStringStyle : NSObject
@property(retain, nonatomic) UIColor *defaultColor;
@end

%group InstagramApp



%hook IGSimpleButton

- (void)layoutSubviews {
    %orig;

    if (isEnabled) {
        UIImageView* _backgroundImageView = MSHookIvar<UIImageView*>(self, "_backgroundImageView");

        [_backgroundImageView setAlpha:0.1];
    }
}

%end


%hook _UIBarBackground

- (void)layoutSubviews {
    %orig;

    if (isEnabled) {
        [self setHidden:YES];
    }
}
%end


%hook UITextFieldBorderView

-(void)layoutSubviews {
    %orig;

    if (isEnabled) {
        [self setAlpha:0.05];
    }
}

%end


%hook IGColors

+ (id)separatorColor {
    return selectedTintColor();
}

+ (id)boldLinkHighlightedColor {
    return selectedTintColor();
}
+ (id)boldLinkColor {
    return selectedTintColor();
}
+ (id)linkHighlightedColor {
    return selectedTintColor();

}
+ (id)linkColor {
    return selectedTintColor();

}
+ (id)veryLightTextColor {
    return TEXT_COLOR;
}
+ (id)secondaryTextColor {
    return TEXT_COLOR;
}
+ (id)textColor {
    return TEXT_COLOR;
}

+ (id)lightBarBackgroundColor {
    return NAV_COLOR;
}




%end

%end

/*
 d888888b db   d8b   db d888888b d888888b d888888b d88888b d8888b.
 `~~88~~' 88   I8I   88   `88'   `~~88~~' `~~88~~' 88'     88  `8D
    88    88   I8I   88    88       88       88    88ooooo 88oobY'
    88    Y8   I8I   88    88       88       88    88~~~~~ 88`8b
    88    `8b d8'8b d8'   .88.      88       88    88.     88 `88.
    YP     `8b8' `8d8'  Y888888P    YP       YP    Y88888P 88   YD
 */

%group TwitterApp

%hook T1StatusView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }
}

%end


%hook ABCustomHitTestView

-(id)backgroundColor {
    return RED_COLOR;
}

%end



%hook TFNCellDrawingView

- (void)setBackgroundColor:(id)arg1 {
    if (isEnabled) {
        arg1 = VIEW_COLOR;
    }
    %orig(arg1);
}

%end

%hook T1TweetDetailsAttributedStringItem //1.4.3 fix

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }
}

%end

%hook TFNTwitterStandardColorPalette

//Usernames
- (id)_twitterColorText {
    return selectedTintColor();
}
- (id)twitterColorText {
    return TEXT_COLOR;
}


%end
%end


/*
 db   dD d888888b db   dD
 88 ,8P'   `88'   88 ,8P'
 88,8P      88    88,8P
 88`8b      88    88`8b
 88 `88.   .88.   88 `88.
 YP   YD Y888888P YP   YD
*/

#import <QuartzCore/QuartzCore.h>

%group KikApp

%hook TintedUIButton

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setTag:VIEW_EXCLUDE_TAG];
        [self setBackgroundColor:WHITE_COLOR];

    }
}

%end

%hook UICollectionViewCell

-(void)layoutSubviews {
    %orig;

    for (UIView* a in [self subviews]) {
        for (UIImageView* b in [a subviews]) {
            if ([b respondsToSelector:@selector(setImage:)]) {
                //b.alpha = 0.0;
            }
        }
    }
}

%end

%hook KikOutgoingContentMessageCell

- (void)layoutCellSubviews {
    %orig;

    UIButton* _bubbleButton = MSHookIvar<UIButton*>(self, "_bubbleButton");
    [_bubbleButton setTag:VIEW_EXCLUDE_TAG];
    _bubbleButton.layer.cornerRadius = 20;
    _bubbleButton.layer.masksToBounds = YES;

    [_bubbleButton setBackgroundColor:[UIColor clearColor]]; //Set color, even if Kik won't allow it

    UIImageView* _bubbleMask = MSHookIvar<UIImageView*>(self, "_bubbleMask");
    [_bubbleMask setHidden:YES];


}

%end

%hook KikIncomingContentMessageCell

- (void)layoutCellSubviews {
    %orig;

    UIButton* _bubbleButton = MSHookIvar<UIButton*>(self, "_bubbleButton");
    [_bubbleButton setTag:VIEW_EXCLUDE_TAG];
    _bubbleButton.layer.cornerRadius = 20;
    _bubbleButton.layer.masksToBounds = YES;

    [_bubbleButton setBackgroundColor:[UIColor clearColor]]; //Set color, even if Kik won't allow it


    UIImageView* _bubbleMask = MSHookIvar<UIImageView*>(self, "_bubbleMask");
    [_bubbleMask setHidden:YES];


}

%end


%hook KikTextMessageCell

- (void)setupSubviews {
    %orig;

    UIButton* _bubbleButton = MSHookIvar<UIButton*>(self, "_bubbleButton");
    [_bubbleButton setTag:VIEW_EXCLUDE_TAG];
    _bubbleButton.layer.cornerRadius = 20;
    _bubbleButton.layer.masksToBounds = YES;


    UIImageView* _bubbleMask = MSHookIvar<UIImageView*>(self, "_bubbleMask");
    [_bubbleMask setHidden:YES];
    //_bubbleMask.layer.cornerRadius = 12;
    //_bubbleMask.layer.masksToBounds = YES;

}



%end

%hook HybridSmileyLabel

- (id)textColor {
    if (isEnabled) {
        return [UIColor darkGrayColor];
    }
    return %orig;
}


%end

%hook BlurryUIView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:NAV_COLOR];
    }

}
%end

%hook BlurredRawProfilePictureImageView

- (id)initWithFrame:(struct CGRect)arg1 {
    id kek = %orig;
    if (isEnabled) {
        UIColor* _blurTintColor = MSHookIvar<UIColor*>(self, "_blurTintColor");
        _blurTintColor = VIEW_COLOR;
        [self setAlpha:0.2];
    }
    return kek;
}

%end

%hook CardListTableViewCell


- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UIImageView* backgroundImage = MSHookIvar<UIImageView*>(self, "_imgBackground");
        [backgroundImage removeFromSuperview];
    }
}

%end

%hook HPTextViewInternal

- (id)updateTextForSmileys {
    id kek = %orig;
    if (isEnabled) {
        [self setTextColor:TEXT_COLOR];
    }
    return kek;
}

-(void)setPlaceholder:(NSString *)placeholder {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
        [self setOpaque:YES];
        [self setTextColor:TEXT_COLOR];
    }
}
-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
        [self setOpaque:YES];
        [self setTextColor:TEXT_COLOR];
    }
}

-(void)setTextColor:(id)color {
    if (isEnabled) {
        %orig(TEXT_COLOR);
        return;
    }
    %orig;
}

-(id)textColor {
    if (isEnabled) {
        return TEXT_COLOR;
    }
    return %orig;
}

- (void)drawRect:(CGRect)rect {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
        [self setOpaque:YES];
        [self setTextColor:TEXT_COLOR];
    }
}


%end

%end

/*
 d888888b db   db d8888b. d88888b d88888b .88b  d88.  .d8b.
 `~~88~~' 88   88 88  `8D 88'     88'     88'YbdP`88 d8' `8b
    88    88ooo88 88oobY' 88ooooo 88ooooo 88  88  88 88ooo88
    88    88~~~88 88`8b   88~~~~~ 88~~~~~ 88  88  88 88~~~88
    88    88   88 88 `88. 88.     88.     88  88  88 88   88
    YP    YP   YP 88   YD Y88888P Y88888P YP  YP  YP YP   YP
*/

%group ThreemaApp

@interface ChatBar : UIImageView
+ (int)perceivedBrightness:(UIColor *)aColor;
+ (UIColor *)contrastBWColor:(UIColor *)aColor;
+ (UIImage *)_imageWithColor:(UIColor *)color;
-(id)initWithFrame:(CGRect)arg1;
@end

%hook ChatBar
%new
+ (int)perceivedBrightness:(UIColor *)aColor
{
	CGFloat r = 0, g = 0, b = 0, a = 1;
	if ( [aColor getRed:&r green:&g blue:&b alpha:&a] ) {
		r=255*r; g=255*g; b=255*b;
		return (int)sqrt(r * r * .241 + g * g * .691 + b * b * .068);
	} else if ([aColor getWhite:&r alpha:&a]) {
		return (255*r);
	}
	return 255;
}

%new
+ (UIColor *)contrastBWColor:(UIColor *)aColor {
	if ( [self perceivedBrightness:aColor] > 130 ) {
		return [UIColor blackColor];
	} else {
		return [UIColor whiteColor];
	}
}

%new
+ (UIImage *)_imageWithColor:(UIColor *)color {
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

-(id)initWithFrame:(CGRect)arg1 {
	self = %orig;
	if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
		//NSLog(@"ChatBar init");
		UIColor* barBgColor = NAV_COLOR; //Eclipse Theme Color
		UIColor* barTopLineColor = [[self class] contrastBWColor:selectedTintColor()]; //Eclipse tint Color
		[self setImage:[[self class] _imageWithColor:barBgColor]];
		for(UIView* view in self.subviews){
			if([view isKindOfClass:[UIImageView class]]){
                [((UIImageView *)view) setImage:nil];
            }
		}
		UIImageView* topLineView = [[UIImageView alloc] initWithImage:[[self class] _imageWithColor:barTopLineColor]];
		[topLineView setTranslatesAutoresizingMaskIntoConstraints:NO];
		[self addSubview:topLineView];
		NSArray* constraintsDef = @[@{@"attribute": @(NSLayoutAttributeCenterX), @"multiplier": @1, @"constant": @0},
                                    @{@"attribute": @(NSLayoutAttributeTop), @"multiplier": @1, @"constant": @0},
                                    @{@"attribute": @(NSLayoutAttributeWidth), @"multiplier": @1, @"constant": @0},
                                    @{@"attribute": @(NSLayoutAttributeHeight), @"multiplier": @0, @"constant": @1}];
		for (NSDictionary* cDict in constraintsDef) {
			NSLayoutConstraint *myConstraint = [NSLayoutConstraint constraintWithItem:topLineView
                                                                            attribute:[cDict[@"attribute"] integerValue]
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self
                                                                            attribute:[cDict[@"attribute"] integerValue]
                                                  	 		               multiplier:[cDict[@"multiplier"] floatValue]
                                                                             constant:[cDict[@"constant"] floatValue]];
			myConstraint.priority = 700;
			[self addConstraint:myConstraint];
		}
		[self setNeedsUpdateConstraints];
		//NSLog(@"ChatBar init END");
	}
	return self;
}

%end

%hook TTTAttributedLabel

-(id)textColor {
    if (isEnabled) {
        return [UIColor darkGrayColor];
    }
    return %orig;
}

%end
%end

/*
 d888888b d88888b db      d88888b  d888b  d8888b.  .d8b.  .88b  d88.
 `~~88~~' 88'     88      88'     88' Y8b 88  `8D d8' `8b 88'YbdP`88
    88    88ooooo 88      88ooooo 88      88oobY' 88ooo88 88  88  88
    88    88~~~~~ 88      88~~~~~ 88  ooo 88`8b   88~~~88 88  88  88
    88    88.     88booo. 88.     88. ~8~ 88 `88. 88   88 88  88  88
    YP    Y88888P Y88888P Y88888P  Y888P  88   YD YP   YP YP  YP  YP
*/

%group TelegramApp

%hook TGBackdropView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:NAV_COLOR];
    }
}

%end

%hook TGContactCellContents

-(void)layoutSubviews {
    %orig;
    for (id meh in [self subviews]) {
        if ([meh respondsToSelector:@selector(setTextColor:)]) {
            [meh setTextColor:TEXT_COLOR];
        }
    }
}

%end

%end

/*
 d888888b db   d8b   db d88888b d88888b d888888b d8888b.  .d88b.  d888888b
 `~~88~~' 88   I8I   88 88'     88'     `~~88~~' 88  `8D .8P  Y8. `~~88~~'
    88    88   I8I   88 88ooooo 88ooooo    88    88oooY' 88    88    88
    88    Y8   I8I   88 88~~~~~ 88~~~~~    88    88~~~b. 88    88    88
    88    `8b d8'8b d8' 88.     88.        88    88   8D `8b  d8'    88
    YP     `8b8' `8d8'  Y88888P Y88888P    YP    Y8888P'  `Y88P'     YP
*/

%group TweetbotApp

%hook PTHTweetbotStatusView

-(void)viewDidLoad {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:TABLE_COLOR];
    }
}

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:TABLE_COLOR];
    }
}

- (void)_updateColors {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:TABLE_COLOR];
    }
}

%end

%hook PTHStaticSectionCell

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }
}

- (void)colorThemeDidChange {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }
}

%end

%hook PTHButton

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }
}

- (void)colorThemeDidChange {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }
}

%end

%end

/*
 d888888b db    db .88b  d88. d8888b. db      d8888b.
 `~~88~~' 88    88 88'YbdP`88 88  `8D 88      88  `8D
    88    88    88 88  88  88 88oooY' 88      88oobY'
    88    88    88 88  88  88 88~~~b. 88      88`8b
    88    88b  d88 88  88  88 88   8D 88booo. 88 `88.
    YP    ~Y8888P' YP  YP  YP Y8888P' Y88888P 88   YD
*/

%group TumblrApp

%hook TMAttributedTextView

- (void)setAttributedText:(id)arg1 frame:(struct __CTFrame *)arg2 {
    NSAttributedString* _attributedText = MSHookIvar<NSAttributedString*>(self, "_attributedText");



    %orig(_attributedText, arg2);
}

%end

%end





/*
  .d8888. d8b   db  .d8b.  d8888b.  .o88b. db   db  .d8b.  d888888b
  88'  YP 888o  88 d8' `8b 88  `8D d8P  Y8 88   88 d8' `8b `~~88~~'
 ` 8bo.   88V8o 88 88ooo88 88oodD' 8P      88ooo88 88ooo88    88
    `Y8b. 88 V8o88 88~~~88 88~~~   8b      88~~~88 88~~~88    88
  db   8D 88  V888 88   88 88      Y8b  d8 88   88 88   88    88
  `8888Y' VP   V8P YP   YP 88       `Y88P' YP   YP YP   YP    YP
*/



/*
%group SnapchatApp


%hook AVCameraViewController

- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    if (isEnabled) {
        UIView* _flashView = MSHookIvar<UIView*>(self, "_flashView");
        [_flashView setTag:VIEW_EXCLUDE_TAG];
    }

}

%end
*/

/*
%hook SCHeader

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {

        id _bottomBorderedView = MSHookIvar<id>(self, "_bottomBorderedView");
        [_bottomBorderedView setBackgroundColor:NAV_COLOR];
    }
}

%end
%end
 */

/*
 .d8888. d8b   db d8888b.  .o88b. db      d8888b.
 88'  YP 888o  88 88  `8D d8P  Y8 88      88  `8D
 `8bo.   88V8o 88 88   88 8P      88      88   88
   `Y8b. 88 V8o88 88   88 8b      88      88   88
 db   8D 88  V888 88  .8D Y8b  d8 88booo. 88  .8D
 `8888Y' VP   V8P Y8888D'  `Y88P' Y88888P Y8888D'
 */

%group SoundcloudApp

%hook SCTrackActivityMiniView

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        [self setBackgroundColor:VIEW_COLOR];
    }

}

%end



%end



/*
 d88888b  .d8b.   .o88b. d88888b d8888b. db   dD
 88'     d8' `8b d8P  Y8 88'     88  `8D 88 ,8P'
 88ooo   88ooo88 8P      88ooooo 88oooY' 88,8P
 88~~~   88~~~88 8b      88~~~~~ 88~~~b. 88`8b
 88      88   88 Y8b  d8 88.     88   8D 88 `88.
 YP      YP   YP  `Y88P' Y88888P Y8888P' YP   YD
*/


%group FBMessenger

%hook MNMaskedProfileImageView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {

        for (UIImageView* view in [self subviews]) {
            if ([view respondsToSelector:@selector(setImage:)]) {
                view.alpha = 0;
            }
        }

    }
}

%end

@interface MNThreadCollectionProfileImageView : UIView
@end

%hook MNThreadCollectionProfileImageView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {

        for (UIImageView* view in [self subviews]) {
            if ([view respondsToSelector:@selector(setImage:)]) {
                view.alpha = 0;
            }
        }

    }
}

%end

%hook MNProfileImageView
-(void)layoutSubviews {
    %orig;

    if (isEnabled) {
        NSMutableArray* _imageViews = MSHookIvar<NSMutableArray*>(self, "_imageViews");

        for (UIImageView* view in _imageViews) {
            view.layer.cornerRadius = view.frame.size.width / 2;
            view.clipsToBounds = YES;
            view.layer.borderWidth = 1.0f;
            view.layer.borderColor = selectedTintColor().CGColor;
        }
    }

}

%end

/*
%hook MNBadgedProfileImageView

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UIImageView* _maskImageView = MSHookIvar<UIImageView*>(self, "_maskImageView");
        [_maskImageView  setHidden:YES];

        UIImageView* _profileImageView = MSHookIvar<UIImageView*>(self, "_profileImageView");

        _profileImageView.layer.cornerRadius = _profileImageView.frame.size.width / 2;
        _profileImageView.clipsToBounds = YES;
        _profileImageView.layer.borderWidth = 1.0f;
        _profileImageView.layer.borderColor = selectedTintColor().CGColor;
    }
}

%end
*/

%hook MNGroupItemView

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UIImageView* _backgroundImageView = MSHookIvar<UIImageView*>(self, "_backgroundImageView");
        _backgroundImageView.image = nil;

        UIImageView* _groupImageMaskView = MSHookIvar<UIImageView*>(self, "_groupImageMaskView");
        _groupImageMaskView.image = nil;
    }
}


%end

%hook MNSettingsUserInfoCell

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UIImageView* _messengerBadge = MSHookIvar<UIImageView*>(self, "_messengerBadge");
        _messengerBadge.image = nil;

        UIImageView* _profilePhotoView = MSHookIvar<UIImageView*>(self, "_profilePhotoView");
        _profilePhotoView.layer.cornerRadius = _profilePhotoView.frame.size.width / 2;
        _profilePhotoView.clipsToBounds = YES;
        _profilePhotoView.layer.borderWidth = 1.0f;
        _profilePhotoView.layer.borderColor = selectedTintColor().CGColor;
    }
}

%end

%hook FBTextView

-(void)setFrame:(CGRect)arg1 {
    %orig;

    [self setTextColor:TEXT_COLOR];
}

%end

%hook MNPeopleCell

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        for (UIImageView* view in [[self contentView] subviews]) {
            if ([view respondsToSelector:@selector(setImage:)]) {

                view.layer.cornerRadius = view.frame.size.width / 2;
                view.clipsToBounds = YES;
                view.layer.borderWidth = 1.0f;
                view.layer.borderColor = selectedTintColor().CGColor;

            }
        }
    }

}

%end

%hook MNThreadCell

- (void)layoutSubviews {
    %orig;
    if (isEnabled) {
        UIImageView* _presenceIndicator = MSHookIvar<UIImageView*>(self, "_presenceIndicator");
        //_presenceIndicator.image = nil;

        _presenceIndicator.layer.cornerRadius = _presenceIndicator.frame.size.width / 2;
        _presenceIndicator.clipsToBounds = YES;
        _presenceIndicator.layer.borderWidth = 1.0f;
        _presenceIndicator.layer.borderColor = [UIColor clearColor].CGColor;
    }

}

%end

%end

/*
  _   _           _
 | |_(_)_ __   __| | ___ _ __
 | __| | '_ \ / _` |/ _ \ '__|
 | |_| | | | | (_| |  __/ |
  \__|_|_| |_|\__,_|\___|_|

*/

%group TinderApp

%hook TNDRChatViewController

- (void)viewWillAppear:(BOOL)arg1 {
    %orig;

     UIToolbar* _composeView = MSHookIvar<UIToolbar*>(self, "_composeView");

    for (UIImageView* image in [_composeView subviews]) {
        if ([image respondsToSelector:@selector(setImage:)]) {
            [image setAlpha:0.1];
        }
    }

}

%end

%hook TNDRChatBubbleCell

- (void)setupBackgroundImageView {
    %orig;

    UIImageView* _backgroundImageView = MSHookIvar<UIImageView*>(self, "_backgroundImageView");

    [_backgroundImageView setAlpha:0.2];

}

%end

%end

/*
    ____          _ _
   / ___|   _  __| (_) __ _
  | |  | | | |/ _` | |/ _` |
  | |__| |_| | (_| | | (_| |
   \____\__, |\__,_|_|\__,_|
        |___/
*/

%group CydiaApp

static NSString* cyCss = @"font-face { font-family: 'Chalkboard'; src: local('ChalkboardSE-Regular'); } body { background-color: none; color: #C7C7C7; font-family: Chalkboard;} a { color: #3E98BD; text-decoration: none;}";




static BOOL isPaidCydiaPackage;

%hook UIWebBrowserView

- (void)webView:(id)arg1 didFinishLoadForFrame:(id)arg2 {
    if (isEnabled) {
        [self setUserStyleSheet:cyCss];
    }
    %orig;
}


%end

%hook Package

- (bool) isCommercial {
    return %orig;
}

%end

%hook PackageCell

- (void) setPackage:(id)package asSummary:(bool)summary {

    isPaidCydiaPackage = (bool)[package isCommercial];

    %orig;
}

%end

%hook NSString

-(CGSize)drawAtPoint:(CGPoint)arg1 forWidth:(double)arg2 withFont:(id)arg3 lineBreakMode:(long long)arg4 {

   // if (isPaidCydiaPackage) {
     //   [selectedTintColor() set];
   // }
    //else {
        [TEXT_COLOR set];
    //}


    return %orig;
}
%end

%hook UISearchBarTextField

-(UIColor*)backgroundColor {
    if (isEnabled) {
        return VIEW_COLOR;
    }
    return %orig;
}

%end

%hook CyteViewController

- (void) setPageColor:(UIColor *)color {
    %orig([UIColor changeBrightness:VIEW_COLOR amount:1.4]);
}

%end
%end

/*
 __   __         _____      _
 \ \ / /__  _   |_   _|   _| |__   ___
  \ V / _ \| | | || || | | | '_ \ / _ \
   | | (_) | |_| || || |_| | |_) |  __/
   |_|\___/ \__,_||_| \__,_|_.__/ \___|
*/

//%group YouTubeApp

%hook YTFeedHeaderView

-(void)layoutSubviews {
    %orig;
    if (isEnabled) {
        for (UIImageView* imgView in [self subviews]) {
            imgView.alpha = 0.2;
        }
    }
}

%end

%hook YTFormattedStringLabel

-(void)setBounds:(CGRect)arg1 {
    %orig;

    if (isEnabled) {
        [self setTextColor:TEXT_COLOR];


    }
}

-(void)setFrame:(CGRect)arg1 {
    %orig;

    if (isEnabled) {
        [self setTextColor:TEXT_COLOR];


    }
}


- (void)didMoveToSuperview {

    %orig;

    if (isEnabled) {
        [self setTextColor:TEXT_COLOR];


    }

}




%end

//%end




/*
%hook XBApplicationSnapshot

%new
- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (id)cachedImageForInterfaceOrientation:(int)arg1 {
    return [self imageWithColor:VIEW_COLOR];
}

- (id)imageForInterfaceOrientation:(int)arg1 {
    return [self imageWithColor:VIEW_COLOR];
}

%end
 */




/*
 db    db d888888b  .d8b.  d8888b. d8888b.
 88    88   `88'   d8' `8b 88  `8D 88  `8D
 88    88    88    88ooo88 88oodD' 88oodD'
 88    88    88    88~~~88 88~~~   88~~~
 88b  d88   .88.   88   88 88      88
 ~Y8888P' Y888888P YP   YP 88      88
 */

#define idIsEqual(id) [[UIApplication displayIdentifier] isEqualToString:id]

static BOOL UniformityInstalled() {
    return [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Uniformity.dylib"];
}

@interface UIApplication(Eclipse)
+(id)displayIdentifier;
-(void)checkRunningApp;
@end

%group UIApp


%hook UIApplication


%new
-(void)checkRunningApp {

    //Third Party Application
    if (idIsEqual(@"us.mxms.relay")) {
        //%init(RelayApp);
    }
    if (idIsEqual(@"com.vine.iphone")) {
        //VineApp
    }
    if (idIsEqual(@"com.tumblr.tumblr")) {
        %init(TumblrApp);
    }
    if (idIsEqual(@"com.tapbots.Tweetbot3")) {
        %init(TweetbotApp);
    }
    if (idIsEqual(@"ph.telegra.Telegraph")) {
        %init(TelegramApp);
    }
    if (idIsEqual(@"com.kik.chat")) {
        %init(KikApp);
    }
    if (idIsEqual(@"com.atebits.Tweetie2")) {
        %init(TwitterApp);
    }
    if (idIsEqual(@"com.burbn.instagram")) {
        %init(InstagramApp);
    }
    if (idIsEqual(@"net.whatsapp.WhatsApp")) {
        %init(WhatsappApp);
    }
    //Added 6/4/14
    if (idIsEqual(@"com.toyopagroup.picaboo")) {
        //%init(SnapchatApp);
    }
    if (idIsEqual(@"com.soundcloud.TouchApp")) {
        %init(SoundcloudApp);
    }
    //Added 9/19/14
    if (idIsEqual(@"com.facebook.Messenger")) {
        %init(FBMessenger);
    }
    //Added 9/28
    if (idIsEqual(@"ch.threema.iapp")) {
        %init(ThreemaApp);
    }
    //Added 10/1
    if (idIsEqual(@"com.cardify.tinder")) {
        %init(TinderApp);
    }
    //Added 2/4/15
    if (idIsEqual(@"com.facebook.Facebook")) {
        isEnabled = NO;
    }


    //Stock Applications

    if (idIsEqual(@"com.apple.mobilephone")) {
        %init(PhoneApp);

        //dlopen("/Library/MobileSubstrate/DynamicLibraries/SleekPhone.dylib", RTLD_NOW);
    }
    if (idIsEqual(@"com.apple.mobilemail")) {
        %init(MailApp);
        shouldOverrideStatusBarStyle = YES;
    }
    if (idIsEqual(@"com.apple.mobilesafari")) {
        %init(SafariApp);
        shouldOverrideStatusBarStyle = YES;
    }
    if (idIsEqual(@"com.apple.Passbook")) {
        %init(PassbookApp);
    }
    if (idIsEqual(@"com.apple.reminders")) {
        %init(RemindersApp);
    }
    if (idIsEqual(@"com.apple.Music")) {
        %init(MusicApp);
    }
    if (idIsEqual(@"com.apple.mobilenotes")) {
        //isEnabled = NO;
        %init(NotesApp);
    }
    if (idIsEqual(@"com.apple.AppStore")) {
        %init(AppstoreApp);
    }
    if (idIsEqual(@"com.apple.mobilecal")) {
        %init(CalendarApp);
        %init(CalendarFix);
    }
    if (idIsEqual(@"com.apple.MobileAddressBook")) {
        %init(ContactsApp);
    }
    if (idIsEqual(@"com.apple.MobileStore")) {
        %init(MobileStoreApp);
    }
    if (idIsEqual(@"com.apple.calculator")) {
        isEnabled = NO;
    }
    if (idIsEqual(@"com.saurik.Cydia")) {
        %init(CydiaApp);
    }
    if (idIsEqual(@"com.apple.Bridge")) {
        %init(WatchApp);
    }
    if (idIsEqual(@"com.apple.Maps")) {
        %init(MapsApp);
    }


}

-(id)init {
    id hi = %orig;


    //Check if Application is on the blacklist
    BOOL applicationIsEnabledInSettings = [[prefs objectForKey:[@"EnabledApps-" stringByAppendingString:[UIApplication displayIdentifier]]] boolValue];

    BOOL shouldAutoReplaceColors = [[prefs objectForKey:[@"AutoColorReplacement-" stringByAppendingString:[UIApplication displayIdentifier]]] boolValue];

    //isEnabled = isTweakEnabled();

    isEnabled = applicationIsEnabledInSettings && isTweakEnabled();

    if (idIsEqual(@"com.apple.springboard")) {
        isEnabled = NO;
    }

    //If Tweak enabled:
    if (isEnabled) {

        %init(_ungrouped);
        //%init(musicTextDrawingView = objc_getClass("TtCVV5Music4Text7Drawing4View"));

        [self checkRunningApp];


        //Fix clock app crashing
        if (idIsEqual(@"com.apple.mobiletimer")) {
            isClockApp = YES;
        }
        else {
            isClockApp = NO;
        }

        darkenUIElements();

        if (shouldAutoReplaceColors && !idIsEqual(@"com.apple.Preferences")) {

            %init(AutoReplaceColor);
        }

        if (UniformityInstalled()) {
            dlopen("/Library/MobileSubstrate/DynamicLibraries/Uniformity.dylib", RTLD_NOW);
        }

    }


    return hi;
}


%end
%end


static BOOL noctisInstalled = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Noctis.dylib"];

%ctor {

    //Swift Classes

    //Music Text Header


	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	prefsChanged(NULL, NULL, NULL, NULL, NULL); // initialize prefs
	// register to receive changed notifications
	registerNotification(prefsChanged, PREFS_CHANGED_NOTIF);
    registerNotification(wallpaperChanged, WALLPAPER_CHANGED_NOTIF);
    registerNotification(quitAppsRequest, QUIT_APPS_NOTIF);
    %init(UIApp);

    if (!noctisInstalled) {
        %init(EclipseAlerts); //Noctis Support
    }


	[pool release];
}
