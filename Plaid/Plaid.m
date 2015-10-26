//
//  Plaid.m
//  Plaid
//
//  Created by Simon Levy on 9/26/15.
//  Copyright © 2015 Vouch Financial, Inc. All rights reserved.
//

#import "Plaid.h"

#import "PLDNetworkApi.h"

static Plaid *sInstance = nil;

@implementation Plaid {
  NSString *_clientId;
  PlaidEnvironment _environment;
  NSString *_secret;

  PLDNetworkApi *_networkApi;
}
@synthesize environment = _environment;

+ (Plaid *)sharedInstance {
  if (!sInstance) {
    sInstance = [[Plaid alloc] initWithEnvironment:PlaidEnvironmentTartan];
  }
  return sInstance;
}

- (void)setEnvironment:(PlaidEnvironment)environment {
  if (_environment != environment) {
    _networkApi = [[PLDNetworkApi alloc] initWithEnvironment:environment];
  }
  _environment = environment;
}

- (instancetype)initWithEnvironment:(PlaidEnvironment)environment {
  if (self = [super init]) {
    _networkApi = [[PLDNetworkApi alloc] initWithEnvironment:environment];
    _environment = environment;
  }
  return self;
}

- (void)setClientId:(NSString *)clientId secret:(NSString *)secret {
  NSAssert(clientId.length > 0 && secret.length > 0, @"Must set both clientId and secret");

  _clientId = clientId;
  _secret = secret;
}

#pragma mark - Auth Product

- (void)addAuthUserWithUsername:(NSString *)username
                       password:(NSString *)password
                           type:(NSString *)type
                        options:(NSDictionary *)options
                     completion:(PlaidMfaCompletion)completion {
  [self addUserForProduct:PlaidProductAuth
                 username:username
                 password:password
                     type:type
                  options:options
               completion:[self authMfaCompletion:completion]];
}

- (void)getAuthUserWithAccessToken:(NSString *)accessToken
                        completion:(PlaidCompletion)completion {
  [self getUserForProduct:PlaidProductAuth
              accessToken:accessToken
                  options:nil
               completion:[self connectCompletion:completion]];
}

- (void)stepAuthUserWithAccessToken:(NSString *)accessToken
                        mfaResponse:(id)mfaResponse
                            options:(NSDictionary *)options
                         completion:(PlaidMfaCompletion)completion {
  [self stepUserForProduct:PlaidProductAuth
               accessToken:accessToken
               mfaResponse:mfaResponse
                   options:options
                completion:[self authMfaCompletion:completion]];
}

- (void)patchAuthUserWithAccessToken:(NSString *)accessToken
                            username:(NSString *)username
                            password:(NSString *)password
                          completion:(PlaidMfaCompletion)completion {
  [self patchUserForProduct:PlaidProductAuth
                accessToken:accessToken
                   username:username
                   password:password
                 completion:[self authMfaCompletion:completion]];
}

- (void)deleteAuthUserWithAccessToken:(NSString *)accessToken
                           completion:(PlaidCompletion)completion {
  [self deleteUserForProduct:PlaidProductAuth
                 accessToken:accessToken
                  completion:completion];
}

#pragma mark - Connect Product

- (void)addConnectUserWithUsername:(NSString *)username
                          password:(NSString *)password
                              type:(NSString *)type
                           options:(NSDictionary *)options
                        completion:(PlaidMfaCompletion)completion {
  [self addUserForProduct:PlaidProductConnect
                 username:username
                 password:password
                     type:type
                  options:options
               completion:[self connectMfaCompletion:completion]];
}

- (void)getConnectUserWithAccessToken:(NSString *)accessToken
                              options:(NSDictionary *)options
                           completion:(PlaidCompletion)completion {
  [self getUserForProduct:PlaidProductConnect
              accessToken:accessToken
                  options:options
               completion:[self connectCompletion:completion]];
}

- (void)stepConnectUserWithAccessToken:(NSString *)accessToken
                           mfaResponse:(id)mfaResponse
                               options:(NSDictionary *)options
                            completion:(PlaidMfaCompletion)completion {
  [self stepUserForProduct:PlaidProductConnect
               accessToken:accessToken
               mfaResponse:mfaResponse
                   options:options
                completion:[self connectMfaCompletion:completion]];
}

- (void)patchConnectUserWithAccessToken:(NSString *)accessToken
                               username:(NSString *)username
                               password:(NSString *)password
                             completion:(PlaidMfaCompletion)completion {
  [self patchUserForProduct:PlaidProductConnect
                accessToken:accessToken
                   username:username
                   password:password
                 completion:[self connectMfaCompletion:completion]];
}

- (void)deleteConnectUserWithAccessToken:(NSString *)accessToken
                               completion:(PlaidCompletion)completion {
  [self deleteUserForProduct:PlaidProductConnect
                 accessToken:accessToken
                  completion:completion];
}

#pragma mark - Generic endpoints

- (void)getCategoryByCategoryId:(NSString *)categoryId
                     completion:(PlaidCompletion)completion {
  NSString *path = [NSString stringWithFormat:@"categories/%@", categoryId];
  [_networkApi executeRequestWithPath:path
                               method:@"GET"
                           parameters:nil
                           completion:^(NSDictionary *response, NSError *error) {
                             if (error) {
                               completion(nil, error);
                               return;
                             }

                             PLDCategory *category =
                                [[PLDCategory alloc] initWithCategoryDictionary:response];
                             completion(category, nil);
                           }];
}

- (void)getCategoriesWithCompletion:(PlaidCompletion)completion {
  [_networkApi executeRequestWithPath:@"categories"
                               method:@"GET"
                           parameters:nil
                           completion:^(NSDictionary *response, NSError *error) {
                             NSMutableArray *categories =
                                 [NSMutableArray arrayWithCapacity:response.count];
                             for (NSDictionary *category in response) {
                               PLDCategory *obj =
                                  [[PLDCategory alloc] initWithCategoryDictionary:category];
                               [categories addObject:obj];
                             }
                             completion(response, error);
                           }];
}

- (void)getInstitutionById:(NSString *)institutionId
                completion:(PlaidCompletion)completion {
  NSString *path = [NSString stringWithFormat:@"institutions/%@", institutionId];
  [_networkApi executeRequestWithPath:path
                               method:@"GET"
                           parameters:nil
                           completion:^(NSDictionary *response, NSError *error) {
                             if (error) {
                               completion(nil, error);
                               return;
                             }
                             PLDInstitution *institution = [[PLDInstitution alloc] initWithDictionary:response];
                             completion(institution, nil);
                           }];
}

- (void)getInstitutionsWithCompletion:(PlaidCompletion)completion {
  [_networkApi executeRequestWithPath:@"institutions"
                               method:@"GET"
                           parameters:nil
                           completion:^(NSArray *response, NSError *error) {
                             NSMutableArray *objects = [NSMutableArray arrayWithCapacity:response.count];
                             for (NSDictionary *institution in response) {
                               [objects addObject:[[PLDInstitution alloc] initWithDictionary:institution]];
                             }
                             completion(objects, error);
                           }];
}

- (void)exchangePublicToken:(NSString *)publicToken completion:(PlaidCompletion)completion {
  NSDictionary *parameters = @{
    @"public_token" : publicToken,
  };
  [_networkApi executeRequestWithPath:@"exchange_token"
                               method:@"POST"
                           parameters:[self authenticatedParametersWithDictionary:parameters]
                           completion:^(NSDictionary *response, NSError *error) {
                             completion(response, error);
                           }];
}

- (void)getBalanceWithAccessToken:(NSString *)accessToken
                       completion:(PlaidCompletion)completion {
  NSDictionary *parameters = @{
    @"access_token" : accessToken,
  };
  [_networkApi executeRequestWithPath:@"balance"
                               method:@"POST"
                           parameters:[self authenticatedParametersWithDictionary:parameters]
                           completion:^(NSDictionary *response, NSError *error) {
                             completion(response, error);
                           }];
}

- (void)upgradeUserWithAccessToken:(NSString *)accessToken
                         upgradeTo:(PlaidProduct)upgradeTo
                        completion:(PlaidMfaCompletion)completion {
  NSDictionary *parameters = @{
    @"access_token" : accessToken,
    @"upgrade_to" : NSStringFromPlaidProduct(upgradeTo)
  };
  [_networkApi executeRequestWithPath:@"upgrade"
                               method:@"POST"
                           parameters:[self authenticatedParametersWithDictionary:parameters]
                           completion:^(NSDictionary *response, NSError *error) {
                             if (response && [response objectForKey:@"mfa"]) {
                               completion(nil, response, error);
                               return;
                             }
                             PLDAuthentication *authentication =
                                 [[PLDAuthentication alloc] initWithProduct:upgradeTo
                                                                   response:response];
                             completion(authentication, nil, error);
                           }];
}

#pragma mark - Private

- (PlaidMfaCompletion)authMfaCompletion:(PlaidMfaCompletion)completion {
  return ^(PLDAuthentication *authentication, id response, NSError *error) {
    if (error) {
      completion(nil, response, error);
      return;
    }

    PLDAuthResponse *authResponse =
        [[PLDAuthResponse alloc] initWithResponse:response];
    completion(authentication, authResponse, error);
  };
}

- (PlaidMfaCompletion)connectMfaCompletion:(PlaidMfaCompletion)completion {
  return ^(PLDAuthentication *authentication, id response, NSError *error) {
    if (error) {
      completion(nil, response, error);
      return;
    }

    PLDConnectResponse *connectResponse =
        [[PLDConnectResponse alloc] initWithResponse:response];
    completion(authentication, connectResponse, error);
  };
}

- (PlaidCompletion)authCompletion:(PlaidCompletion)completion {
  return ^(id response, NSError *error) {
    if (error) {
      completion(nil, error);
      return;
    }

    PLDAuthResponse *authResponse =
        [[PLDAuthResponse alloc] initWithResponse:response];
    completion(authResponse, nil);
  };
}

- (PlaidCompletion)connectCompletion:(PlaidCompletion)completion {
  return ^(id response, NSError *error) {
    if (error) {
      completion(nil, error);
      return;
    }

    PLDConnectResponse *connectResponse =
        [[PLDConnectResponse alloc] initWithResponse:response];
    completion(connectResponse, nil);
  };
}

- (void)addUserForProduct:(PlaidProduct)product
                 username:(NSString *)username
                 password:(NSString *)password
                     type:(NSString *)type
                  options:(NSDictionary *)options
               completion:(PlaidMfaCompletion)completion {
  NSAssert([NSStringFromPlaidProduct(product) length] > 0, @"Missing product");

  if (!options) {
    options = @{};
  }
  NSDictionary *parameters = @{
    @"credentials" : @{
      @"username" : username,
      @"password" : password
    },
    @"type" : type,
    @"options" : options
  };
  [_networkApi executeRequestWithPath:NSStringFromPlaidProduct(product)
                               method:@"POST"
                           parameters:[self authenticatedParametersWithDictionary:parameters]
                           completion:^(NSDictionary *response, NSError *error) {
                             if (error) {
                               completion(nil, response, error);
                               return;
                             }
                             
                             PLDAuthentication *authentication =
                                 [[PLDAuthentication alloc] initWithProduct:product
                                                                   response:response];
                             completion(authentication, nil, error);
                           }];
}

- (void)getUserForProduct:(PlaidProduct)product
              accessToken:(NSString *)accessToken
                  options:(NSDictionary *)options
               completion:(PlaidCompletion)completion {
  NSAssert([NSStringFromPlaidProduct(product) length] > 0, @"Missing product");
  
  if (!options) {
    options = @{};
  }
  NSDictionary *parameters = @{
    @"access_token" : accessToken,
    @"options" : options
  };
  NSString *path = [NSString stringWithFormat:@"%@/get", NSStringFromPlaidProduct(product)];
  [_networkApi executeRequestWithPath:path
                               method:@"POST"
                           parameters:[self authenticatedParametersWithDictionary:parameters]
                           completion:^(NSDictionary *response, NSError *error) {
                             completion(response, error);
                           }];
}

- (void)stepUserForProduct:(PlaidProduct)product
               accessToken:(NSString *)accessToken
               mfaResponse:(id)mfaResponse
                   options:(NSDictionary *)options
                completion:(PlaidMfaCompletion)completion {
  NSAssert([NSStringFromPlaidProduct(product) length] > 0, @"Missing product");
  
  if (!options) {
    options = @{};
  }
  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
    @"access_token" : accessToken,
    @"options" : options
  }];
  if (mfaResponse) {
    parameters[@"mfa"] = mfaResponse;
  }
  NSString *path = [NSString stringWithFormat:@"%@/step", NSStringFromPlaidProduct(product)];
  [_networkApi executeRequestWithPath:path
                               method:@"POST"
                           parameters:[self authenticatedParametersWithDictionary:parameters]
                           completion:^(NSDictionary *response, NSError *error) {
                             if (error) {
                               completion(nil, response, error);
                               return;
                             }

                             PLDAuthentication *authentication =
                                 [[PLDAuthentication alloc] initWithProduct:product
                                                                   response:response];
                             completion(authentication, nil, error);
                           }];
}

- (void)patchUserForProduct:(PlaidProduct)product
                accessToken:(NSString *)accessToken
                   username:(NSString *)username
                   password:(NSString *)password
                 completion:(PlaidMfaCompletion)completion {
  NSAssert([NSStringFromPlaidProduct(product) length] > 0, @"Missing product");

  NSDictionary *parameters = @{
    @"access_token" : accessToken,
    @"credentials" : @{
      @"username" : username,
      @"password" : password
    }
  };
  [_networkApi executeRequestWithPath:NSStringFromPlaidProduct(product)
                               method:@"PATCH"
                           parameters:[self authenticatedParametersWithDictionary:parameters]
                           completion:^(NSDictionary *response, NSError *error) {
                             if (error) {
                               completion(nil, response, error);
                               return;
                             }

                             PLDAuthentication *authentication =
                                 [[PLDAuthentication alloc] initWithProduct:product
                                                                   response:response];
                             completion(authentication, nil, error);
                           }];
}

- (void)deleteUserForProduct:(PlaidProduct)product
                 accessToken:(NSString *)accessToken
                  completion:(PlaidCompletion)completion {
  NSAssert([NSStringFromPlaidProduct(product) length] > 0, @"Missing product");

  NSDictionary *parameters = @{
    @"access_token" : accessToken
  };
  [_networkApi executeRequestWithPath:NSStringFromPlaidProduct(product)
                               method:@"DELETE"
                           parameters:[self authenticatedParametersWithDictionary:parameters]
                           completion:^(NSDictionary *response, NSError *error) {
                             completion(response, error);
                           }];
}

- (NSDictionary *)authenticatedParametersWithDictionary:(NSDictionary *)dictionary {
  NSAssert(_clientId.length > 0, @"Missing client id");
  NSAssert(_secret.length > 0, @"Missing secret");

  NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:dictionary];
  parameters[@"client_id"] = _clientId;
  parameters[@"secret"] = _secret;
  return parameters;
}

@end