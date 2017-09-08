//
//  AppleMapImageViewController.swift
//  TTTMaps
//
//  Created by bl on 8/31/17.
//  Copyright © 2017 bl. All rights reserved.
//


import UIKit


class AppleMapImageViewController: UIViewController {
    public var displayTitle: String?
    public var imageName: String?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        assert(imageName != nil, "imageName property not set.")
        
        edgesForExtendedLayout = []
        
        if displayTitle != nil {
            title = displayTitle!
        }
        
        let image: UIImage = UIImage(named: imageName!)!
        imageView.image = image
    }
}
