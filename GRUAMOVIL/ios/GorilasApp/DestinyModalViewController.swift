//
//  DestinyModalViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 10/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import SwiftSpinner
import Alamofire
import SwiftyJSON
import GooglePlaces


class DestinyModalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating,UISearchControllerDelegate  {

    var resultsArray = [String]();
    let locationManager = CLLocationManager()
    var resultSearchController = UISearchController()

    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var LocationsTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self;
            controller.delegate = self;
            controller.dimsBackgroundDuringPresentation = false;
            controller.searchBar.sizeToFit()
            controller.hidesNavigationBarDuringPresentation = true;
        
            self.LocationsTableView.tableHeaderView = controller.searchBar
            return controller
        })();
        
        self.LocationsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell");

    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        DispatchQueue.main.async { () -> Void in
            if let parent = self.presentingViewController as? RequestViewController {
                
                parent.Request.destiny.address = title;
                parent.Request.destiny.lat = lat;
                parent.Request.destiny.long = lon;
            }
            SwiftSpinner.hide();
            if(self.resultSearchController.isActive){
                self.dismiss(animated: true, completion: nil);
            }
            self.dismiss(animated: true, completion: nil);
        }
    }
    
    func updateSearchResults(for searchController: UISearchController){
        
        let searchText = searchController.searchBar.text;
        if (searchText != ""){
            let placesClient = GMSPlacesClient();
            
            let Filter = GMSAutocompleteFilter();
            Filter.type = .address
            Filter.country = "MX";

            placesClient.autocompleteQuery("\(searchText)", bounds: nil, filter: Filter, callback: {
                (results, error) -> Void in
                self.resultsArray.removeAll();
                if results == nil {
                    return
                }
                for result in results!{
                    self.resultsArray.append(result.attributedFullText.string);
                }
            });
        } else {
            self.resultsArray = [];
        }
        self.LocationsTableView.reloadData();
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.resultsArray.count == 0){
            return 1;
        }
        return resultsArray.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell;
        
        if(self.resultsArray.count == 0){
            
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.font = UIFont(name: "Roboto-Regular.ttf", size: 22);
            cell.textLabel?.textColor = UIColor.gray;
            cell.textLabel?.text = "Sin Resultados.";
            cell.textLabel?.textAlignment = NSTextAlignment.center;
            cell.isUserInteractionEnabled = false;
            
        }else{
            
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.font = UIFont(name: "Roboto-Regular.ttf", size: 14);
            cell.textLabel!.textColor = UIColor(red: 255/255, green: 111/255, blue: 0/255, alpha: 1);
            cell.textLabel?.text = self.resultsArray[(indexPath as NSIndexPath).row];
            cell.textLabel?.textAlignment = NSTextAlignment.left;
            cell.isUserInteractionEnabled = true;
            
        }
        return cell;
    }
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SwiftSpinner.show("Guardando...");
        let correctedAddress:String! = self.resultsArray[(indexPath as NSIndexPath).row].addingPercentEncoding(withAllowedCharacters: CharacterSet.symbols);
        print(correctedAddress);
        let url = "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress)&sensor=false";
        Alamofire.request(url, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                let data = JSON(data: response.data!);
                let lat = data["results"][0]["geometry"]["location"]["lat"].doubleValue;
                let lon = data["results"][0]["geometry"]["location"]["lng"].doubleValue;
                self.locateWithLongitude(lon, andLatitude: lat, andTitle: self.resultsArray[indexPath.row]);
            }else{
                print((response.result.error?.localizedDescription)!);
            }
        }
    }

    @IBAction func CancelModal(_ sender: AnyObject) {
        if(self.resultSearchController.isActive){
            self.dismiss(animated: true, completion: nil);
        }
        self.dismiss(animated: true, completion: nil);
    }
    

}
