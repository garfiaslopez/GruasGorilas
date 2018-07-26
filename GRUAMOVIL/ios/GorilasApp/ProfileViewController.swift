//
//  ProfileViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 09/03/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class ProfileViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let Variables = VARS();
    let Save = UserDefaults.standard;
    let ApiUrl = VARS().getApiUrl();
    var UsuarioEnSesion:Session = Session();
    let imagePicker = UIImagePickerController();
    var profileImage: UIImage! = UIImage();

    @IBOutlet weak var ProfilePhotoImageView: UIImageView!
    @IBOutlet weak var NameTextfield: UITextField!
    @IBOutlet weak var PhoneTextfield: UITextField!
    @IBOutlet weak var EmailTextfield: UITextField!
    @IBOutlet weak var OldPasswordTextField: UITextField!
    @IBOutlet weak var NewPasswordTextField: UITextField!
    
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var CarsButton: UIBarButtonItem!
    
    
    @IBOutlet weak var topLayout: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad();
        
        let profileImg = self.ApiUrl + "/profile/images/" + self.UsuarioEnSesion._id;
        let urlProfile = URL(string: profileImg);
        self.downloadImage(url: urlProfile!);

        self.imagePicker.delegate = self;
        self.NameTextfield.text = self.UsuarioEnSesion.name;
        self.PhoneTextfield.text = self.UsuarioEnSesion.phone;
        self.EmailTextfield.text = self.UsuarioEnSesion.email;
        
        self.OldPasswordTextField.delegate = self;
        self.NewPasswordTextField.delegate = self;
        
        self.NameTextfield.delegate = self;
        self.PhoneTextfield.delegate = self;
        self.EmailTextfield.delegate = self;
        
        self.OldPasswordTextField.tag = 1;
        self.NewPasswordTextField.tag = 2;
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //ACTIVAR NOTIFICACIONES DEL TECLADO:
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.KeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.KeyboardDidHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil);
        
        if (self.UsuarioEnSesion.typeuser == "operator") {
            self.CarsButton.tintColor = UIColor.clear;
            self.CarsButton.width = 0.01;
            self.CarsButton.isEnabled = false;
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_Profile")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        self.save();
    }
    
    func save (){
    
        var DatatoSend: Parameters = ["":"" as AnyObject!];
        
        if(self.OldPasswordTextField.text != "" && self.NewPasswordTextField.text != "") {
            DatatoSend["oldPassword"] = self.OldPasswordTextField.text!;
            DatatoSend["password"] = self.NewPasswordTextField.text!;
        }
        
        if(self.EmailTextfield.text != "") {
            if (isValidEmail(self.EmailTextfield.text!)){
                DatatoSend["email"] = self.EmailTextfield.text!;
            }else{
                self.alerta("Oops!", Mensaje: "El correo electrónico no es válido.");
            }
        }
        
        if(self.NameTextfield.text != "") {
            DatatoSend["name"] = self.NameTextfield.text!;
        }
        
        if(self.PhoneTextfield.text != "") {
            DatatoSend["phone"] = self.PhoneTextfield.text!;
        }
        
        DismissKeyboard();
        SwiftSpinner.show("Actualizando");
        let AuthUrl = ApiUrl + "/user/" + self.UsuarioEnSesion._id;
        let headers = [
            "Authorization": self.UsuarioEnSesion.token
        ]
        
        let status = Reach().connectionStatus();
        switch status {
        case .online(.wwan), .online(.wiFi):
            
            Alamofire.request(AuthUrl, method: .put, parameters: DatatoSend, encoding: JSONEncoding.default,  headers: headers).responseJSON { response in
                if response.result.isSuccess {
                    let data = JSON(data: response.data!);
                    if(data["success"] == true){
                        SwiftSpinner.hide();
                        self.alerta("Correcto", Mensaje: data["message"].stringValue );
                        // UPDATE LOCAL USUARIO SESION:
                        var SaveObj = [String : String]();
                        SaveObj["token"] = self.UsuarioEnSesion.token;
                        SaveObj["_id"] = self.UsuarioEnSesion._id;
                        SaveObj["email"] = self.EmailTextfield.text;
                        SaveObj["password"] = self.NewPasswordTextField.text;
                        SaveObj["phone"] = self.PhoneTextfield.text;
                        SaveObj["name"] = self.NameTextfield.text;
                        SaveObj["typeuser"] = self.UsuarioEnSesion.typeuser;
                        
                        self.Save.set(SaveObj, forKey: "UsuarioEnSesion")
                        self.Save.synchronize();
                        
                    }else{
                        SwiftSpinner.hide();
                        self.alerta("Error de sesión", Mensaje: data["message"].stringValue );
                    }
                }else{
                    SwiftSpinner.hide();
                    self.alerta("Oops!", Mensaje: (response.result.error?.localizedDescription)!);
                }
            }
        case .unknown, .offline:
            SwiftSpinner.hide();
            self.alerta("Sin conexión a internet", Mensaje: "Favor de conectarse a internet para acceder.");
            break;
        }
        
    }
    
    @IBAction func selectPhoto(_ sender: AnyObject) {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImage = pickedImage;
            self.ProfilePhotoImageView.contentMode = .scaleAspectFit;
            self.ProfilePhotoImageView.image = pickedImage;
            self.UploadProfilePhoto();
        }
        self.dismiss(animated: true, completion: nil);
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func UploadProfilePhoto(){
        SwiftSpinner.show("Subiendo foto");
        
        let ImageUrl = VARS().getApiUrl() + "/profile/images/" + self.UsuarioEnSesion._id;
        if((self.profileImage) != nil) {
            
            let imageData = UIImageJPEGRepresentation(self.profileImage, 1.0);
            let imgName = self.UsuarioEnSesion._id + ".jpeg";
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(imageData!, withName: "profilePhoto", fileName: imgName, mimeType: "jpeg")
                },
                to: ImageUrl,
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON { response in
                            if response.result.isSuccess{
                                let json = JSON(data: response.data!);
                                SwiftSpinner.hide();
                                if json["success"].boolValue {
                                    print("Upload OK");
                                }else{
                                    self.alerta("Oops!", Mensaje: json["message"].stringValue);
                                }
                            }else{
                                SwiftSpinner.hide();
                                self.alerta("Oops!", Mensaje: "No se pudo comunicar con el servidor.");
                            }
                        }
                    case .failure(let encodingError):
                        print(encodingError);
                        SwiftSpinner.hide();
                    }
                }
            )
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField.tag == 1 || textField.tag == 2) {
            self.topLayout.constant = -300;
            UIView.animate(withDuration: 1, animations: {
                self.view.layoutIfNeeded()
            })
        }else{
            self.topLayout.constant = -155;
            UIView.animate(withDuration: 1, animations: {
                self.view.layoutIfNeeded()
            })
        }
        return true;
    }
    
    func KeyboardDidShow(){
        
        //añade el gesto del tap para esconder teclado:
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.DismissKeyboard))
        view.addGestureRecognizer(tap);
        
    }
    
    func KeyboardDidHidden(){
        self.topLayout.constant = 0;
        UIView.animate(withDuration: 1, animations: {
            self.view.layoutIfNeeded()
        });
        
        //quita los gestos para que no halla interferencia despues
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer )
            }
        }
    }
    
    func DismissKeyboard(){
        self.EmailTextfield.resignFirstResponder();
        self.NameTextfield.resignFirstResponder();
        self.PhoneTextfield.resignFirstResponder();
        self.NewPasswordTextField.resignFirstResponder();
        self.OldPasswordTextField.resignFirstResponder();
    }
    
    
    func alerta(_ Titulo:String,Mensaje:String){
        let alertController = UIAlertController(title: Titulo, message:
            Mensaje, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailExpression = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailExpression);
        return emailTest.evaluate(with: testStr);
    }

    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                if ((self.ProfilePhotoImageView) != nil) {
                    let img = UIImage(data:data as Data);
                    if img != nil {
                        self.ProfilePhotoImageView.image = img;
                        self.ProfilePhotoImageView.layer.cornerRadius = 70;
                        self.ProfilePhotoImageView.layer.masksToBounds = true;
                        self.ProfilePhotoImageView.layer.borderWidth = 0;
                    }else{
                        self.ProfilePhotoImageView.image = UIImage(named:"ProfileDefault");
                        self.ProfilePhotoImageView.layer.cornerRadius = 35;
                        self.ProfilePhotoImageView.layer.masksToBounds = true;
                        self.ProfilePhotoImageView.layer.borderWidth = 0;
                    }
                }
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    
}
