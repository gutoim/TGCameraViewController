//
//  ViewController.swift
//  ExampleSwift
//
//  Created by Mario Cecchi on 7/20/16.
//  Copyright © 2016 Tudo Gostoso Internet. All rights reserved.
//

import UIKit

class TGInitialViewController: UIViewController, TGCameraDelegate {
    @IBOutlet weak var photoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set custom tint color
        //TGCameraColor.setTintColor(.greenColor())
        
        // save image to album
        TGCamera.setOption(kTGCameraOptionSaveImageToAlbum, value: true)
        
        // hide switch camera button
        //TGCamera.setOption(kTGCameraOptionHiddenToggleButton, value: true)
        
        // hide album button
        //TGCamera.setOption(kTGCameraOptionHiddenAlbumButton, value: true)
        
        // hide filter button
        //TGCamera.setOption(kTGCameraOptionHiddenFilterButton, value: true)
        
        photoView.clipsToBounds = true
        
        let clearButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action:#selector(clearTapped))
        navigationItem.rightBarButtonItem = clearButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: TGCameraDelegate - Required methods
    
    func cameraDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cameraDidTakePhoto(image: UIImage!) {
        photoView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cameraDidSelectAlbumPhoto(image: UIImage!) {
        photoView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: TGCameraDelegate - Optional methods
    
    func cameraWillTakePhoto() {
        print("cameraWillTakePhoto")
    }
    
    func cameraDidSavePhotoAtPath(assetURL: NSURL!) {
        print("cameraDidSavePhotoAtPath: \(assetURL)")
    }
    
    func cameraDidSavePhotoWithError(error: NSError!) {
        print("cameraDidSavePhotoWithError \(error)")
    }
    
    
    // MARK: Actions
    
    @IBAction func takePhotoTapped() {
        let navigationController = TGCameraNavigationController.newWithCameraDelegate(self)
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    // MARK: Private methods
    
    func clearTapped() {
        photoView.image = nil
    }
}

