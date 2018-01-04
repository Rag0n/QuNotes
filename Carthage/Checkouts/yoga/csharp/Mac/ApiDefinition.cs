﻿/**
 * Copyright (c) 2014-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

using System;

using AppKit;
using Foundation;
using ObjCRuntime;
using CoreGraphics;

namespace Facebook.Yoga.Mac
{
    // Xamarin.Mac binding projects allow you to include native libraries inside C# DLLs for easy consumption
    // later. However, the binding project build files currently assume you are binding some objective-c API
    // and that you need an ApiDefinition.cs for that. yoga is all C APIs, so just include this "blank" file so
    // the dylib gets packaged
}
