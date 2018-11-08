//
//  AddCommentViewController.swift
//  LambdaTimeline
//
//  Created by Ilgar Ilyasov on 11/7/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class AddCommentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextField.isEnabled = false
        recordButton.isEnabled = false
        playButton.isEnabled = false
    }

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectCommentType(_ sender: Any) {
        if commentTypeSegmentedControl.selectedSegmentIndex == 0 {
            commentTextField.isEnabled = true
            recordButton.isEnabled = false
            playButton.isEnabled = false
        } else {
            commentTextField.isEnabled = false
            recordButton.isEnabled = true
            playButton.isEnabled = true
        }
    }
    
    
    @IBAction func record(_ sender: Any) {
        
    }
    
    @IBAction func play(_ sender: Any) {
        
    }
    
    @IBAction func send(_ sender: Any) {
        
    }
    
    @IBOutlet weak var commentTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
}
