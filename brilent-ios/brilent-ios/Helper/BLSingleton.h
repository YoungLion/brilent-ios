//
//  BLSingleton.h
//  brilent-ios
//
//  Created by Yong Lin on 8/28/13.
//  Copyright (c) 2013 brilent. All rights reserved.
//

#ifndef brilent_ios_BLSingleton_h
#define brilent_ios_BLSingleton_h

#define BL_SYNTHESIZE_SINGLETON(classname,accessorMethod,initializerBlock)                   \
                                                                                             \
    + (classname *)accessorMethod                                                            \
    {                                                                                        \
        static classname *sSharedInstance = nil;                                             \
        static dispatch_once_t pred;                                                         \
        dispatch_once(&pred, ^{                                                              \
                          sSharedInstance = [self alloc];                                    \
                          sSharedInstance = (classname *)initializerBlock (sSharedInstance); \
                      }                                                                      \
                      );                                                                     \
        return sSharedInstance;                                                              \
    }

#endif
