//
//  GoogleMapViewController.swift
//  TTTMaps
//
//  Created by bl on 8/24/17.
//  Copyright © 2017 bl. All rights reserved.
//
//  https://developers.google.com/maps/documentation/ios-sdk/start
//


import UIKit
import GoogleMaps
import GooglePlaces


class GoogleMapViewController: UIViewController {
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        mapView.delegate = self
        
        // Create a GMSCameraPosition that centers the map around TurnToTech
        mapView.camera = GMSCameraPosition.camera(withLatitude: TTTLatitude, longitude: TTTLongitude, zoom: 15.0)

        // Creates a marker in the center of the map.
        let TTTMarker = GMSMarker()
        TTTMarker.position = CLLocationCoordinate2D(latitude: TTTLatitude, longitude: TTTLongitude)
        TTTMarker.title = "TurnToTech"
        TTTMarker.snippet = "40 Rector St."
        TTTMarker.userData = ["url": "http://turntotech.io", "image": "40Rector-sm.jpg"]
        TTTMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        TTTMarker.map = mapView
        
        // Create markers for nearby burger chains
        let BurgeKingMarker = GMSMarker()
        BurgeKingMarker.position = CLLocationCoordinate2D(latitude: 40.709637, longitude: -74.011912)
        BurgeKingMarker.title = "Burger King"
        BurgeKingMarker.snippet = "106 Liberty St"
        BurgeKingMarker.userData = ["url": "http://www.bk.com/menu", "image": "BurgerKing-sm.jpg"]
        BurgeKingMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        BurgeKingMarker.map = mapView

        let McDonaldsMarker = GMSMarker()
        McDonaldsMarker.position = CLLocationCoordinate2D(latitude: 40.709372, longitude: -74.009975)
        McDonaldsMarker.title = "McDonald's"
        McDonaldsMarker.snippet = "160 Broadway"
        McDonaldsMarker.userData = ["url": "https://www.mcdonalds.com/us/en-us/full-menu.html", "image": "McDonalds-sm.jpg"]
        McDonaldsMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        McDonaldsMarker.map = mapView

        let ShakeShackMarker = GMSMarker()
        ShakeShackMarker.position = CLLocationCoordinate2D(latitude: 40.710446, longitude: -74.008924)
        ShakeShackMarker.title = "Shake Shack"
        ShakeShackMarker.snippet = "200 Broadway, Level 2"
        ShakeShackMarker.userData = ["url": "https://www.shakeshack.com/location/fulton-center-nyc", "image": "FultonCenter-sm.jpg"]
        ShakeShackMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        ShakeShackMarker.map = mapView

        // For some unknown reasons, when you add a segment control in storyboard it will not show
        // up in a google map, but it will if you create it programmatically.
        let mapTypeSelector = UISegmentedControl(items: [" Normal ", " Hybrid "])
        mapTypeSelector.selectedSegmentIndex = 0
        mapTypeSelector.backgroundColor = UIColor.clear
        mapTypeSelector.translatesAutoresizingMaskIntoConstraints = false
        mapTypeSelector.addTarget(self, action: #selector(GoogleMapViewController.mapTypeSegmentedControlTapped(_:)), for: .valueChanged)
        mapView.addSubview(mapTypeSelector)
        
        mapTypeSelector.widthAnchor.constraint(equalToConstant: 144).isActive = true
        mapTypeSelector.heightAnchor.constraint(equalToConstant: 29).isActive = true
        mapTypeSelector.topAnchor.constraint(equalTo: mapView.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
        mapTypeSelector.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Method called when user taps the segment control to change the map type.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func mapTypeSegmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .normal   // kGMSTypeNormal
        case 1:
            mapView.mapType = .hybrid   // kGMSTypeHybrid
        default:
            assertionFailure("MapSegmentControlTapped: unhandled selectedSegmentIndex")
        }
    }
    
    // MARK: - Interface Builder Actions

    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Method called when user taps the search button on the navigation bar.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func SearchButtonTapped(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        autocompleteController.hidesBottomBarWhenPushed = true
        
        let visibleRegion = mapView.projection.visibleRegion()
        autocompleteController.autocompleteBounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        navigationController?.pushViewController(autocompleteController, animated: true)
    }

    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Method called when user taps the TurnToTech button on the navigation bar.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    @IBAction func TTTButtonTapped(_ sender: UIBarButtonItem) {
        // Move the map so that TurnToTech is at it center
        mapView.animate(toLocation: CLLocationCoordinate2D(latitude: TTTLatitude, longitude: TTTLongitude))
    }
}


// MARK: - Map View Delegate Methods

extension GoogleMapViewController: GMSMapViewDelegate {
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called when user taps the information window of a marker.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let locationInfo = marker.userData as! [String: String]
        guard let url = locationInfo["url"] else {
            return
        }
        
        // Initialize a webViewController
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        webVC.displayTitle = marker.title!
        webVC.pageUrl = url
        webVC.hidesBottomBarWhenPushed = true
        
        // Set back button of webVC to just a chevron
        let newBackButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = newBackButton
        
        // Go to the webViewController
        navigationController?.pushViewController(webVC, animated: true)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called when user taps a marker to display an infoWindow.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let customInfoView = Bundle.main.loadNibNamed("CustomInfoWindow", owner: self, options: nil)?[0] as? CustomInfoWindow else {
            return nil
        }
        
        // Determine which text is longer for the specified font
        var fontAttributes = [NSFontAttributeName: customInfoView.title.font!]
        let titleSize = marker.title?.size(attributes: fontAttributes)
        fontAttributes = [NSFontAttributeName: customInfoView.snippet.font!]
        let snippetSize = marker.snippet?.size(attributes: fontAttributes)
        let textWidth = Double((titleSize?.width)!) > Double((snippetSize?.width)!) ? titleSize?.width : snippetSize?.width

        customInfoView.title.text = marker.title
        customInfoView.title.frame.size.width = textWidth!
        customInfoView.snippet.text = marker.snippet
        customInfoView.snippet.frame.size.width = textWidth!
        
        var thumbnailWidth: CGFloat = 0
        var infoIconWidth: CGFloat = 0
        
        let locationInfo = marker.userData as! [String: String]
        if locationInfo["image"] == nil {
            customInfoView.thumbnail.isHidden = true
            
            // Shift visible controls to the left
            customInfoView.title.frame.origin.x -= customInfoView.infoIcon.frame.origin.x
            customInfoView.snippet.frame.origin.x -= customInfoView.infoIcon.frame.origin.x
            customInfoView.infoIcon.frame.origin.x = 0
        } else {
            customInfoView.thumbnail.image = UIImage(named: locationInfo["image"]!)
            thumbnailWidth = customInfoView.thumbnail.frame.size.width + 5
        }
        if locationInfo["url"] == nil {
            customInfoView.infoIcon.isHidden = true
            
            // Shift visible controls to the left
            customInfoView.title.frame.origin.x = 0
            customInfoView.snippet.frame.origin.x = 0
        } else {
            infoIconWidth = customInfoView.infoIcon.frame.size.width + 5
        }
        
        customInfoView.frame.size.width = thumbnailWidth + infoIconWidth + textWidth!
        return customInfoView
    }
}


// MARK: - Autocomplete View Controller Delegate Methods

extension GoogleMapViewController: GMSAutocompleteViewControllerDelegate {
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called when the user taps a search result.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        var streetName: String? = nil
        var address: String = ""
        
        // Loop through the addressComponents to find the street number and name
        for field in place.addressComponents! {
            switch field.type {
            case kGMSPlaceTypeStreetNumber:
                address = field.name + " "
            case kGMSPlaceTypeRoute:
                streetName = field.name
            default:
                break
            }
        }
        
        if streetName != nil {
            address += streetName!
        }
        
        // Create a marker for the search result
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        if place.website?.absoluteString == nil {
            marker.title = place.name
            marker.userData = [String: String]()
        } else {
            marker.title = place.name
            marker.userData = ["url": place.website?.absoluteString]
        }
        marker.snippet = address
        marker.map = mapView
        marker.icon = GMSMarker.markerImage(with: UIColor.blue)
        mapView.animate(toLocation: marker.position)
        
        // Return to the map view
        navigationController?.popViewController(animated: true)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called when an error occurred during a search.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // Display the error message
        let errorDlgBox = UIAlertController(title: "Search Error", message: error.localizedDescription, preferredStyle: .alert)
        errorDlgBox.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(errorDlgBox, animated: true)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called when the user canceled the search.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // Return to map view
        navigationController?.popViewController(animated: true)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

