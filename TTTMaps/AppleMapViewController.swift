//
//  AppleMapViewController.swift
//  TTTMaps
//
//  Created by bl on 8/21/17.
//  Copyright © 2017 bl. All rights reserved.
//


import UIKit
import MapKit


class AppleMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private let TTTCoordindates = CLLocationCoordinate2DMake(TTTLatitude, TTTLongitude)
    private var TTTPin: MapPin?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        mapView.delegate = self

        // Display a map centered around TurnToTech
        let TTTDisplayRegion = MKCoordinateRegionMakeWithDistance(TTTCoordindates, 1000, 1000)
        mapView.setRegion(TTTDisplayRegion, animated: true)
        
        // Put a pin on TurnToTech location
        TTTPin = MapPin(title: "TurnToTech", subtitle: "40 Rector St.", coordinate: TTTCoordindates, color: UIColor.red, imageName: "40Rector", url: "http://turntotech.io")
        mapView.addAnnotation(TTTPin!)
        
        // Put a pin for nearby burger chain
        var burgerChainPin = MapPin(title: "Burger King", subtitle: "106 Liberty St", coordinate: CLLocationCoordinate2DMake(40.709637, -74.011912), color: UIColor.green, imageName: "BurgerKing", url: "http://www.bk.com/menu")
        mapView.addAnnotation(burgerChainPin)
        burgerChainPin = MapPin(title: "McDonald's", subtitle: "160 Broadway", coordinate: CLLocationCoordinate2DMake(40.709372, -74.009975), color: UIColor.green, imageName: "McDonalds", url: "https://www.mcdonalds.com/us/en-us/full-menu.html")
        mapView.addAnnotation(burgerChainPin)
        burgerChainPin = MapPin(title: "Shake Shack", subtitle: "200 Broadway, Level 2", coordinate: CLLocationCoordinate2DMake(40.710446, -74.008924), color: UIColor.green, imageName: "FultonCenter", url: "https://www.shakeshack.com/location/fulton-center-nyc")
        mapView.addAnnotation(burgerChainPin)
    }

    // MARK: - Interface Builder Actions
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Method called when user taps the segment control to change the map type.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func MapSegmentControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = MKMapType.standard
        case 1:
            mapView.mapType = MKMapType.satellite
        default:
            assertionFailure("MapSegmentControlTapped: unhandled selectedSegmentIndex")
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Method called when user taps the search button on the navigation bar.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func SearchButtonTapped(_ sender: UIBarButtonItem) {
        // Initialize the search view controller
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "AppleMapSearchViewController") as! AppleMapSearchViewController
        searchVC.delegate = self
        searchVC.hidesBottomBarWhenPushed = true
        searchVC.mapViewRegion = mapView.region
        
        // Set back button of searchVC to just a chevron
        let newBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = newBackButton

        // Go to the search view controller
        navigationController?.pushViewController(searchVC, animated: true)
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Method called when user taps the TurnToTech button on the navigation bar.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func TTTButtonTapped(_ sender: UIBarButtonItem) {
        // Move the map so that TurnToTech is at it center
        mapView.setCenter(TTTCoordindates, animated: true)
    }
}


// MARK: - Search Result Delegate Method

extension AppleMapViewController: SearchResultDelegate {
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called from search view controller when the user tapped (select) a cell.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func userDidFind(location: MapPin) {
        // Add the selected search result to the map
        mapView.addAnnotation(location)
        mapView.setCenter(location.coordinate, animated: true)
    }
}


// MARK: - Map View Delegate Methods

extension AppleMapViewController: MKMapViewDelegate {
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called when user taps the callout accessory control.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        var vc: UIViewController
        
        let selectedAnnotation = view.annotation as! MapPin
        
        // If the leftCalloutAccessory was tapped then ...
        if control.tag == 1 {
            // display an image of the location
            let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "AppleMapImageViewController") as! AppleMapImageViewController
            imageVC.displayTitle = selectedAnnotation.title
            imageVC.imageName = selectedAnnotation.imageName! + "-lg.jpg"
            imageVC.hidesBottomBarWhenPushed = true
            
            vc = imageVC
            
        // If there is an associated website then ...
        } else if selectedAnnotation.url != nil {
            // display it
            let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webVC.displayTitle = selectedAnnotation.title
            webVC.pageUrl = selectedAnnotation.url
            webVC.hidesBottomBarWhenPushed = true
            
            vc = webVC
            
        // Otherwise, ...
        } else {
            // nothing to display
            return
        }
        
        // Set back button of viewcontroller to just a chevron
        let newBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = newBackButton
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called for every annotation added to the map.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapPin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            // If an AnnotationView is available for recycling then ...
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
                // Otherwise, ...
            } else {
                // create a new AnnotationView
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
            }
            
            view.pinTintColor = annotation.color
            
            // Display an information button on the right if there is an url
            view.rightCalloutAccessoryView = annotation.url != nil ? UIButton(type: .detailDisclosure) as UIView : nil
            
            // If there is an image associated then ...
            if let imageName = annotation.imageName {
                // retrieve it and display it on the left
                let thumbnailImage = UIImage(named: imageName + "-sm.jpg")
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                button.setImage(thumbnailImage, for: .normal)
                button.tag = 1
                view.leftCalloutAccessoryView = button
            } else {
                view.leftCalloutAccessoryView = nil
            }
            
            return view
        }
        return nil
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called when an error occured during map loading.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print("Map loading error: \(error)")
    }
}
