//
//  CircuitBreaker_AUAudioUnit.h
//  CircuitBreaker AU
//
//  Created by Robert Abernathy on 3/17/22.
//

#import <AudioToolbox/AudioToolbox.h>
#import "CircuitBreaker_AUDSPKernelAdapter.h"

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface CircuitBreaker_AUAudioUnit : AUAudioUnit

@property (nonatomic, readonly) CircuitBreaker_AUDSPKernelAdapter *kernelAdapter;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
