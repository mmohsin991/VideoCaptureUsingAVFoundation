//
//  ViewController.swift
//  VideoCaptureUsingAVFoundation
//
//  Created by Mohsin on 04/09/2015.
//  Copyright (c) 2015 Mohsin. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    
    
    @IBOutlet weak var videoView: UIView!
    
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var fileOutput : AVCaptureMovieFileOutput!
    var delegate : AVCaptureFileOutputRecordingDelegate?
    var player:MPMoviePlayerViewController!
    
    // If we find a device we'll store it here for later use
    var captureDevice : AVCaptureDevice?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        self.delegate = self

        
        let devices = AVCaptureDevice.devices()
        captureSession
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func focusTo(value : Float) {
        if let device = captureDevice {
//            if(device.lockForConfiguration(nil)) {
//                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
//                    //
//                })
//                device.unlockForConfiguration()
//            }
        }
    }
    
    let screenWidth = UIScreen.mainScreen().bounds.size.width

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var anyTouch = touches.first as! UITouch
        var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
        focusTo(Float(touchPercent))
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var anyTouch = touches.first as! UITouch
        var touchPercent = anyTouch.locationInView(self.view).x / screenWidth
        focusTo(Float(touchPercent))
    }
    
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
            device.unlockForConfiguration()
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        // video recording
        self.fileOutput = AVCaptureMovieFileOutput()
        self.captureSession.addOutput(self.fileOutput)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
//        // filters
//        let filters : [CIFilter] = [CIFilter(name:"CIColorInvert")]
//        
//        previewLayer?.filters = filters
        
        self.videoView.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.videoView.layer.frame
        captureSession.startRunning()
    }
    
    
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        println("start recording")

    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        println("stop recording")
        println(outputFileURL)
        if outputFileURL != nil {
            self.playVideo(outputFileURL)
        }
    }
    
    
    func playVideo(videoURL: NSURL){
        
        player = MPMoviePlayerViewController(contentURL: videoURL)
        
        self.presentMoviePlayerViewControllerAnimated(player)
    }
    
    
    func record() -> NSURL{
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateTimePrefix: String = formatter.stringFromDate(NSDate())
        
        let paths = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true)
        
        let documentsDirectory = paths[0] as! String
        
        var filePath:String? = nil
        var fileNamePostfix = 0
        do {
            filePath =
            "\(documentsDirectory)/\(dateTimePrefix)-\(fileNamePostfix++).mp4"
        } while (NSFileManager.defaultManager().fileExistsAtPath(filePath!))
        
        self.fileOutput.startRecordingToOutputFileURL(NSURL(fileURLWithPath: filePath!), recordingDelegate: delegate)
        
        return NSURL(fileURLWithPath: filePath!)!
    }
    
    

    
    
    
    @IBAction func record(sender : UIButton) {
        
        let url = self.record()
        
    }

    
    @IBAction func stop(sender : UIButton) {
        println("Stop")
        self.fileOutput.stopRecording()
    }
    

}

