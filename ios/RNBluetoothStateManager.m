
#import <CoreBluetooth/CoreBluetooth.h>
#import "RNBluetoothStateManager.h"

@implementation RNBluetoothStateManager{
  CBCentralManager *cb;
  bool hasListeners;
}

// Override
-(void)startObserving {
  hasListeners = YES;
}

// Override
-(void)stopObserving {
  hasListeners = NO;
}

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

-(instancetype)init{
  self = [super init];
//  if(self){
//    NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey: @NO};
//
//    cb = [[CBCentralManager alloc] initWithDelegate:nil queue:nil options:options];
//    [cb setDelegate:self];
//  }
  return self;
}

RCT_EXPORT_METHOD(setup:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  [self setupBluetooth];
  resolve(nil);
}

NSString *const EVENT_BLUETOOTH_STATE_CHANGE = @"EVENT_BLUETOOTH_STATE_CHANGE";

- (NSDictionary<NSString *, NSString *> *)constantsToExport {
    return @{EVENT_BLUETOOTH_STATE_CHANGE: EVENT_BLUETOOTH_STATE_CHANGE};
}

- (NSArray<NSString *> *)supportedEvents {
  return @[EVENT_BLUETOOTH_STATE_CHANGE];
}

// ----------------------------------------------------------------------------------------------- -
// BLUETOOTH STATE

RCT_EXPORT_METHOD(getState:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  [self setupBluetooth];
  NSString *stateName = [self bluetoothStateToString:cb.state];
  resolve(stateName);
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
  [self setupBluetooth];
  NSString *stateName = [self bluetoothStateToString:central.state];
  [self sendEventBluetoothStateChange:stateName];
}

// ----------------------------------------------------------------------------------------------- -
// OPEN SETTINGS

RCT_EXPORT_METHOD(openSettings:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  if(&UIApplicationOpenSettingsURLString != nil){
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
  }
  resolve(nil);
}

// ----------------------------------------------------------------------------------------------- -
// NOT AVAILABLE IN iOS

RCT_EXPORT_METHOD(enable:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSError* error = nil;
  reject(@"UNSUPPORTED", @"Not implemented in iOS", error);
}

RCT_EXPORT_METHOD(disable:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSError* error = nil;
  reject(@"UNSUPPORTED", @"Not implemented in iOS", error);
}

RCT_EXPORT_METHOD(requestToEnable:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSError* error = nil;
  reject(@"UNSUPPORTED", @"Not implemented in iOS", error);
}

// ----------------------------------------------------------------------------------------------- -
// HELPERS

- (void)sendEventBluetoothStateChange:(NSString*)stateName {
  if (hasListeners) {
    [self sendEventWithName:EVENT_BLUETOOTH_STATE_CHANGE body:stateName];
  }
}

- (NSString*)bluetoothStateToString:(CBManagerState)state {
  switch (state)
  {
    case CBManagerStatePoweredOn:
      return @"PoweredOn";
    case CBManagerStatePoweredOff:
      return @"PoweredOff";
    case CBManagerStateResetting:
      return @"Resetting";
    case CBManagerStateUnsupported:
      return @"Unsupported";
    case CBManagerStateUnauthorized:
      return @"Unauthorized";
    case CBManagerStateUnknown:
    default:
      return @"Unknown";
  }
}

- (void)setupBluetooth {
    if(self.isSetup){
        return;
    }
    NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey: @YES};

    cb = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    [cb setDelegate:self];

    self.isSetup = true;
}


@end

