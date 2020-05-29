/*
 ____          _ _
 / ___| _  __| (_) __ _
 | |  | | | |/ _` | |/ _` |
 | |__| |_| | (_| | | (_| |
 \____\__, |\__,_|_|\__,_|
 |		___/
 */

extern "C" void UISetColor(CGColorRef color);

%group CydiaApp

// static NSString* cyJS = @"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'white'; document.getElementsByTagName('html')[0].style.backgroundColor= 'transparent'; var x = document.getElementsByTagName('fieldset'); var i; for (i = 0; i < x.length; i++) { x[i].style.backgroundColor = 'transparent'; };";

static BOOL isPaidCydiaPackage;

%hook _UIBarBackground

-(void)layoutSubviews {
	%orig;
	if (isEnabled) {
		[self setBackgroundColor: NAV_COLOR];
	}
}

%end

%hook UILabel 

-(void)layoutSubviews {
	%orig;
	if (isEnabled) {
		[self setTextColor: TEXT_COLOR];
	}
}

-(UIColor*)textColor {
	if (isEnabled) {
		return TEXT_COLOR;
	}
	return %orig;
}

-(void)setTextColor:(UIColor*)color {
	if (isEnabled) {
		%orig(TEXT_COLOR);
	}
	return %orig;
}

%end

%hook UIWebScrollView

-(id)init {
	id x = %orig;
	[self setBackgroundColor: VIEW_COLOR];
	return x;
}

-(void)layoutSubviews {
	%orig;
	if (isEnabled) {
		[self setBackgroundColor: VIEW_COLOR];
	}
}

%end

%hook CyteTableViewCellContentView

-(void)setFrame:(CGRect)frame {
	%orig;
	[self setBackgroundColor: VIEW_COLOR];
}

-(void)layoutSubviews {
	%orig;
	if (isEnabled) {
		[self setBackgroundColor: TABLE_COLOR];
	}
}

-(id)backgroundColor {
	if (isEnabled) {
		return TABLE_COLOR;
	}
	return %orig;
}

%end

%hook CyteWebView

- (void)webView:(id)arg1 didFinishLoadForFrame:(id)arg2 {
	%orig;
	if (isEnabled) {
		//[self.view setBackgroundColor:[UIColor blackColor]];
		NSString *setJavaScript = darkCydiaJS;
		[arg1 stringByEvaluatingJavaScriptFromString:setJavaScript];
		//[readerWebView setBackgroundColor:[UIColor blackColor]]; // doesn't solve it
		// [self.scrollView setBackgroundColor:[UIColor blackColor]];
		[self setBackgroundColor: VIEW_COLOR];
	}
}

-(void)layoutSubviews {
	%orig;
}


%end

%hook _UITableViewCellHeaderFooterContentView

-(void)setFrame:(CGRect)frame {
	%orig;
	if (isEnabled) {
		[self setBackgroundColor: VIEW_COLOR];
	}
}

%end

%hook UITableViewIndex

-(void)layoutSubviews {
	%orig;
	if (isEnabled) {
		[self setBackgroundColor: [UIColor clearColor]];
	}
}

%end

%hook PackageCell

- (void) setPackage:(id)package asSummary:(bool)summary {
	isPaidCydiaPackage = (bool)[package isCommercial];
	%orig;
}

%end

%hook NSString

// -(CGSize)drawAtPoint:(CGPoint)arg1 forWidth:(double)arg2 withFont:(id)arg3 lineBreakMode:(long long)arg4 {

// 	// if (isPaidCydiaPackage) {
// 	//   [selectedTintColor() set];
// 	// }
// 	//else {
// 	if (isEnabled) {
// 		[TEXT_COLOR set];
// 	}

// 	//}


// 	return %orig;
// }

%end

%hook UISearchBarTextField

-(UIColor*)backgroundColor {
	if (isEnabled) {
		return VIEW_COLOR;
	}
	return %orig;
}

-(void)layoutSubviews {
	%orig;
	if (isEnabled) {
		[self setTextColor: TEXT_COLOR];
	}
}

%end


%end
