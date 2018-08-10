//
//  ViewController.swift
//  CameraObjectDetection
//
//  Created by Euijae Hong on 2018. 8. 10..
//  Copyright © 2018년 JAEJIN. All rights reserved.
//

import UIKit
import AVKit
import Vision

/*
 모델 받는 URL
 https://developer.apple.com/kr/machine-learning/build-run-models/
*/

enum CoreMLModel {
    
    case ModelMobileNet
    case ModelSqueezeNet
    case ModelPlaces205
    case ModelResNet50
    
    func getModel() -> MLModel {
        
        switch self {
            
        case .ModelMobileNet:
            
            return MobileNet().model
            
        case .ModelSqueezeNet:
            
            return SqueezeNet().model
            
        case .ModelPlaces205:
            
            return GoogLeNetPlaces().model
            
        case .ModelResNet50:
            
            return Resnet50().model
    
        }
    }
}

class ViewController: UIViewController {
    
    var coreMLModel = CoreMLModel.ModelSqueezeNet

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Setup Camera
        let captureSesstion = AVCaptureSession()
        captureSesstion.sessionPreset = .photo
    
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSesstion.addInput(input)
        captureSesstion.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSesstion)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSesstion.addOutput(dataOutput)
        
    }
    

}


//MARK:- AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // Notifies the delegate that a new video frame was written.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for: coreMLModel.getModel()) else { return }
        
        let request = VNCoreMLRequest(model:model , completionHandler: { (req, err) in
            
            guard let results = req.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            print("identifier :",firstObservation.identifier)
            print("confidence :",firstObservation.confidence)
            
        })
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
    }

}

