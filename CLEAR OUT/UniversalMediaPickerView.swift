//
//  UniversalMediaPickerView.swift
//  CLEAR OUT
//
//  Created by Bolanle Adisa on 3/4/24.
//

import SwiftUI
import UIKit

struct UniversalMediaPickerView: UIViewControllerRepresentable {
    @Binding var inputImage: UIImage?
    @Binding var videoURL: URL?
    var completion: (() -> Void)?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        // Allow both images and videos
        picker.mediaTypes = ["public.image", "public.movie"]
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: UniversalMediaPickerView

        init(_ parent: UniversalMediaPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Handle image selection
            if let uiImage = info[.originalImage] as? UIImage {
                parent.inputImage = uiImage
            }
            // Handle video selection
            if let videoUrl = info[.mediaURL] as? URL {
                parent.videoURL = videoUrl
            }
            parent.completion?()
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
