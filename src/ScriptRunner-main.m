//
//  main.m
//  Couch Slouch Script Runner
//
//  Created by Daniel Kennett on 29/09/2013.
//  For license information, see LICENSE.markdown
//


#include <xpc/xpc.h>
#include <Foundation/Foundation.h>
#import "DKScriptRunnerXPCController.h"

int main(int argc, const char *argv[]) {

	DKScriptRunnerXPCController *controller = [DKScriptRunnerXPCController new];
    NSXPCListener *listener = [NSXPCListener serviceListener];

    listener.delegate = controller;
    [listener resume];

    // The resume method never returns.
    exit(EXIT_FAILURE);
}
