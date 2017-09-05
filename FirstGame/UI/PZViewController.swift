//
//  PZViewController.swift
//  FirstGame
//
//  Created by Gennaro Frazzingaro on 8/7/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import AVFoundation

class PZViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /*
     * TODO: Hook up the imageView
     */
     @IBOutlet var imageView: UIImageView?
    
    var _imagePickerController: UIImagePickerController?
    
    
    // MARK: - UIViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Set up the buttons
        //
        let camera = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(showImagePickerForLibrary(sender:)))
        self.navigationItem.rightBarButtonItem = camera
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        /*
         * TODO: Dispose of any resources that can be recreated.
         */
    }
    
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self._imagePickerController = nil
        
        picker.dismiss(animated: true)
        
        print("Analyzing Image…")
        
        guard let uiImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("no image from image picker")
            return
        }
        guard let ciImage = CIImage(image: uiImage) else {
            print("can't create CIImage from UIImage")
            return
        }
        
        imageView?.image = uiImage
        
        let resource = PZResource.init(image: ciImage)
        
        PZImageRecongnitionModelHandler().predict(image: resource) { (label, error) in
            if let error = error {
                print("error recognizing image: \(error)")
            } else {
                print("label for image: \(label?.identifier ?? "nil")")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
    // MARK: - IBActions
    
    @IBAction func showImagePickerForLibrary(sender: UIBarButtonItem) {
        self.showImagePicker(for: .photoLibrary, from: sender)
    }
    
    /*
     * Later, we might want to add Camera functionalities
     *
    @IBAction func showImagePickerForCamera(sender: UIBarButtonItem) {
        if self.imageView!.isAnimating {
            self.imageView?.stopAnimating()
        }
        
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authStatus == .denied {
            let alertController = UIAlertController(title: "Unable to access the Camera",
                                                    message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.",
                                                    preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(ok)
            
            self.present(alertController, animated: true, completion: nil)
        } else if (authStatus == .notDetermined) {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted {
                    self.showImagePicker(for: .camera, from: sender)
                }
            })
        } else {
            self.showImagePicker(for: .camera, from: sender)
        }
    }
    */
    
    func showImagePicker(for sourceType: UIImagePickerControllerSourceType, from button: UIBarButtonItem) {
        
        if let imageView = self.imageView, imageView.isAnimating {
            imageView.stopAnimating()
        }

        let imagePickerController = UIImagePickerController()
        imagePickerController.modalPresentationStyle = .currentContext
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = (sourceType == .camera) ? .fullScreen : .popover
        
        let presentationController = imagePickerController.popoverPresentationController;
        presentationController?.barButtonItem = button  // display popover from the UIBarButtonItem as an anchor
        presentationController?.permittedArrowDirections = .any
        
        /*
         * Later, we might want to add Camera functionalities
         *
         if (sourceType == .camera)
         {
         // The user wants to use the camera interface. Set up our custom overlay view for the camera.
         imagePickerController.showsCameraControls = false;
         
         /*
         Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view, and set self's reference to the view to nil.
         */
         //            Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)
         //            self.overlayView.frame = imagePickerController.cameraOverlayView.frame;
         //            imagePickerController.cameraOverlayView = self.overlayView
         //            self.overlayView = nil
         }
         */
        
        self._imagePickerController = imagePickerController // we need this for later
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

