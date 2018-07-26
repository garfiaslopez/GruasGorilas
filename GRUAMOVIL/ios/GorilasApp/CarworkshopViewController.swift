//
//  CarworkshopViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 15/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//


import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner
import GoogleMaps

class CarworkshopViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate,CLLocationManagerDelegate, GMSMapViewDelegate {

    var UsuarioEnSesion:Session = Session();
    let ApiUrl = VARS().getApiUrl();
    let Format = Formatter();
    
    var Refresh:UIRefreshControl!;
    var CarworkshopsArray:Array<CarworkshopTemplate> = [];
    var ImagesCache = [Int:UIImage](); //Dictionary<Int, UIImage>();
    
    var SelectedCell:Int = 0;
    var ActualFilter:String = "ALL";
    var SelectedCarworkshop: Int!;
    
    var categoriesArray = ["ALL","talleres", "gomerias", "repuesteras","estServicios", "estacionamientos","farmacias","cerrajeria"];
    var categoriesLabel = ["Todos","Talleres Mecanicos", "Gomerias", "Repuesteras", "Estaciones de Servicio", "Estacionamientos", "Farmacias","Cerrajeria"];
    
    let locationManager = CLLocationManager()
    var NearVendors: Array<Loc> = [];
    var Markers: Array<GMSMarker> = [];
    
    var pickerCategory = UIPickerView();
    
    
    @IBOutlet weak var MapView: GMSMapView!
    @IBOutlet weak var CategoryTextfield: UITextField!

    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var CarworkshopsTableView: UITableView!

    @IBOutlet weak var typeSegment: UISegmentedControl!
    
    @IBOutlet weak var TopTableViewLayout: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LOCATION SETTINGS:
        self.locationManager.delegate = self;
        self.locationManager.requestWhenInUseAuthorization();
        self.locationManager.startUpdatingLocation();
        
        //MAPVIEW SETTINGS
        self.MapView.delegate = self
        self.MapView.isMyLocationEnabled = true
        self.MapView.settings.myLocationButton = true;
        
        self.pickerCategory.delegate = self;
        self.pickerCategory.dataSource = self;
        self.pickerCategory.showsSelectionIndicator = true;
        
        let doneButton = UIBarButtonItem(title: "Aceptar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker(sender:)));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancelar", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker(sender:)))
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.CategoryTextfield.text = self.categoriesLabel[0];
        self.CategoryTextfield.inputView = pickerCategory;
        self.CategoryTextfield.inputAccessoryView = toolBar;
        self.CategoryTextfield.tintColor = .clear;
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Talleres")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.title = "Servicios";
        
        if(self.UsuarioEnSesion.token == "" && self.UsuarioEnSesion.name == ""){
            self.performSegue(withIdentifier: "LoginSegue", sender: self);
        }else{
            self.ReloadData();
        }
    }
    
    func ReloadData(){
        SwiftSpinner.show("Cargando Catalogo");
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            let GETURL = ApiUrl + "/carworkshop/by/type/" + self.ActualFilter;
            let headers: HTTPHeaders = [
                "Authorization": self.UsuarioEnSesion.token
            ]
            Alamofire.request(GETURL, encoding: JSONEncoding.default , headers: headers).responseJSON { response in
                
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        print(data);
                        self.CarworkshopsArray = [];
                        self.ImagesCache = [:];
                        
                        for (_,carworkshop):(String,JSON) in data["carworkshops"] {
                            
                            var tmp:CarworkshopTemplate = CarworkshopTemplate();
                            
                            tmp.id = carworkshop["_id"].stringValue;
                            tmp.name = carworkshop["name"].stringValue;
                            tmp.description = carworkshop["description"].stringValue;
                            tmp.havePromo = carworkshop["promo"]["active"].boolValue;
                            tmp.promo = carworkshop["promo"]["description"].stringValue;
                            tmp.phone = carworkshop["phone"].stringValue;
                            tmp.firstPhoto = carworkshop["firstPhoto"].stringValue;
                            tmp.secondPhoto = carworkshop["secondPhoto"].stringValue;
                            tmp.thirdPhoto = carworkshop["thirdPhoto"].stringValue;
                            tmp.logo = carworkshop["logo"].stringValue;
                            tmp.categorie = carworkshop["categorie"].stringValue;
                            tmp.color = carworkshop["color"].stringValue;
                            
                            for (_,subsi):(String,JSON) in carworkshop["subsidiary_id"] {
                                
                                var SubTmp:SubsidiaryTemplate = SubsidiaryTemplate();
                                SubTmp._id = subsi["_id"].stringValue;
                                SubTmp.carworkshop_id = subsi["carworkshop_id"].stringValue;
                                SubTmp.country = subsi["country"].stringValue;
                                SubTmp.phone = subsi["phone"].stringValue;
                                SubTmp.address = subsi["address"].stringValue;
                                SubTmp.long = subsi["coords"].arrayValue[0].doubleValue;
                                SubTmp.lat = subsi["coords"].arrayValue[1].doubleValue;
                                
                                tmp.subsidiaries.append(SubTmp);
                            }
                            
                            self.CarworkshopsArray.append(tmp);
                        }
                        self.reloadMapView();
                        SwiftSpinner.hide();
                        
                    }else{
                        
                        if(data["message"] == "Corrupt Token."){
                            self.performSegue(withIdentifier: "LoginSegue", sender: self);
                        }else{
                            self.alerta("Oops!", Mensaje: data["message"].stringValue );
                            SwiftSpinner.hide();
                        }
                    }
                }else{
                    SwiftSpinner.hide();
                }
            }
            
        case .unknown, .offline:
            SwiftSpinner.hide();
            self.alerta("Sin Conexion", Mensaje: "Favor de conectarse a internet.");
        }
    }
    
    func reloadMapView() {
        print("Reloading map view");
        self.MapView.clear();
        if self.CarworkshopsArray.count > 0{
            
            for m in self.Markers {
                m.map = nil;
            }
            self.Markers = [];
            
            for Carworkshop in self.CarworkshopsArray {
                if (Carworkshop.subsidiaries.count >= 1) {
                    let  position = CLLocationCoordinate2DMake(Carworkshop.subsidiaries[0].lat, Carworkshop.subsidiaries[0].long);
                    let marker = GMSMarker(position: position);
                    marker.appearAnimation = .pop;
                    marker.icon = self.createMarkerWithInfo(title: Carworkshop.name, subTitle: Carworkshop.categorie);
                    marker.title = Carworkshop.name;
                    marker.snippet = Carworkshop.categorie;
                    marker.map = self.MapView;
                    self.Markers.append(marker);
                }
            }
            if self.Markers.count > 0 {
                //self.MapView.selectedMarker = self.Markers[0];
            }
            SwiftSpinner.hide();
            
        }else{
            SwiftSpinner.hide();
            self.alerta("Lo sentimos", Mensaje: "Por el momento no hay sucursales en su zona.");
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.categoriesLabel.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.categoriesLabel[row];
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.SelectedCell = row;
    }
    
    func donePicker (sender:UIBarButtonItem) {
        self.ActualFilter = self.categoriesArray[self.SelectedCell];
        self.CategoryTextfield.text = self.categoriesLabel[self.SelectedCell];
        self.CategoryTextfield.resignFirstResponder();
        self.pickerCategory.resignFirstResponder();
        self.ReloadData();
    }
    
    func cancelPicker (sender:UIBarButtonItem) {
        self.CategoryTextfield.resignFirstResponder();
        self.pickerCategory.resignFirstResponder();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if let dest = segue.destination as? DetailCarworkshopViewController {
                dest.Carworkshop = self.CarworkshopsArray[self.SelectedCarworkshop];
                // dest.LogoImage = self.ImagesCache[self.SelectedCarworkshop];
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
        //geoCode(locations.first!);
        
    }
    
    ///*****/////******/////////*****/////******/////////*****/////******/////////*****/////******/////////*****/////******//////
    /// GOOGLE MAPS MANAGER METHODS:
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var i = -1;
        for (index, Carworkshop) in self.CarworkshopsArray.enumerated() {
            if(Carworkshop.subsidiaries.count >= 1) {
                let loc = CLLocationCoordinate2D(latitude: Carworkshop.subsidiaries[0].lat, longitude: Carworkshop.subsidiaries[0].long);
                if(marker.position.latitude == loc.latitude &&
                    marker.position.longitude == loc.longitude) {
                    i = index;
                }
            }
        }
        if (i != -1) {
            self.SelectedCarworkshop = i;
            self.performSegue(withIdentifier: "ShowDetail", sender: self);
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        return nil
    }
    
    
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.selectedMarker = nil
        return false
    }
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func createMarkerWithInfo( title:String, subTitle: String) -> UIImage {
        let backGroundText = getImageWithColor(color: UIColor.orange, size: CGSize(width: 100, height: 40));
        let str = title + "\n" + subTitle;
        let textImg = textToImage(drawText: str as NSString, inImage: backGroundText, atPoint: CGPoint(x: 2, y: 2));
        
        let bottomImage = UIImage(named: "Shop");
        
        let size = CGSize(width: 100, height: 80)
        UIGraphicsBeginImageContext(size)
        
        textImg.draw(at: CGPoint(x: 0, y: 0));
        bottomImage!.draw(at: CGPoint(x: 28, y: 42));
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        return newImage;
    }
    
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 16)!
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.alignment = .center;
        
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paragraphStyle
            ] as [String : Any];
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
