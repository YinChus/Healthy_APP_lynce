
//
//  AVCpatureVideo.swift
//  我的 App
//
//  Created by Jianhui Tan on 2023/8/18.
//


import SwiftUI
import AVFoundation
import Vision


class UIAVCaptureVideoPreviewView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
    var recognitionInterval = 0
    var mlModel: VNCoreMLModel?
    var captureSession: AVCaptureSession!
    var resultLabel: UILabel!
    
    var recognitionObject: ((String) -> Void)?
    var recognitionConfidence: ((Double) -> Void)?

    func setModel() {
        mlModel = try? VNCoreMLModel(for: CoreMLFruit().model)
    }

    func setupSession() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
        guard captureSession.canAddInput(videoInput) else { return }
        
        captureSession.addInput(videoInput)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        captureSession.commitConfiguration()
    }

    func setupPreview() {
        // 设置视图的大小为整个屏幕的大小
        self.frame = UIScreen.main.bounds

        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.frame = self.bounds // 使用bounds而不是frame确保尺寸正确
        previewLayer.videoGravity = .resizeAspectFill // 保持宽高比并填满整个视图
        self.layer.addSublayer(previewLayer)

        self.captureSession.startRunning()
    }

    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if recognitionInterval < 20 {
            recognitionInterval += 1
            return
        }
        recognitionInterval = 0
        
        guard
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let model = mlModel
        else { return }

        let request = VNCoreMLRequest(model: model) { (request: VNRequest, error: Error?) in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            
            if let topResult = results.first {
                self.recognitionObject?(topResult.identifier)
                self.recognitionConfidence?(Double(topResult.confidence))
            }
        }

        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}





import SwiftUI

struct SwiftUIAVCaptureVideoPreviewView: UIViewRepresentable {
    @Binding var recognizedObject: String
    @Binding var recognizedConfidence: Double

    func makeUIView(context: Context) -> UIAVCaptureVideoPreviewView {
        let view = UIAVCaptureVideoPreviewView()
        
        view.recognitionObject = { object in
            self.recognizedObject = object
        }
        
        view.recognitionConfidence = { confidence in
            self.recognizedConfidence = confidence
        }
        
        view.setModel()
        view.setupSession()
        view.setupPreview()
        
        return view
    }

    func updateUIView(_ uiView: UIAVCaptureVideoPreviewView, context: Context) {}
}
