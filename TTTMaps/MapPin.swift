//
//  MapPin.swift
//  TTTMaps
//
//  Created by bl on 8/21/17.
//  Copyright © 2017 bl. All rights reserved.
//


import UIKit
import MapKit


class MapPin: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let color: UIColor?
    let imageName: String?
    let url: String?
    
    init(title: String, subtitle: String?, coordinate: CLLocationCoordinate2D, color: UIColor, imageName: String?, url: String?) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.color = color
        self.imageName = imageName
        self.url = url
        
        super.init()
    }
}


