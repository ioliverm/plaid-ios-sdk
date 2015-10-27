//
//  PLDDefines.h
//  Plaid
//
//  Created by Simon Levy on 9/30/15.
//  Copyright © 2015 Vouch Financial, Inc. All rights reserved.
//

typedef NS_ENUM(NSUInteger, PlaidEnvironment) {
  PlaidEnvironmentTartan,
  PlaidEnvironmentProduction
};

typedef NS_ENUM(NSUInteger, PlaidProduct) {
  PlaidProductUnknown = 0,
  PlaidProductAuth,
  PlaidProductConnect
};

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
static NSString * NSStringFromPlaidProduct(PlaidProduct product) {
  switch (product) {
    case PlaidProductAuth:
      return @"auth";
    case PlaidProductConnect:
      return @"connect";
    case PlaidProductUnknown:
    default:
      break;
  }
  return nil;
}

static PlaidProduct PlaidProductFromNSString(NSString *string) {
  if ([string isEqualToString:@"auth"]) {
    return PlaidProductAuth;
  } else if ([string isEqualToString:@"connect"]) {
    return PlaidProductConnect;
  }
  return PlaidProductUnknown;
}
#pragma clang diagnostic pop
