//
//  DetailFullOrderViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 2/6/17.
//  Copyright © 2017 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import SwiftyJSON


class DetailFullOrderViewController: UIViewController,UITableViewDelegate, UITableViewDataSource , GMSMapViewDelegate {

    let Format = Formatter();
    let Variables = VARS();
    let Save = UserDefaults.standard;
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();

    var Order = OrderModel();
    var isQuotation = false;
    var MarkersArray:Array<GMSMarker> = [];
    var OrderDetailArray:Array<[String:String]> = [];
    
    
    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var QuotationButton: UIButton!
    @IBOutlet weak var MainTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        MapView.delegate = self;
        MapView.isMyLocationEnabled = true
        MapView.settings.myLocationButton = true;
        
        let nib = UINib(nibName: "OrderTableViewCell", bundle: nil);
        self.MainTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        self.reloadData();
        
        self.DrawMarker(self.Order.origin.lat, Long: self.Order.origin.long, title: "Origen", color: UIColor.red);
        self.locateWithLongitude(self.Order.origin.long, andLatitude: self.Order.origin.lat, andTitle: "");
        if (self.Order.destiny.address != "Sin direccion" && self.Order.destiny.address != "") {
            self.DrawMarker(self.Order.destiny.lat, Long: self.Order.destiny.long, title: "Destino", color: UIColor.green);
            self.addOverlayToMapView();
        }
        
        self.QuotationButton.isHidden = true;
        
        if (self.UsuarioEnSesion.typeuser == "user") {
            if(isQuotation) {
                self.QuotationButton.setTitle("Ordenar Servicio", for: .normal);
                self.QuotationButton.isHidden = false;
            }
        }else{
            if(!isQuotation){
                self.QuotationButton.setTitle("Empezar Viaje", for: .normal);
                self.QuotationButton.isHidden = false;
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.FocusMapOnAllMarkers();
    }
    
    func reloadData() {
        self.OrderDetailArray = [];
        
        if (self.UsuarioEnSesion.typeuser == "user"){
            self.OrderDetailArray.append(["title": "NOMBRE DEL OPERADOR", "value": "\(self.Order.oper.name)   |   \(self.Order.oper.rate) Estrellas","icon":"Profile.png"]);
        }else{
            self.OrderDetailArray.append(["title": "NOMBRE DEL USUARIO", "value": "\(self.Order.user.name)   |   \(self.Order.user.rate) Estrellas","icon":"Profile.png"]);
        }
        if (self.UsuarioEnSesion.typeuser == "user"){
            self.OrderDetailArray.append(["title": "TELEFONO DEL OPERADOR", "value": "\(self.Order.oper.phone)","icon":"PhoneCallMenu.png"]);
        }else{
            self.OrderDetailArray.append(["title": "TELEFONO DEL USUARIO", "value": "\(self.Order.user.phone)","icon":"PhoneCallMenu.png"]);
        }
        
        if (self.UsuarioEnSesion.typeuser == "user") {
            self.OrderDetailArray.append(["title": "\(self.Order.group.uppercased())", "value": self.Order.tow,"icon":"TowTruck.png"]);
        }
        
        let str = Formatter().FullDatePretty.string(from: self.Order.dateSchedule);
        self.OrderDetailArray.append(["title": "FECHA", "value": str,"icon":"CalendarMenu.png"]);

        //self.OrderDetailArray.append(["title": "FECHA", "value": "INMEDIATAMENTE","icon":"CalendarMenu.png"]);

        self.OrderDetailArray.append(["title": "ORIGEN", "value": self.Order.origin.address,"icon":"Home.png"]);
        self.OrderDetailArray.append(["title": "DESTINO", "value": self.Order.destiny.address,"icon":"MapMarker.png"]);
        
        self.OrderDetailArray.append(["title": "AUTOMÓVIL", "value": self.Order.carinfo,"icon":"Car.png"]);
        self.OrderDetailArray.append(["title": "CONDICIONES", "value": self.Order.conditions,"icon":"Wheel.png"]);
        self.OrderDetailArray.append(["title": "LLAMAR A CABINA", "value": "(55) 56 83 96 45","icon":"PhoneCallMenu.png"]);

        
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
        
        if (indexPath.row == (self.OrderDetailArray.count - 2)) {
            let phoneNumber: String = "tel://5556839645";
            UIApplication.shared.openURL(URL(string:phoneNumber)!);
        }else if (indexPath.row == 1) {
            let phoneNumber: String = "tel://\(self.OrderDetailArray[1]["value"]!)";
            print(phoneNumber);
            UIApplication.shared.openURL(URL(string:phoneNumber)!);
        } else {
            self.alerta(self.OrderDetailArray[(indexPath as NSIndexPath).row]["title"]!, Mensaje: self.OrderDetailArray[(indexPath as NSIndexPath).row]["value"]!);
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToOriginSegue" {
            if let dest = segue.destination as? ToOriginOpViewController {
                dest.Order = self.Order;
                dest.isSchedule = true;
            }
        }
    }
    
    @IBAction func OrderNow(_ sender: Any) {
        
        if(self.UsuarioEnSesion.typeuser == "user") {
            
            
            
        }else{
            // just invoke onRouteView and make call to socket endpoint for chanfe isSChedule = false isQuotation = false.
            self.performSegue(withIdentifier: "ToOriginSegue", sender: self);
        }
        
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
    
    func FocusMapOnAllMarkers() {
        var bounds = GMSCoordinateBounds(coordinate: MarkersArray[0].position, coordinate: MarkersArray[0].position);
        for marker in self.MarkersArray {
            bounds = bounds.includingCoordinate(marker.position);
        }
        let Camera  = GMSCameraUpdate.fit(bounds, withPadding: 15.0);
        self.MapView.animate(with: Camera);
        
    }
    
    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {
        DispatchQueue.main.async { () -> Void in
            let Camera  = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15);
            self.MapView.camera = Camera;
        }
    }
    
    func addOverlayToMapView(){
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(self.Order.origin.lat),\(self.Order.origin.long)&destination=\(self.Order.destiny.lat),\(self.Order.destiny.long)&mode=driving&key=\(VARS().getGoogleKey())";
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
                            self.OrderDetailArray.append(["title": "TIEMPO DE VIAJE", "value": "\(Distance)   |   \(Time)","icon":"MapMarker.png"]);
                            self.MainTableView.reloadData();
                            let overViewPolyLine = routes![0]["overview_polyline"]["points"].string
                            if overViewPolyLine != nil{
                                self.addPolyLineWithEncodedStringInMap(overViewPolyLine!, color: UIColor.green)
                            }
                        }
                    }
                }
            }else{
                print("Failure");
            }
        }
    }
    
    func addPolyLineWithEncodedStringInMap(_ encodedString: String, color: UIColor) {
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        let polyLine = GMSPolyline(path: path)
        polyLine.strokeWidth = 5
        polyLine.strokeColor = color
        polyLine.map = self.MapView;
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

extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
