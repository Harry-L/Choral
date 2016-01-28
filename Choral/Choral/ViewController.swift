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

class ViewController: UIViewController {
    
    var recordingSession: AVAudioSession!
    var audioUnit: AVAudioUnit!
    var rioUnit: AudioUnit = AudioUnit()
    var sampleRate = 44100.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupAudioSession()
        setupIOUnit()
        
        let err = AudioOutputUnitStart(rioUnit)
        
        
    }
    
    func startRecording() {
        
        
    }
    
    func setupAudioSession() {
        //configure audio session
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print(error)
            print("Couldn't setup audio session")
        } catch {
            fatalError()
        }
        
        // set the buffer duration to 5 ms
        let bufferDuration: NSTimeInterval = 0.005
        do {
            try recordingSession.setPreferredIOBufferDuration(bufferDuration)
        } catch let error as NSError {
            print(error)
            print("Couldn't setup buffer duration")
        } catch {
            fatalError()
        }
        
        // set the session's sample rate
        do {
            try recordingSession.setPreferredSampleRate(sampleRate)
        } catch let error as NSError {
            print(error)
            print("Couldn't setup sample rate")
        } catch {
            fatalError()
        }
        
         // activate the audio session
        do {
            try recordingSession.setActive(true)
        } catch let error as NSError {
            print(error)
            print("Couldn't activate the audio session")
        } catch {
            fatalError()
        }
        
        sampleRate = recordingSession.sampleRate
    }
    
    func setupIOUnit() {
        // Create a new instance of AURemoteIO
        var description = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0,
            componentFlagsMask: 0)
        
        
        let component = AudioComponentFindNext(nil, &description)
        
        AudioComponentInstanceNew(component, &self.rioUnit)
        
        var enableInput: UInt32         = 1;    // to enable input
        let inputBus: AudioUnitElement = 1;
        
        let ioUnit: AudioUnit = AudioUnit.init()
        
        AudioUnitSetProperty (
            ioUnit,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Input,
            inputBus,
            &enableInput,
            UInt32(strideofValue(enableInput))
        );
        
        //  Enable input and output on AURemoteIO
        //  Input is enabled on the input scope of the input element
        //  Output is enabled on the output scope of the output element
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

