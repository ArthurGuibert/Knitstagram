//
//  MainViewController.swift
//  Knitstagram
//
//  Created by Arthur Guibert on 08/01/2017.
//  Copyright © 2017 Arthur Guibert. All rights reserved.
//

import UIKit
import GLKit

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func take(_ sender: Any) {
        if let cameraController = self.childViewControllers.first as? ViewController {
            let glkView: GLKView = cameraController.view as! GLKView
            share(image: glkView.snapshot)
        }
    }
    
    func share(image: UIImage) {
        let activityItem: [AnyObject] = [image as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        self.present(avc, animated: true, completion: nil)
    }
}
