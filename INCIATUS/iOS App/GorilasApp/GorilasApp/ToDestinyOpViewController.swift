//
//  ToDestinyOpViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 21/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON

class ToDestinyOpViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , CLLocationManagerDelegate, GMSMapViewDelegate  {
    
    var Order = OrderModel();
    let locationManager = CLLocationManager()
    var MarkersArray:Array<GMSMarker> = [];
    var ActualLocation = Loc();
    var UsuarioEnSesion:Session = Session();
    var OrderDetailArray:Array<[String:String]> = [];
    var isClickedConfirm = false;
    var isClickedCancel = false;
    var Timer = Foundation.Timer();
    var isSchedule = false;

    @IBOutlet weak var MainTableView: UITableView!
    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var AcceptButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        //LOCATION SETTINGS:
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        
        //MAPVIEW SETTINGS
        MapView.delegate = self;
        MapView.isMyLocationEnabled = true
        MapView.settings.myLocationButton = true;
        
        let nib = UINib(nibName: "OrderTableViewCell", bundle: nil);
        self.MainTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        self.reloadData();
        
        
        self.Timer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ToDestinyOpViewController.drawOriginMarker), userInfo: nil, repeats: false);
        RunLoop.main.add(self.Timer, forMode: RunLoopMode.commonModes);
        
        if (self.Order.destiny.address != "Sin direccion" && self.Order.destiny.address != "") {
            self.DrawMarker(self.Order.destiny.lat, Long: self.Order.destiny.long, title: "Destino", color: UIColor.green);
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        if(self.isSchedule) {
            return true;
        }
        return false;
    }
    
    func drawOriginMarker() {

        self.DrawMarker(self.ActualLocation.lat, Long: self.ActualLocation.long, title: "Origen", color: UIColor.blue);
        self.locateWithLongitude(self.ActualLocation.long, andLatitude: self.ActualLocation.lat, andTitle: "");
        self.addOverlayToMapView();
        
        self.Timer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ToDestinyOpViewController.FocusMapOnAllMarkers), userInfo: nil, repeats: false);
        RunLoop.main.add(self.Timer, forMode: RunLoopMode.commonModes);

        self.locationManager.stopUpdatingLocation();
    }
    
    func reloadData() {
        self.OrderDetailArray = [];
        
        // USER:
        self.OrderDetailArray.append(["title": "NOMBRE DEL USUARIO", "value": "\(self.Order.user.name)   |   \(round(self.Order.user.rate)) Estrellas","icon":"Profile.png"]);
        self.OrderDetailArray.append(["title": "ORIGEN", "value": self.Order.origin.address,"icon":"Home.png"]);
        self.OrderDetailArray.append(["title": "DESTINO", "value": self.Order.destiny.address,"icon":"MapMarker.png"]);
        
        self.OrderDetailArray.append(["title": "AUTOMÓVIL", "value": self.Order.carinfo,"icon":"Car.png"]);
        self.OrderDetailArray.append(["title": "CONDICIONES", "value": self.Order.conditions,"icon":"Wheel.png"]);
        
        self.MainTableView.reloadData();
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.OrderDetailArray.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:OrderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! OrderTableViewCell;
        cell.selectionStyle = .none;
        cell.TitleLabel.text = self.OrderDetailArray[(indexPath as NSIndexPath).row]["title"];
        let image = UIImage(named: self.OrderDetailArray[(indexPath as NSIndexPath).row]["icon"]!);
        cell.IconImageView.image = image;
        cell.SubtitleLabel.text = self.OrderDetailArray[(indexPath as NSIndexPath).row]["value"];
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.alerta(self.OrderDetailArray[(indexPath as NSIndexPath).row]["title"]!, Mensaje: self.OrderDetailArray[(indexPath as NSIndexPath).row]["value"]!);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.FocusMapOnAllMarkers();
    }
    
    @IBAction func EndTravel(_ sender: AnyObject) {
        
        if ( self.isSchedule) {
            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "EndScheduleOrder");
            self.presentingViewController?.presentingViewController?.performSegueToReturnBack();
        }else{
            if (self.isClickedConfirm == false) {
                self.isClickedConfirm = true;
                SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "EndTravel");
            }
        }
    }
    
    @IBAction func CallUser(_ sender: AnyObject) {
        let phoneNumber: String = "tel://\(self.Order.user.phone)";
        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }
    
    @IBAction func OpenWazeNav(_ sender: AnyObject) {
        let waze: String = "waze://?ll=\(self.Order.destiny.lat),\(self.Order.destiny.long)&navigate=yes";
        UIApplication.shared.openURL(URL(string:waze)!);
    }
    
    func FitMarkers() {
        print("FIT MARKERS");
        if (self.MarkersArray.count >= 2 ){
            var bounds = GMSCoordinateBounds(coordinate: self.MarkersArray[0].position, coordinate: self.MarkersArray[1].position);
            
            for marker in self.MarkersArray {
                bounds = bounds.includingCoordinate(marker.position);
            }
            
            let markerBoundsTopLeft = self.MapView.projection.point(for: CLLocationCoordinate2D(latitude: bounds.northEast.latitude, longitude: bounds.southWest.longitude));
            
            let markerBoundsBottomRight = self.MapView.projection.point(for: CLLocationCoordinate2D(latitude: bounds.southWest.latitude, longitude: bounds.northEast.longitude));
            
            let currentLocation = self.MapView.projection.point(for: CLLocationCoordinate2D(latitude: self.ActualLocation.lat, longitude: self.ActualLocation.long));
            
            let markerBoundsCurrentLocationMaxDelta = CGPoint(x: max(fabs(currentLocation.x - markerBoundsTopLeft.x), fabs(currentLocation.x - markerBoundsBottomRight.x)), y: max(fabs(currentLocation.y - markerBoundsTopLeft.y), fabs(currentLocation.y - markerBoundsBottomRight.y)));
            
            let centeredMarkerBoundsSize = CGSize(width: 2.0 * markerBoundsCurrentLocationMaxDelta.x, height: 2.0 * markerBoundsCurrentLocationMaxDelta.y);
            
            let insetViewBoundsSize = CGSize(width: self.MapView.bounds.size.width - 0 / 2.0 - 0, height: self.MapView.bounds.size.height - 0 / 2.0 - 0);
            
            var x1 = CGFloat();
            var x2 = CGFloat();
            
            if (centeredMarkerBoundsSize.width / centeredMarkerBoundsSize.height > insetViewBoundsSize.width / insetViewBoundsSize.height) {
                x1 = centeredMarkerBoundsSize.width;
                x2 = insetViewBoundsSize.width;
            } else {
                x1 = centeredMarkerBoundsSize.height;
                x2 = insetViewBoundsSize.height;
            }
            
            let zoom = log2(x2 * CGFloat(pow(2, self.MapView.camera.zoom)) / x1);
            
            let camera = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2D(latitude: self.ActualLocation.lat, longitude: self.ActualLocation.long), zoom: Float(zoom));
            self.MapView.animate(to: camera);
            
            
        }
    }
    
    func FocusMapOnAllMarkers() {
        
        var bounds = GMSCoordinateBounds(coordinate: MarkersArray[0].position, coordinate: MarkersArray[0].position);
        for marker in self.MarkersArray {
            bounds = bounds.includingCoordinate(marker.position);
            print(bounds);
        }
        
        let Camera  = GMSCameraUpdate.fit(bounds, withPadding: 15.0);
        self.MapView.animate(with: Camera);
        
    }
    
    func DrawMarker(_ Lat:Double, Long: Double, title:String, color: UIColor) {
        
        let  position = CLLocationCoordinate2DMake(Lat, Long);
        let marker = GMSMarker(position: position);
        marker.icon = GMSMarker.markerImage(with: color);
        marker.appearAnimation = GMSMarkerAnimation.pop;
        marker.title = title;
        marker.isFlat = true;
        marker.map = self.MapView;
        
        self.MarkersArray.append(marker);
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        
        DispatchQueue.main.async { () -> Void in
            let Camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15);
            self.MapView.camera = Camera;
        }
    }
    
    func addPolyLineWithEncodedStringInMap(_ encodedString: String, color: UIColor) {
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = color
        polyLine.map = self.MapView;
    }
    
    func addOverlayToMapView(){
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.ActualLocation.lat),\(self.ActualLocation.long)&destination=\(self.Order.destiny.lat),\(self.Order.destiny.long)&mode=driving&key=\(VARS().getGoogleKey())";
        
        Alamofire.request(directionURL).responseJSON { response in
            
            if response.result.isSuccess {
                let json = JSON(data: response.data!);
                let errornum = json["error"]
                if (errornum == true){
                }else{
                    let routes = json["routes"].array
                    if routes != nil{
                        if (routes?.count)! > 0 {
                            print(routes![0]);
                            
                            let Distance = routes![0]["legs"][0]["distance"]["text"].stringValue;
                            let Time = routes![0]["legs"][0]["duration"]["text"].stringValue;
                            
                            self.OrderDetailArray.append(["title": "HACIA DESTINO DE USUARIO", "value": "\(Distance)   |   \(Time)","icon":"MapMarker.png"]);

                            
                            self.MainTableView.reloadData();
                            
                            let overViewPolyLine = routes![0]["overview_polyline"]["points"].string
                            if overViewPolyLine != nil{
                                self.addPolyLineWithEncodedStringInMap(overViewPolyLine!, color: UIColor.green);
                            }
                        }
                    }
                }
            }else{
                print("Failure");
            }
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("DIDCHANGEAUTH");
            locationManager.startUpdatingLocation();
            MapView.isMyLocationEnabled = true
            MapView.settings.myLocationButton = true
        }
    }
    
    // if the users is moving of something like that.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        MapView.camera = GMSCameraPosition(target: locations.last!.coordinate, zoom: 15, bearing: 0, viewingAngle: 0);
        self.ActualLocation.lat = locations.first!.coordinate.latitude;
        self.ActualLocation.long = locations.first!.coordinate.longitude;
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert);
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            print("Ok Pressed");
        }
        alertController.addAction(okAction);
        self.present(alertController, animated: true, completion: nil)
    }
    
}
