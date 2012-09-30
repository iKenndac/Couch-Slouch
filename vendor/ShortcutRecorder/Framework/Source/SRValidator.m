//
//  SRValidator.h
//  ShortcutRecorder
//
//  Copyright 2006-2011 Contributors. All rights reserved.
//
//  License: BSD
//
//  Contributors:
//      David Dauer
//      Jesper
//      Jamie Kirkpatrick
//      Andy Kim

#import "SRValidator.h"
#import "SRCommon.h"

@implementation SRValidator

//---------------------------------------------------------- 
// iinitWithDelegate:
//---------------------------------------------------------- 
- (id) initWithDelegate:(id)theDelegate;
{
    self = [super init];
    if ( !self )
        return nil;
    
    [self setDelegate:theDelegate];
    
    return self;
}

//---------------------------------------------------------- 
// isKeyCode:andFlagsTaken:error:
//---------------------------------------------------------- 
- (BOOL) isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags error:(NSError **)error;
{
	// Since we're recording shortcuts to replicate them later, it
	// doesn't matter if a shotcut is taken.
    return NO;
}

//---------------------------------------------------------- 
// isKeyCode:andFlags:takenInMenu:error:
//---------------------------------------------------------- 
- (BOOL) isKeyCode:(NSInteger)keyCode andFlags:(NSUInteger)flags takenInMenu:(NSMenu *)menu error:(NSError **)error;
{
    NSArray *menuItemsArray = [menu itemArray];
	NSEnumerator *menuItemsEnumerator = [menuItemsArray objectEnumerator];
	NSMenuItem *menuItem;
	NSUInteger menuItemModifierFlags;
	NSString *menuItemKeyEquivalent;
	
	BOOL menuItemCommandMod = NO, menuItemOptionMod = NO, menuItemShiftMod = NO, menuItemCtrlMod = NO;
	BOOL localCommandMod = NO, localOptionMod = NO, localShiftMod = NO, localCtrlMod = NO;
	
	// Prepare local carbon comparison flags
	if ( flags & cmdKey )       localCommandMod = YES;
	if ( flags & optionKey )    localOptionMod = YES;
	if ( flags & shiftKey )     localShiftMod = YES;
	if ( flags & controlKey )   localCtrlMod = YES;
	
	while (( menuItem = [menuItemsEnumerator nextObject] ))
	{
        // rescurse into all submenus...
		if ( [menuItem hasSubmenu] )
		{
			if ( [self isKeyCode:keyCode andFlags:flags takenInMenu:[menuItem submenu] error:error] ) 
			{
				return YES;
			}
		}
		
		if ( ( menuItemKeyEquivalent = [menuItem keyEquivalent] )
             && ( ![menuItemKeyEquivalent isEqualToString: @""] ) )
		{
			menuItemCommandMod = NO;
			menuItemOptionMod = NO;
			menuItemShiftMod = NO;
			menuItemCtrlMod = NO;
			
			menuItemModifierFlags = [menuItem keyEquivalentModifierMask];
            
			if ( menuItemModifierFlags & NSCommandKeyMask )     menuItemCommandMod = YES;
			if ( menuItemModifierFlags & NSAlternateKeyMask )   menuItemOptionMod = YES;
			if ( menuItemModifierFlags & NSShiftKeyMask )       menuItemShiftMod = YES;
			if ( menuItemModifierFlags & NSControlKeyMask )     menuItemCtrlMod = YES;
			
			NSString *localKeyString = SRStringForKeyCode( keyCode );
			
			// Compare translated keyCode and modifier flags
			if ( ( [[menuItemKeyEquivalent uppercaseString] isEqualToString: localKeyString] ) 
                 && ( menuItemCommandMod == localCommandMod ) 
                 && ( menuItemOptionMod == localOptionMod ) 
                 && ( menuItemShiftMod == localShiftMod ) 
                 && ( menuItemCtrlMod == localCtrlMod ) )
			{
                if ( error )
                {
                    NSString *description = [NSString stringWithFormat: 
                        SRLoc(@"The key combination %@ can't be used!"),
                        SRStringForCarbonModifierFlagsAndKeyCode( flags, keyCode )];
                    NSString *recoverySuggestion = [NSString stringWithFormat: 
                        SRLoc(@"The key combination \"%@\" can't be used because it's already used by the menu item \"%@\"."), 
                        SRReadableStringForCocoaModifierFlagsAndKeyCode( menuItemModifierFlags, keyCode ),
                        [menuItem title]];
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
											  description, NSLocalizedDescriptionKey,
											  recoverySuggestion, NSLocalizedRecoverySuggestionErrorKey,
											  [NSArray arrayWithObject:@"OK"], NSLocalizedRecoveryOptionsErrorKey,
											  nil];
                    *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
                }
				return YES;
			}
		}
	}
	return NO;    
}

#pragma mark -
#pragma mark accessors

//---------------------------------------------------------- 
//  delegate 
//---------------------------------------------------------- 
- (id) delegate
{
    return delegate; 
}

- (void) setDelegate: (id) theDelegate
{
    delegate = theDelegate; // Standard delegate pattern does not retain the delegate
}

@end

#pragma mark -
#pragma mark default delegate implementation

@implementation NSObject( SRValidation )

//---------------------------------------------------------- 
// shortcutValidator:isKeyCode:andFlagsTaken:reason:
//---------------------------------------------------------- 
- (BOOL) shortcutValidator:(SRValidator *)validator isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason;
{
    return NO;
}

@end
