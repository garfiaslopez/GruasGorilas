//
//  AboutViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 10/6/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var MainTableView: UITableView!
    @IBOutlet weak var MenuButton: UIBarButtonItem!
    @IBOutlet weak var RankView: UIView!
    
    let citys = ["Argentina"];
    var UsuarioEnSesion:Session = Session();

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil);
        self.MainTableView.register(nib, forCellReuseIdentifier: "CustomCell");
        
        
        if revealViewController() != nil {
            MenuButton.target = revealViewController()
            MenuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if(self.UsuarioEnSesion.typeuser == "operator") {
            self.RankView.isHidden = true;
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_About")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.citys.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell;
        cell.DescriptionLabel.text = "\(self.citys[indexPath.row])";
        return cell
    }
    
    
    
    @IBAction func OpenRank(_ sender: AnyObject) {
        let appID = "1153437033";
        let urlStr = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id=\(appID)" // (Option 2) Open App Review Tab
        UIApplication.shared.openURL(URL(string: urlStr)!);
    }
    
    
    @IBAction func OpenShare(_ sender: AnyObject) {
//        let share = "https://itunes.apple.com/us/app/gruas-gorilas/id1153437033?ls=1&mt=8";
//        self.displayShareSheet(shareContent: share);
    }
    @IBAction func OpenFacebook(_ sender: AnyObject) {
//        let phoneNumber: String = "http://facebook.com/inciatus/";
//        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }
    @IBAction func OpenTwitter(_ sender: AnyObject) {
//        let phoneNumber: String = "http://twitter.com/intent/follow?source=followbutton&variant=1.0&screen_name=Gruasgorilas";
//        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }
    @IBAction func OpenLinkedIn(_ sender: AnyObject) {
//        let phoneNumber: String = "https://www.linkedin.com/company/gr-as-gorilas";
//        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }
    @IBAction func OpenYoutube(_ sender: AnyObject) {
//        let phoneNumber: String = "http://www.youtube.com/user/videosgruasgorilas?sub_confirmation=1";
//        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }
    @IBAction func OpenWeb(_ sender: AnyObject) {
        let phoneNumber: String = "http://gruamovil.inciatus.mx";
        UIApplication.shared.openURL(URL(string:phoneNumber)!);
    }
    
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil);
        present(activityViewController, animated: true, completion: {});
    }

}
