//
//  AppleMapSearchViewController.swift
//  TTTMaps
//
//  Created by bl on 8/22/17.
//  Copyright © 2017 bl. All rights reserved.
//


import UIKit
import MapKit


private var searchResultCache = [MapPin]()


protocol SearchResultDelegate: class {
    func userDidFind(location: MapPin)
}


class AppleMapSearchViewController: UITableViewController {

    public var mapViewRegion: MKCoordinateRegion?
    public weak var delegate: SearchResultDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(mapViewRegion != nil, "Error: property mapViewRegion not set.")

        title = "Search"
    }

    // MARK: - Table View Data Source Methods
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called to determine the number of sections to display.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method to load a row for display.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.text = searchResultCache[indexPath.row].title
        cell?.detailTextLabel?.text = searchResultCache[indexPath.row].subtitle
        
        return cell!
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called to determine the number of rows to display.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultCache.count
    }
    
    // MARK: - Table View Delegate Methods
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called when a user taps on a cell.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if delegate != nil {
            delegate!.userDidFind(location: searchResultCache[indexPath.row])
        }
        
        navigationController?.popViewController(animated: true)
    }
}


extension AppleMapSearchViewController: UISearchBarDelegate, UISearchDisplayDelegate {
    
    // MARK: - Search Delegate Methods
    
    //////////////////////////////////////////////////////////////////////////////////////////
    //
    //  Delegate method called when user changes the text in search bar.
    //
    //////////////////////////////////////////////////////////////////////////////////////////
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = mapViewRegion!
        
        let search = MKLocalSearch(request: request)
        
        if search.isSearching {
            search.cancel()
        }
        
        search.start(completionHandler: { (response, error) in
            // Clear the cache for the new results
            searchResultCache.removeAll()
            
            if error != nil {
                DispatchQueue.main.async {
                    let errorDlgBox = UIAlertController(title: "Search Error", message: error!.localizedDescription, preferredStyle: .alert)
                    errorDlgBox.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(errorDlgBox, animated: true)
                }
            } else {
                for item in response!.mapItems {
                    var address: String = item.placemark.subThoroughfare == nil ? "" : item.placemark.subThoroughfare!
                    if item.placemark.thoroughfare != nil {
                        address = address + " " + item.placemark.thoroughfare!
                    }
                    
                    let pin = MapPin(title: item.name!, subtitle: address, coordinate: item.placemark.coordinate, color: UIColor.blue, imageName: nil, url: item.url?.absoluteString)
                    searchResultCache.append(pin)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
}
