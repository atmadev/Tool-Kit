//
//  TKConstants.h
//  Tool Kit
//
//  Created by Alexander Koryttsev on 3/5/14.
//  Copyright (c) 2014 Alexander Koryttsev. All rights reserved.
//




#pragma mark - Property Keys

FOUNDATION_EXPORT NSString *const kIDKey;


FOUNDATION_EXPORT NSString * const TKHTTPMethodGET;
FOUNDATION_EXPORT NSString * const TKHTTPMethodPOST;
FOUNDATION_EXPORT NSString * const TKHTTPMethodPUT;
typedef NSString * TKHTTPMethodType;

#pragma mark -


typedef enum {
    TKNetworkStatusOffline = 0,
    TKNetworkStatus3G,
    TKNetworkStatusWiFi
}   TKNetworkStatus;


typedef enum {
    TKErrorActionNone = 0,
    TKErrorActionTooltip,
    TKErrorActionAlert,
    TKErrorActionLogout,
    TKErrorActionRetrieveDataOrLogout,
    TKErrorActionSignInWithExistingEmail
}   TKErrorAction;

#pragma mark - Error Codes

typedef enum {
    TKServerErrorContinue                          = 100,
    TKServerErrorSwitchingProtocols                = 101,
    TKServerErrorOK                                = 200,
    TKServerErrorCreated                           = 201,
    TKServerErrorAccepted                          = 202,
    TKServerErrorNonAuthoritativeInfo              = 203,
    TKServerErrorNoContent                         = 204,
    TKServerErrorResetContent                      = 205,
    TKServerErrorPartialContent                    = 206,
    TKServerErrorMultipleChoices                   = 300,
    TKServerErrorMovedPermanently                  = 301,
    TKServerErrorFound                             = 302,
    TKServerErrorSeeOther                          = 303,
    TKServerErrorNotModified                       = 304,
    TKServerErrorUseProxy                          = 305,
    TKServerErrorUnused                            = 306,
    TKServerErrorTempraryRedirect                  = 307,
    TKServerErrorBadRequest                        = 400,
    TKServerErrorUnauthorized                      = 401,
    TKServerErrorPaymentRequired                   = 402,
    TKServerErrorForbidden                         = 403,
    TKServerErrorNotFound                          = 404,
    TKServerErrorMethodNotAllowed                  = 405,
    TKServerErrorNotAcceptable                     = 406,
    TKServerErrorProxyAuthenticationRequired       = 407,
    TKServerErrorRequestTimeout                    = 408,
    TKServerErrorConflict                          = 409,
    TKServerErrorGone                              = 410,
    TKServerErrorLengthRequired                    = 411,
    TKServerErrorPreconditionFailed                = 412,
    TKServerErrorRequestEntityTooLarge             = 413,
    TKServerErrorRequestURITooLong                 = 414,
    TKServerErrorUnsupportedMediaType              = 415,
    TKServerErrorRequestedRangeNotSatisfiable      = 416,
    TKServerErrorExpectationFailed                 = 417,
    TKServerErrorBadRequestParameters              = 418,
    TKServerErrorInternal                          = 500,
    TKServerErrorNotImplemented                    = 501,
    TKServerErrorBadGateway                        = 502,
    TKServerErrorServiceUnavailable                = 503,
    TKServerErrorGatewayTimeout                    = 504,
    TKServerErrorHTTPVersionNotSupported           = 505,
    TKServerErrorDB                                = 1000,
    
    TKNetworkErrorNoConnection                     = -10000,
    TKNetworkErrorServerIsUnreachable              = -10001,
    TKLocalErrorFailedToParseResponce              = -10002,
    TKLocalErrorRaisedException                    = -10003,
    TKLocalErrorUnableToSerializeObject            = -10004
}   TKErrorCode;
