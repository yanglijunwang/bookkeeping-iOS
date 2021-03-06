//
//  ASAbsoluteLayoutSpec.h
//  Texture
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the /ASDK-Licenses directory of this source tree. An additional
//  grant of patent rights can be found in the PATENTS file in the same directory.
//
//  Modifications to this file made after 4/13/2017 are: Copyright (c) 2017-present,
//  Pinterest, Inc.  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <AsyncDisplayKit/ASLayoutSpec.h>

/** How much space the spec will take up. */
typedef NS_ENUM(NSInteger, ASAbsoluteLayoutSpecSizing) {
  /** The spec will take up the maximum size possible. */
  ASAbsoluteLayoutSpecSizingDefault,
  /** Computes a size for the spec that is the union of all childrens' frames. */
  ASAbsoluteLayoutSpecSizingSizeToFit,
};

NS_ASSUME_NONNULL_BEGIN

/**
 A layout spec that positions children at fixed positions.
 */
@interface ASAbsoluteLayoutSpec : ASLayoutSpec

/**
 How much space will the spec taken up
 */
@property (nonatomic) ASAbsoluteLayoutSpecSizing sizing;

/**
 @param sizing How much space the spec will take up
 @param children Children to be positioned at fixed positions
 */
+ (instancetype)absoluteLayoutSpecWithSizing:(ASAbsoluteLayoutSpecSizing)sizing children:(NSArray<id<ASLayoutElement>> *)children NS_RETURNS_RETAINED AS_WARN_UNUSED_RESULT;

/**
 @param children Children to be positioned at fixed positions
 */
+ (instancetype)absoluteLayoutSpecWithChildren:(NSArray<id<ASLayoutElement>> *)children NS_RETURNS_RETAINED AS_WARN_UNUSED_RESULT;

@end

NS_ASSUME_NONNULL_END
