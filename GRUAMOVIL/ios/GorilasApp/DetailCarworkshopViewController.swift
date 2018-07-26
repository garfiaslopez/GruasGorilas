//
//  DetailCarworkshopViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 16/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import MapKit

class DetailCarworkshopViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var Carworkshop:CarworkshopTemplate!;
    var LogoImage:UIImage!;
    let ApiUrl = VARS().getApiUrl();

    @IBOutlet weak var PromoView: UIView!
    @IBOutlet weak var PromoTextView: UITextView!
    @IBOutlet weak var LogoImageView: UIImageView!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var SubsidiariesLabel: UILabel!
    @IBOutlet weak var DescriptionTextArea: UITextView!
    @IBOutlet weak var CategorieLabel: UILabel!
    @IBOutlet weak var FirsthPhotoImageView: UIImageView!
    @IBOutlet weak var SecondPhotoImageView: UIImageView!
    @IBOutlet weak var ThirdPhotoImageView: UIImageView!
    @IBOutlet weak var SubsidiariesTableView: UITableView!
    
    @IBOutlet weak var PromoTopLayout: NSLayoutConstraint!
    
    @IBOutlet weak var TitleBar: UINavigationBar!
    
    // -40 To HIDE & 0 To Show...
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.title = self.Carworkshop.name;
        self.TitleBar.topItem?.title = self.Carworkshop.name;
        self.navigationController?.navigationBar.topItem?.title = "Atras";
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = UIColor.white;
        
        let nib = UINib(nibName: "DetailCarworkshopTableViewCell", bundle: nil);
        self.SubsidiariesTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        DispatchQueue.main.async {
            self.LogoImageView.image = self.LogoImage;            
        }
        
        self.PromoTextView.textColor = UIColor.white;
        
        if (self.Carworkshop.havePromo){
            self.PromoTopLayout.constant = 0;
            self.PromoTextView.text = self.Carworkshop.promo;
            print(self.PromoTextView.text);
        }else{
            self.PromoTopLayout.constant = -40;
        }
        
        self.DescriptionTextArea.text = self.Carworkshop.description;
        self.SubsidiariesLabel.text = "\(self.Carworkshop.subsidiaries.count) Sucursales";
        self.CategorieLabel.text = self.Carworkshop.categorie;
        
        self.PromoTextView.textColor = UIColor.white;
        
        //LoadImages:
        
        // LOGOPHOTO:
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
            
            let url = self.ApiUrl + "/images/" + self.Carworkshop.name.replacingOccurrences(of: " ", with: "") + "/" + self.Carworkshop.logo;
            print(url);
            if let checkedUrl = URL(string: url) {
                self.getDataFromUrl(checkedUrl) { data in
                    if let NewImage = UIImage(data: data! as Data){
                        DispatchQueue.main.async {
                            self.LogoImageView.image = NewImage;
                        }
                    }else{
                        
                        let MissingImage = UIImage(named: "MissingImage.png");
                        DispatchQueue.main.async {
                            self.LogoImageView.image = MissingImage;
                        }
                    }
                    
                }
            }
        }
        
        // FIRSTPHOTO:
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {

            let url = self.ApiUrl + "/images/" + self.Carworkshop.name.replacingOccurrences(of: " ", with: "") + "/" + self.Carworkshop.firstPhoto;
            print(url);
            if let checkedUrl = URL(string: url) {
                self.getDataFromUrl(checkedUrl) { data in
                    if let NewImage = UIImage(data: data! as Data){
                        DispatchQueue.main.async {
                            self.FirsthPhotoImageView.image = NewImage;
                        }
                    }else{
                        
                        let MissingImage = UIImage(named: "MissingImage.png");
                        DispatchQueue.main.async {
                            self.FirsthPhotoImageView.image = MissingImage;
                        }
                    }
                    
                }
            }
        }
        
        //SECOND PHOTO
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
            
            let url = self.ApiUrl + "/images/" + self.Carworkshop.name.replacingOccurrences(of: " ", with: "") + "/" + self.Carworkshop.secondPhoto;
            print(url);
            if let checkedUrl = URL(string: url) {
                self.getDataFromUrl(checkedUrl) { data in
                    if let NewImage = UIImage(data: data! as Data){
                        DispatchQueue.main.async {
                            self.SecondPhotoImageView.image = NewImage;
                        }
                    }else{
                        
                        let MissingImage = UIImage(named: "MissingImage.png");
                        DispatchQueue.main.async {
                            self.SecondPhotoImageView.image = MissingImage;
                        }
                    }
                    
                }
            }
        }
        
        //THIRDPHOTO
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async {
            
            let url = self.ApiUrl + "/images/" + self.Carworkshop.name.replacingOccurrences(of: " ", with: "") + "/" + self.Carworkshop.thirdPhoto;
            print(url);
            if let checkedUrl = URL(string: url) {
                self.getDataFromUrl(checkedUrl) { data in
                    if let NewImage = UIImage(data: data! as Data){
                        DispatchQueue.main.async {
                            self.ThirdPhotoImageView.image = NewImage;
                        }
                    }else{
                        
                        let MissingImage = UIImage(named: "MissingImage.png");
                        DispatchQueue.main.async {
                            self.ThirdPhotoImageView.image = MissingImage;
                        }
                    }
                    
                }
            }
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Carworkshop.subsidiaries.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:DetailCarworkshopTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! DetailCarworkshopTableViewCell;
        
        cell.CountryLabel.text = self.Carworkshop.subsidiaries[(indexPath as NSIndexPath).row].country;
        cell.PhoneLabel.text = self.Carworkshop.subsidiaries[(indexPath as NSIndexPath).row].phone;
        cell.AddressLabel.text = self.Carworkshop.subsidiaries[(indexPath as NSIndexPath).row].address;
        
        
        return cell;
    }
    
    
    
    // MARK:  UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let latitute:CLLocationDegrees = self.Carworkshop.subsidiaries[(indexPath as NSIndexPath).row].lat;
        let longitute:CLLocationDegrees = self.Carworkshop.subsidiaries[(indexPath as NSIndexPath).row].long;
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.self.Carworkshop.name)"
        mapItem.openInMaps(launchOptions: options)
        
    }
    
    @IBAction func CloseView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    

    func getDataFromUrl(_ urL:URL, completion: @escaping ((_ data: NSData?) -> Void)) {
        URLSession.shared.dataTask(with: urL) { (data, response, error) in
            completion(data as NSData?)
            }.resume()
    }
}
