//
//  FirstMapViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 03/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//


import UIKit
import GoogleMaps
import CoreLocation
import SwiftSpinner
import GooglePlaces
import Alamofire
import SwiftyJSON

class FirstMapViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, LocateOnTheMap {

    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    
    let locationManager = CLLocationManager()
    var NearVendors: Array<Loc> = [];
    var Markers: Array<GMSMarker> = [];

    var searchResultController:SearchResultsController!
    var resultsArray = [String]();
    var ActualLocation = Loc();
    var DestinyLocation = Loc();
    
    var isSearchingOrigin = false;
    var isManualAddress = false;
    var isLoadingOperators = false;
    var clickedOrder = false;
    var TimerForGetOp = Foundation.Timer();
    
    var isQuotation = false;

    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var RequestButton: UIButton!
    @IBOutlet weak var QuotationButton: UIButton!
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var MapViewContainer: UIView!

    @IBOutlet weak var LabelView: UIView!
    @IBOutlet weak var OriginLabel: UILabel!
    @IBOutlet weak var DestinyLabel: UILabel!

    @IBOutlet weak var OrderLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LOCATION SETTINGS:
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        
        //MAPVIEW SETTINGS
        MapView.delegate = self
        MapView.isMyLocationEnabled = true
        MapView.settings.myLocationButton = true;
        
        //LOCATION SETTINGS:
        searchResultController = SearchResultsController();
        searchResultController.delegate = self
        
        SwiftSpinner.show("Localizando Operadores...");

        
        addBorderUtility(x: 0, y: CGFloat(self.OriginLabel.frame.height - 1)  , width: CGFloat(self.OriginLabel.frame.width - 40), height: 1, color: UIColor(hexString: "FAE804"));

        //UI SETTINGS:
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.isQuotation = false;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_FirstMap")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    func presentSearchController(_ placeholder:String){
        let searchController = UISearchController(searchResultsController: searchResultController);
        searchController.searchBar.sizeToFit();
        searchController.hidesNavigationBarDuringPresentation = false;
        searchController.searchBar.placeholder = placeholder;
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil);
        
    }
    
    
    @IBAction func RequestAction(_ sender: AnyObject) {
        if(self.DestinyLocation.address != "") {
            self.performSegue(withIdentifier: "SolicitarSegue", sender: self);
        }else{
            self.alerta("Oops!", Mensaje: "Favor de seleccionar destino.");
        }
        
        let tracker = GAI.sharedInstance().defaultTracker;
        let eventTracker: NSObject = GAIDictionaryBuilder.createEvent(
            withCategory: "FirstMap",
            action: "RequestAction",
            label: "id:\(self.UsuarioEnSesion._id)",
            value: nil).build()
        tracker?.send(eventTracker as! [NSObject : AnyObject]);
    }
    
    @IBAction func QuotateAction(_ sender: Any) {
        if(self.DestinyLocation.address != ""){
            self.isQuotation = true;
            self.performSegue(withIdentifier: "SolicitarSegue", sender: self);
        }else{
            self.alerta("Oops!", Mensaje: "Favor de seleccionar destino.");
        }
        
        let tracker = GAI.sharedInstance().defaultTracker;
        let eventTracker: NSObject = GAIDictionaryBuilder.createEvent(
            withCategory: "FirstMap",
            action: "QuotationAction",
            label: "id:\(self.UsuarioEnSesion._id)",
            value: nil).build()
        tracker?.send(eventTracker as! [NSObject : AnyObject]);
    }
    
    func loadNearOperators(){
        if(!isLoadingOperators){
            self.isLoadingOperators = true;
            let AuthUrl = self.ApiUrl + "/users/byavailablevendors/bylocation/\(self.ActualLocation.lat)/\(self.ActualLocation.long)";
            let status = Reach().connectionStatus();
            let headers = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            switch status {
            case .online(.wwan), .online(.wiFi):
                Alamofire.request(AuthUrl, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    
                    if response.result.isSuccess {
                        let data = JSON(data: response.data!);
                        if(data["success"] == true){
                            self.NearVendors = [];
                            
                            for (_,vendor):(String,JSON) in data["vendors"] {
                                
                                var tmp:Loc = Loc();
                                
                                tmp.long = vendor["loc"]["cord"][0].doubleValue;
                                tmp.lat = vendor["loc"]["cord"][1].doubleValue;
                                tmp.address = vendor["marketname"].stringValue;
                                
                                self.NearVendors.append(tmp);
                            }
                            self.isLoadingOperators = false;
                            self.DrawOnMapViewVendors();
                        }else{
                            self.isLoadingOperators = false;
                            if response.response?.statusCode == 403 {
                                if let parent = self.parent as? ViewController {
                                    parent.logOut();
                                }
                            }else{
                                self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                            }
                        }
                    }else{
                        self.isLoadingOperators = false;
                        self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                    }
                }
            case .unknown, .offline:
                //No internet connection:
                self.isLoadingOperators = false;
                self.alerta("Oops!", Mensaje: "Favor de conectarse a internet");
            }
        }
    }
    
    func DrawOnMapViewVendors(){
        
        self.MapView.clear();

        
        if self.NearVendors.count > 0{
            
            self.RequestButton.isHidden = false;
            self.RequestButton.setTitle("SOLICITAR", for: .normal);
            self.RequestButton.isUserInteractionEnabled = true;
            self.QuotationButton.isHidden = false;
            self.QuotationButton.setTitle("COTIZAR", for: .normal);
            self.QuotationButton.isUserInteractionEnabled = true;
            
            for m in self.Markers {
                m.map = nil;
            }
            self.Markers = [];
            
            for vendor in self.NearVendors {
                let  position = CLLocationCoordinate2DMake(vendor.lat, vendor.long);
                let marker = GMSMarker(position: position);
                //marker.appearAnimation = kGMSMarkerAnimationPop;
                marker.icon = UIImage(named: "TowIcon.png");
                marker.title = vendor.address;
                marker.map = self.MapView;
                self.Markers.append(marker);
            }
            if self.Markers.count > 0 {
                self.MapView.selectedMarker = self.Markers[0];
            }
            SwiftSpinner.hide();
            
        }else{
            SwiftSpinner.hide();
            self.alerta("Lo sentimos", Mensaje: "Por el momento no hay operadores activos en su zona.");
            
            self.RequestButton.isHidden = true;
            self.RequestButton.isUserInteractionEnabled = false;
            self.QuotationButton.isHidden = true;
            self.QuotationButton.isUserInteractionEnabled = false;
        }
    }
    
    
    @IBAction func SearchOrigin(_ sender: AnyObject) {
        self.isSearchingOrigin = true;
        self.presentSearchController(self.ActualLocation.address);
    }
    
    @IBAction func SearchDestiny(_ sender: AnyObject) {
        self.isSearchingOrigin = false;
        self.presentSearchController("Direccion de destino")
    }
    
    
    
    //PASS DATA THROW THE SOLICITAR VIEW;
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SolicitarSegue" {
            if let destination = segue.destination as? RequestViewController {
                destination.Request.origin = self.ActualLocation;
                destination.Request.destiny = self.DestinyLocation;
                destination.isQuotation = self.isQuotation;
            }
        }
    }
    
    
    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    /// LOCATION MANAGER METHODS:
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation();
            MapView.isMyLocationEnabled = true
            MapView.settings.myLocationButton = true
        }
    }
    
    // if the users is moving of something like that.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        MapView.camera = GMSCameraPosition(target: locations.last!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0);
        locationManager.stopUpdatingLocation();
        geoCode(locations.first!);
        
    }

    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    //SEARCH BAR METHODS
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let lat = self.ActualLocation.lat;
        let long = self.ActualLocation.long;
        
        let offset = 200.0 / 1000.0;
        let latMax = lat + offset;
        let latMin = lat - offset;
        let lngOffset = offset * cos(lat * M_PI / 200.0);
        let lngMax = long + lngOffset;
        let lngMin = long - lngOffset;
        let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
        let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
        
        
        let placesClient = GMSPlacesClient();
        let Filter = GMSAutocompleteFilter();
        let Bounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)

        Filter.type = .address
        Filter.country = "AR";
        placesClient.autocompleteQuery("\(searchText)", bounds: Bounds, filter: Filter, callback: {
            (results, error) -> Void in
            self.resultsArray.removeAll()
            if results == nil {
                return
            }
            for result in results!{
                self.resultsArray.append(result.attributedFullText.string)
            }
            self.searchResultController.reloadDataWithArray(self.resultsArray)
        })
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.LabelView.isHidden = true;
        return true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.LabelView.isHidden = false;
    }
    
    func changeManualStatus(_ status: Bool) {
        self.isManualAddress = status;
        
        self.TimerForGetOp = Foundation.Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(FirstMapViewController.loadNearOperators), userInfo: nil, repeats: false);
        RunLoop.main.add(self.TimerForGetOp, forMode: RunLoopMode.commonModes);
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        if(self.isSearchingOrigin){
            self.OriginLabel.text = title;
            self.ActualLocation.lat = lat;
            self.ActualLocation.long = lon;
            self.ActualLocation.address = title;
            
        }else{
            self.DestinyLabel.text = title;
            self.DestinyLocation.lat = lat;
            self.DestinyLocation.long = lon;
            self.DestinyLocation.address = title;
        }
        
        DispatchQueue.main.async { () -> Void in
            if(self.isSearchingOrigin){
                let Camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 19);
                self.MapView.camera = Camera;
            }

        }
    }
    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    
    func geoCode(_ location : CLLocation!){
        /* Only one reverse geocoding can be in progress at a time hence we need to cancel existing
         one if we are getting location updates */
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(location.coordinate.latitude),\(location.coordinate.longitude)&sensor=false&key=\(VARS().getGoogleKey())";
        Alamofire.request(url, encoding: JSONEncoding.default).responseJSON { response in
            if response.result.isSuccess {
                let data = JSON(data: response.data!);
                let address = data["results"][0]["formatted_address"].stringValue;
                self.OriginLabel.text = address;
                self.ActualLocation.long = location.coordinate.longitude;
                self.ActualLocation.lat = location.coordinate.latitude;
                self.ActualLocation.address = address;
                
                self.TimerForGetOp = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(FirstMapViewController.loadNearOperators), userInfo: nil, repeats: false);
                RunLoop.main.add(self.TimerForGetOp, forMode: RunLoopMode.commonModes);
                
            }else{
                self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
            }
        }
    }
    
    
    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    /// GOOGLE MAPS MANAGER METHODS:
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if(!isManualAddress){
            let newLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude);
            geoCode(newLocation);
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if (gesture) {
            self.isManualAddress = false;
            mapView.selectedMarker = nil
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
    
    func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        self.OriginLabel.layer.addSublayer(border)
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func alertWithCall(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let callAction = UIAlertAction(title: "Llamar", style: UIAlertActionStyle.default) {
            UIAlertAction in
            let phoneNumber: String = "tel://5556839645";
            UIApplication.shared.openURL(URL(string:phoneNumber)!);
        }
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            UIAlertAction in
        }
        alertController.addAction(okAction);
        alertController.addAction(callAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
}
