//
//  CustomCameraView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import AVFoundation

struct CustomCameraView: View {
    @Binding var image: Image?
    @Binding var inputImage: UIImage?
    @Binding var videoURL: URL?
    @State private var isRecording = false
    let cameraController = CameraController()

    var body: some View {
        ZStack {
            CameraPreview(cameraController: cameraController)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                if let image = image {
                    image
                        .resizable()
                        .scaledToFit()
                }
                
                HStack {
                    Button(action: {
                        self.cameraController.switchCamera()
                    }) {
                        Image(systemName: "arrow.2.circlepath.camera")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        if self.isRecording {
                            self.cameraController.stopRecording()
                        } else {
                            let outputPath = NSTemporaryDirectory() + UUID().uuidString + ".mov"
                            let outputFileURL = URL(fileURLWithPath: outputPath)
                            self.cameraController.startRecording(to: outputFileURL)
                            self.videoURL = outputFileURL // Optionally handle or store the video URL as needed
                        }
                        self.isRecording.toggle()
                    }) {
                        Image(systemName: self.isRecording ? "stop.circle" : "video.circle")
                            .font(.largeTitle)
                            .foregroundColor(self.isRecording ? .red : .white)
                    }
                }
            }
        }
        .onAppear {
            self.cameraController.setup()
        }
        .onDisappear {
            self.cameraController.tearDown()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    var cameraController: CameraController
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        cameraController.previewLayer.frame = view.frame
        view.layer.addSublayer(cameraController.previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}


class CameraController: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var currentCameraPosition: CameraPosition?
    var photoOutput: AVCapturePhotoOutput?
    var videoOutput: AVCaptureMovieFileOutput?
    var previewLayer: AVCaptureVideoPreviewLayer!
    var isRecording = false

    override init() {
        super.init()
        self.captureSession = AVCaptureSession()
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        self.previewLayer.videoGravity = .resizeAspectFill
    }
    
    func setup() {
        checkCameraAuthorization { authorized in
            if authorized {
                self.configureCaptureSession()
            }
        }
    }

    func configureCaptureSession() {
        guard let captureSession = self.captureSession else { return }
        
        captureSession.beginConfiguration()
        
        // Setup devices
        let videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        
        try? videoDevices.forEach { device in
            if device.position == .back {
                self.rearCamera = device
            } else if device.position == .front {
                self.frontCamera = device
            }
        }
        
        if let rearCamera = self.rearCamera, let rearCameraInput = try? AVCaptureDeviceInput(device: rearCamera), captureSession.canAddInput(rearCameraInput) {
            captureSession.addInput(rearCameraInput)
            self.currentCameraPosition = .rear
        } else if let frontCamera = self.frontCamera, let frontCameraInput = try? AVCaptureDeviceInput(device: frontCamera), captureSession.canAddInput(frontCameraInput) {
            captureSession.addInput(frontCameraInput)
            self.currentCameraPosition = .front
        }

        
        // Setup photo output
        let photoOutput = AVCapturePhotoOutput()
                if captureSession.canAddOutput(photoOutput) {
                    captureSession.addOutput(photoOutput)
                    self.photoOutput = photoOutput
                }
                
                // Setup video output
                let videoOutput = AVCaptureMovieFileOutput()
                if captureSession.canAddOutput(videoOutput) {
                    captureSession.addOutput(videoOutput)
                    self.videoOutput = videoOutput
                }
                
                captureSession.commitConfiguration()
            }
    
    func tearDown() {
        captureSession?.stopRunning()
        for input in captureSession?.inputs ?? [] {
            captureSession?.removeInput(input)
        }
        for output in captureSession?.outputs ?? [] {
            captureSession?.removeOutput(output)
        }
    }
    
    func switchCamera() {
        guard let captureSession = captureSession, let currentCameraPosition = currentCameraPosition else { return }
        
        captureSession.beginConfiguration()
        
    func switchToCamera(position: AVCaptureDevice.Position) {
            let newDevice = (position == .back) ? rearCamera : frontCamera
            for input in captureSession.inputs {
                captureSession.removeInput(input)
            }
            
            if let newDevice = newDevice {
                do {
                    let newInput = try AVCaptureDeviceInput(device: newDevice)
                    if captureSession.canAddInput(newInput) {
                        captureSession.addInput(newInput)
                        self.currentCameraPosition = position == .back ? .rear : .front
                    }
                } catch let error {
                    print("Error switching to \(position == .back ? "rear" : "front") camera: \(error)")
                }
            }
        }
        
        switchToCamera(position: currentCameraPosition == .rear ? .front : .back)
        
        captureSession.commitConfiguration()
    }
    
    func takePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let photoOutput = self.photoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        self.photoCaptureCompletionBlock = completion
    }
    
    private var photoCaptureCompletionBlock: ((UIImage?) -> Void)?
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            self.photoCaptureCompletionBlock?(nil)
        } else if let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) {
            self.photoCaptureCompletionBlock?(image)
        } else {
            print("Error capturing photo: No image data found.")
            self.photoCaptureCompletionBlock?(nil)
        }
    }
    
    enum CameraPosition {
        case front
        case rear
    }
    
    func startRecording(to outputFileURL: URL) {
        guard let videoOutput = self.videoOutput else { return }
        
        if videoOutput.isRecording {
            videoOutput.stopRecording() // Optional: Stop any existing recording
        }
        
        videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
    }

    func stopRecording() {
        guard let videoOutput = self.videoOutput, videoOutput.isRecording else { return }
        videoOutput.stopRecording()
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
        } else {
            // Handle successful recording (e.g., save the video to an album, update UI)
            DispatchQueue.main.async {
                // Update your UI or handle the video URL as needed
            }
        }
    }
    
    private func checkCameraAuthorization(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        default:
            completion(false)
        }
    }
    
}

struct CustomCameraView_Previews: PreviewProvider {
    @State static var image: Image? = nil
    @State static var inputImage: UIImage? = nil
    @State static var videoURL: URL? = nil // Added to match the expected argument

    static var previews: some View {
        // Updated to include videoURL as per the CustomCameraView definition
        CustomCameraView(image: $image, inputImage: $inputImage, videoURL: $videoURL)
    }
}
