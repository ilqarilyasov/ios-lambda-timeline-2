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
        
        hideLabels()
        
        let noFilterTapGesture = UITapGestureRecognizer(target: self, action: #selector(noFilterImageViewTapped))
        noFilterImageView.addGestureRecognizer(noFilterTapGesture)
        
        let vintageTapGesture = UITapGestureRecognizer(target: self, action: #selector(vintageImageViewTapped))
        vintageImageView.addGestureRecognizer(vintageTapGesture)
        
        let monoTapGesture = UITapGestureRecognizer(target: self, action: #selector(monoImageViewTapped))
        monoImageView.addGestureRecognizer(monoTapGesture)
        
        let noirTapGesture = UITapGestureRecognizer(target: self, action: #selector(noirImageViewTapped))
        noirImageView.addGestureRecognizer(noirTapGesture)
        
        let coolTapGesture = UITapGestureRecognizer(target: self, action: #selector(coolImageViewTapped))
        coolImageView.addGestureRecognizer(coolTapGesture)
        
        let warmTapGesture = UITapGestureRecognizer(target: self, action: #selector(warmImageViewTapped))
        warmImageView.addGestureRecognizer(warmTapGesture)
        
        updateViews()
    }
    
    // 9. Added
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideLabels()
    }
    
    
    @objc func noFilterImageViewTapped() {
        print("noFilterImageViewTapped")
        guard let originalImage = originalImage else { return }
        imageView.image = originalImage
    }
    
    @objc func vintageImageViewTapped() {
        print("vintageImageViewTapped")
        guard let originalImage = originalImage else { return }
        let filteredImage = apply(filter: vintageFilter, for: originalImage)
        imageView.image = filteredImage
    }
    
    @objc func monoImageViewTapped() {
        print("monoImageViewTapped")
    }
    
    @objc func noirImageViewTapped() {
        print("noirImageViewTapped")
    }
    
    @objc func coolImageViewTapped() {
        print("coolImageViewTapped")
    }
    
    @objc func warmImageViewTapped() {
        print("warmImageViewTapped")
    }
    
    // 5. Update Image function added
    
    func updateImage() {
        let size = CGSize(width: 60, height: 60)
        guard let originalImage = originalImage else { return }
        
        imageView.image = originalImage
        noFilterImageView.image = UIImage.scaleImage(image: originalImage, size: size)
        
        let filteredVintage: UIImage = apply(filter: vintageFilter, for: originalImage)
        let scaledVintage = UIImage.scaleImage(image: filteredVintage, size: size)
        vintageImageView.image = scaledVintage
        
        let filteredMono: UIImage = apply(filter: monoFilter, for: originalImage)
        let scaledMono = UIImage.scaleImage(image: filteredMono, size: size)
        monoImageView.image = scaledMono
        
        let filteredNoir: UIImage = apply(filter: noirFilter, for: originalImage)
        let scaledNoir = UIImage.scaleImage(image: filteredNoir, size: size)
        noirImageView.image = scaledNoir
        
        let filteredCool: UIImage = apply(filter: noirFilter, for: originalImage)
        let scaledCool = UIImage.scaleImage(image: filteredCool, size: size)
        coolImageView.image = scaledCool
        
        let filteredWarm: UIImage = apply(filter: noirFilter, for: originalImage)
        let scaledWarm = UIImage.scaleImage(image: filteredWarm, size: size)
        warmImageView.image = scaledWarm
    }
    
    // 8. Hide labels
    
    private func hideLabels(){
        if originalImage == nil {
            addFilterLabel.isHidden = true
            noFilterLabel.isHidden = true
            vintageLabel.isHidden = true
            monoLabel.isHidden = true
            noirLabel.isHidden = true
            coolLabel.isHidden = true
            warmLabel.isHidden = true
        } else {
            addFilterLabel.isHidden = false
            noFilterLabel.isHidden = false
            vintageLabel.isHidden = false
            monoLabel.isHidden = false
            noirLabel.isHidden = false
            coolLabel.isHidden = false
            warmLabel.isHidden = false
        }
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
        
        return UIImage(cgImage: filteredCGImage)
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
