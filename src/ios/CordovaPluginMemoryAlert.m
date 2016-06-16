/*
 * Copyright 2016 Wizcorp
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Cordova/CDV.h>
#import "CordovaPluginMemoryAlert.h"

@implementation CordovaPluginMemoryAlert

- (void)pluginInitialize
{
    activated = FALSE;
    memoryWarningEventName = @"cordova-plugin-memory-alert.memoryWarning";
    escapedMemoryWarningEventName = [memoryWarningEventName stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
}

- (void)activate:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    activated = [[command argumentAtIndex:0] boolValue];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    NSLog(@"cordova-plugin-memory-alert: %@", activated ? @"activated" : @"disabled");
}

- (void)setEventName:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString *eventName = [command.arguments objectAtIndex:0];

    if (eventName != nil && [eventName length] > 0) {
        memoryWarningEventName = eventName;
        escapedMemoryWarningEventName = [memoryWarningEventName stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        NSLog(@"cordova-plugin-memory-alert: setting event name to %@", memoryWarningEventName);
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        NSLog(@"cordova-plugin-memory-alert: unable to set event name");
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)onMemoryWarning
{
    if (!activated) return;
    NSString *jsCommand = [@[@"cordova.fireWindowEvent('", escapedMemoryWarningEventName, @"');"] componentsJoinedByString:@""];
    [self.commandDelegate evalJs:jsCommand];
    NSLog(@"cordova-plugin-memory-alert: did received a memory warning, emitting `%@` on window", memoryWarningEventName);
}

@end
