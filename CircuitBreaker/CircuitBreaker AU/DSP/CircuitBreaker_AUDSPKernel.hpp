//
//  CircuitBreaker_AUDSPKernel.hpp
//  CircuitBreaker AU
//
//  Created by Robert Abernathy on 3/17/22.
//

#ifndef CircuitBreaker_AUDSPKernel_hpp
#define CircuitBreaker_AUDSPKernel_hpp

#import "DSPKernel.hpp"

#include <Accelerate/Accelerate.h>
#include <math.h>

enum {
    clipLevelParameter = 0,
};

/*
 CircuitBreaker_AUDSPKernel
 Performs simple copying of the input signal to the output.
 As a non-ObjC class, this is safe to use from render thread.
 */
class CircuitBreaker_AUDSPKernel : public DSPKernel {
public:
    
    // MARK: Member Functions

    CircuitBreaker_AUDSPKernel() {}

    void init(int channelCount, double inSampleRate) {
        chanCount = channelCount;
        sampleRate = float(inSampleRate);
    }

    void reset() {
    }

    bool isBypassed() {
        return bypassed;
    }

    void setBypass(bool shouldBypass) {
        bypassed = shouldBypass;
    }

    void setParameter(AUParameterAddress address, AUValue value) {
                
        switch (address) {
                
            case clipLevelParameter:
                clip_level_db = value;
                if( value <= -90.0f ) {
                    clip_level = 0.0f;
                } else {
                    clip_level = powf(10.0f, 0.05f * value);
                }
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        
        switch (address) {
                
            case clipLevelParameter:
                // Return the goal. It is not thread safe to return the ramping value.
                return clip_level_db;

            default: return 0.f;
        }
    }

    void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        
        /* This is not used in this small AU, so there is no reason to waste the processing time.
         Even if you do test for bypass, it would be better to use a call to
         cblas_copy(frameCount, source, 1, dest, 1);
        
         if (bypassed) {
            // Pass the samples through
            for (int channel = 0; channel < chanCount; ++channel) {
                if (inBufferListPtr->mBuffers[channel].mData ==  outBufferListPtr->mBuffers[channel].mData) {
                    continue;
                }
                
                for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                    const int frameOffset = int(frameIndex + bufferOffset);
                    const float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                    float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                    *out = *in;
                }
            }
            return;
        }
        */
        
        float neg_clip_level = -clip_level;
        
        for (int channel = 0; channel < chanCount; ++channel) {
        
            // Get pointer to immutable input buffer and mutable output buffer
            const float* in = (float*)inBufferListPtr->mBuffers[channel].mData;
            float* out = (float*)outBufferListPtr->mBuffers[channel].mData;
            
            /* This is the template code.
               We are going to do a vector based processing instead.
            
            for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
                const int frameOffset = int(frameIndex + bufferOffset);
                
                // Do your sample by sample dsp here...
                out[frameOffset] = in[frameOffset];
            }
            */
            
            const float *samples_in = &in[bufferOffset];
            float *samples_out = &out[bufferOffset];
            
            vDSP_vclip(samples_in, 1, &neg_clip_level, &clip_level, samples_out, 1, frameCount);
            
        }
    }

    // MARK: Member Variables

private:
    
    int chanCount = 0;
    
    float sampleRate = 44100.0;
    
    bool bypassed = false;
    
    float clip_level_db = 0.0;
    float clip_level = 1.0;
    
    AudioBufferList* inBufferListPtr = nullptr;
    AudioBufferList* outBufferListPtr = nullptr;
};

#endif /* CircuitBreaker_AUDSPKernel_hpp */
