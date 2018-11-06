//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos

class ImagePostViewController: ShiftableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        _ = UITapGestureRecognizer(target: noFilterImageView, action: #selector(noFilterImageViewTapped))
        
        updateViews()
    }
    
    
    @objc func noFilterImageViewTapped() {
        print("noFilterImageViewTapped")
    }
    
    // 5. Update Image function added
    
    func updateImage() {
        guard let originalImage = originalImage else { return }
        
        imageView.image = originalImage
        noFilterImageView.image = UIImage.scaleImage(image: originalImage)
        vintageImageView.image = apply(filter: vintageFilter, for: originalImage)
        monoImageView.image = apply(filter: monoFilter, for: originalImage)
        noirImageView.image = apply(filter: noirFilter, for: originalImage)
        coolImageView.image = apply(filter: coolFilter, for: originalImage)
        warmImageView.image = apply(filter: warmFilter, for: originalImage)
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
        imageView.image = image
        
        chooseImageButton.setTitle("", for: [])
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    // 1. Added outlets
    @IBOutlet weak var addFilterLabel: UILabel!
    @IBOutlet weak var noFilterLabel: UILabel!
    @IBOutlet weak var noFilterImageView: UIImageView!
    @IBOutlet weak var vintageLabel: UILabel!
    @IBOutlet weak var vintageImageView: UIImageView!
    @IBOutlet weak var monoLabel: UILabel!
    @IBOutlet weak var monoImageView: UIImageView!
    @IBOutlet weak var noirLabel: UILabel!
    @IBOutlet weak var noirImageView: UIImageView!
    @IBOutlet weak var coolLabel: UILabel!
    @IBOutlet weak var coolImageView: UIImageView!
    @IBOutlet weak var warmLabel: UILabel!
    @IBOutlet weak var warmImageView: UIImageView!
    
    // 4. Properties added
    private var originalImage: UIImage? {
        didSet{ updateImage() }
    }
    
    // 3. Filters and context added
    private let vintageFilter = CIFilter(name: "CIPhotoEffectChrome")!
    private let monoFilter = CIFilter(name: "CIPhotoEffectMono")!
    private let noirFilter = CIFilter(name: "CIPhotoEffectNoir")!
    private let coolFilter = CIFilter(name: "CIPhotoEffectProcess")!
    private let warmFilter = CIFilter(name: "CIPhotoEffectTransfer")!
    private let colorControlsFilter = CIFilter(name: "CIColorControls")!
    private let hueFilter = CIFilter(name: "CIHueAdjust")!
    private let context = CIContext(options: nil)
    
    // 2. Created image filter function
    private func apply(filter: CIFilter, for image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let filteredCIImage = filter.outputImage else { return image }
        guard let filteredCGImage = context.createCGImage(filteredCIImage, from: filteredCIImage.extent) else { return image }
        
        let filteredImage = UIImage(cgImage: filteredCGImage)
        let scaledImage = UIImage.scaleImage(image: filteredImage)
        
        return scaledImage
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        originalImage = image // 6. Changed
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// 7. ScaleImage added

extension UIImage {
    
    class func scaleImage(image: UIImage) -> UIImage {
        
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
}
