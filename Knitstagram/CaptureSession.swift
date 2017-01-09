//
//  CaptureSession.swift
//  Knitstagram
//
//  Created by Arthur Guibert on 04/01/2017.
//  Copyright © 2017 Arthur Guibert. All rights reserved.
//

import UIKit
import GLKit
import AVFoundation

class CaptureSession {
    var session: AVCaptureSession!
    var textureCache: CVOpenGLESTextureCache? = nil
    
    func setup(context: EAGLContext, useFrontCamera: Bool, outputDelegate: AVCaptureVideoDataOutputSampleBufferDelegate) -> Bool {
        let result = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context, nil, &textureCache)
        
        guard result == kCVReturnSuccess else {
            print("Could not create texture cache")
            return false
        }
        
        session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSessionPreset640x480
        
        let videoDevice = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera,
                                                         mediaType: AVMediaTypeVideo,
                                                         position: useFrontCamera ? AVCaptureDevicePosition.front : AVCaptureDevicePosition.back)
        
        guard videoDevice != nil else {
            print("Could not get video device")
            return false
        }
        
        let input = try? AVCaptureDeviceInput(device: videoDevice)
        
        guard input != nil else {
            print("Could not initialize video input")
            return false
        }
        
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA as UInt32)]
        output.setSampleBufferDelegate(outputDelegate, queue: DispatchQueue.main)
        
        session.addOutput(output)
        session.commitConfiguration()
        
        session.startRunning()
        
        return true
    }
}
