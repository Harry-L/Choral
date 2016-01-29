//
//  ViewController.swift
//  Choral
//
//  Created by Harry Liu on 2016-01-27.
//  Copyright © 2016 Harry Liu. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

@objc protocol AURenderCallbackDelegate {
    func performRender(ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        inTimeStamp: UnsafePointer<AudioTimeStamp>,
        inBufNumber: UInt32,
        inNumberFrames: UInt32,
        ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus
}

private func AudioController_RenderCallback(inRefCon: UnsafeMutablePointer<Void>,
    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp: UnsafePointer<AudioTimeStamp>,
    inBufNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer<AudioBufferList>)
    -> OSStatus
{
    let delegate = unsafeBitCast(inRefCon, AURenderCallbackDelegate.self)
    let result = delegate.performRender(ioActionFlags,
        inTimeStamp: inTimeStamp,
        inBufNumber: inBufNumber,
        inNumberFrames: inNumberFrames,
        ioData: ioData)
    return result
}


class ViewController: UIViewController, AURenderCallbackDelegate {
    
    var sampleRate = 44100.0 //Hertz
    let bufferDuration: NSTimeInterval = 0.005
    var mySession: AVAudioSession!
    var ioUnitInstance: AudioUnit = AudioUnit()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        setupAudioUnit()
        
        AudioOutputUnitStart(ioUnitInstance)
    }
    
    func performRender(
        ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        inTimeStamp: UnsafePointer<AudioTimeStamp>,
        inBufNumber: UInt32,
        inNumberFrames: UInt32,
        ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus
    {
        let err = AudioUnitRender(ioUnitInstance, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData)
        return err;
    }
    
    func setupAudioSession() {
        mySession = AVAudioSession.sharedInstance()
        
        do {
            try mySession.setPreferredSampleRate(sampleRate)
        } catch {}
        
        do {
            try mySession.setPreferredIOBufferDuration(bufferDuration)
        } catch {}
        
        do {
            try mySession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {}
        
        do {
            try mySession.setActive(true)
        } catch {}
        
        sampleRate = mySession.sampleRate
        
        print("setup audio session")
    }
    
    func setupAudioUnit() {
        var description = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        
        let component = AudioComponentFindNext(nil, &description)
        
        AudioComponentInstanceNew(component, &ioUnitInstance)
        
        var enableInput: UInt32        = 1    // to enable input
        let inputBus: AudioUnitElement = 1
        
        AudioUnitSetProperty (
            ioUnitInstance,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Input,
            inputBus,
            &enableInput,
            UInt32(strideofValue(enableInput))
        )
        
        var enableOutput: UInt32 = 1
        let outputBus: AudioUnitElement = 1
        
        AudioUnitSetProperty (
            ioUnitInstance,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Output,
            outputBus,
            &enableOutput,
            UInt32(strideofValue((enableOutput)))
        )
        
        var renderCallback = AURenderCallbackStruct(
            inputProc: AudioController_RenderCallback,
            inputProcRefCon: UnsafeMutablePointer(unsafeAddressOf(self))
        )
        
        AudioUnitSetProperty(ioUnitInstance, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &renderCallback, UInt32(sizeofValue(renderCallback)))
        
        AudioUnitInitialize(ioUnitInstance)
        
        print("setup audio unit")
        
    }
}

