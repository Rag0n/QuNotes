// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Created by Luc Dion on 2017-07-17.

#import <UIKit/UIKit.h>

#import "UIView+Yoga.h"
#import "YGLayout+Private.h"

//! Project version number for FlexLayout.
FOUNDATION_EXPORT double FlexLayoutVersionNumber;

//! Project version string for FlexLayout.
FOUNDATION_EXPORT const unsigned char FlexLayoutVersionString[];

// In this header, you should import all the public headers of your framework using
#if defined(XCODE_PROJECT_BUILD) || defined(FLEXLAYOUT_USE_CARTHAGE) || defined(USE_YOGAKIT_PACKAGE)
    #import <YogaKit/Yoga.h>
    #import <YogaKit/YGEnums.h>
    #import <YogaKit/YGNodeList.h>
    #import <YogaKit/YGMacros.h>
#else
    #import <Yoga/Yoga.h>
    #import <Yoga/YGEnums.h>
    #import <Yoga/YGNodeList.h>
#import <Yoga/YGMacros.h>
#endif




