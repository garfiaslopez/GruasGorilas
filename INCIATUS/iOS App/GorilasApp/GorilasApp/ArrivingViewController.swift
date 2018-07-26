//
//  ArrivingViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 23/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON

class ArrivingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , CLLocationManagerDelegate, GMSMapViewDelegate  {
    
    var Order = OrderModel();
    let locationManager = CLLocationManager()
    var MarkersArray:Array<GMSMarker> = [];
    var ActualLocation = Loc();
    var UsuarioEnSesion:Session = Session();
    var OrderDetailArray:Array<[String:String]> = [];
    var isClickedConfirm = false;
    var isClickedCancel = false;
    var Timer = Foundation.Timer();

    @IBOutlet weak var MainTableView: UITableView!
    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var AcceptButton:UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var TimeLabel: UILabel!
    
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
        
        
        self.Timer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ArrivingViewController.drawOriginMarker), userInfo: nil, repeats: false);
        RunLoop.main.add(self.Timer, forMode: RunLoopMode.commonModes);
        
        self.DrawMarker(self.Order.oper.lat, Long: self.Order.oper.long, title: self.Order.oper.name);
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Arriving")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    func drawOriginMarker() {
        
        self.DrawMarker(self.ActualLocation.lat, Long: self.ActualLocation.long, title: "Origen");
        self.locateWithLongitude(self.ActualLocation.long, andLatitude: self.ActualLocation.lat, andTitle: "");
        self.Timer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ArrivingViewController.FocusMapOnAllMarkers), userInfo: nil, repeats: false);
        RunLoop.main.add(self.Timer, forMode: RunLoopMode.commonModes);
        
        self.addOverlayToMapView();
        self.locationManager.stopUpdatingLocation();
    }
    
    func reloadData() {
        self.OrderDetailArray = [];
        
        // USER:
        self.OrderDetailArray.append(["title": "NOMBRE DEL OPERADOR", "value": "\(self.Order.oper.name)   |   \(round(self.Order.oper.rate)) Estrellas","icon":"Profile.png"]);
        self.OrderDetailArray.append(["title": "\(self.Order.group.uppercased())", "value": self.Order.tow,"icon":"TowTruck.png"]);
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
    
    @IBAction func ToDestiny(_ sender: AnyObject) {
        
        if (self.isClickedConfirm == false) {
            self.isClickedConfirm = true;
            SocketIOManager.sharedInstance.SendState(self.Order._id, user_id: self.UsuarioEnSesion._id, state: "ToDestiny");
        }
    }
    
    @IBAction func CallUser(_ sender: AnyObject) {
        let phoneNumber: String = "tel://\(self.Order.oper.phone)";
        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }
    
    @IBAction func OpenWazeNav(_ sender: AnyObject) {
        let waze: String = "waze://?ll=<\(self.Order.origin.lat)>,<\(self.Order.origin.long)>&navigate=yes";
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
    
    func DrawMarker(_ Lat:Double, Long: Double, title:String) {
        
        let  position = CLLocationCoordinate2DMake(Lat, Long);
        let marker = GMSMarker(position: position);
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
    
    func addPolyLineWithEncodedStringInMap(_ encodedString: String) {
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = UIColor.red
        polyLine.map = self.MapView;
    }
    
    func addOverlayToMapView(){
        
        print("ADDING OVERLAY");
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.Order.oper.lat),\(self.Order.oper.long)&destination=\(self.ActualLocation.lat),\(self.self.ActualLocation.long)&mode=driving&key=\(VARS().getGoogleKey())";
        
        Alamofire.request(directionURL).responseJSON { response in
            print(response);
            if response.result.isSuccess {
                let json = JSON(data: response.data!);
                let errornum = json["error"]
                if (errornum == true){
                }else{
                    let routes = json["routes"].array
                    if routes != nil{
                        if (routes?.count)! > 0 {
                            print(routes![0]);
                            
                            //let Distance = routes![0]["legs"][0]["distance"]["text"].stringValue;
                            let Time = routes![0]["legs"][0]["duration"]["text"].stringValue;
                            
                            self.TimeLabel.text = Time;
                            
                            let overViewPolyLine = routes![0]["overview_polyline"]["points"].string
                            if overViewPolyLine != nil{
                                print("ADDING POLYLINE");
                                self.addPolyLineWithEncodedStringInMap(overViewPolyLine!)
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
        locationManager.stopUpdatingLocation();
        
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

