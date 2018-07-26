//
//  TutorialViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 11/22/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class TutorialViewController: UIViewController {

    
    var UsuarioEnSesion:Session = Session();

    
    @IBOutlet weak var YoutubeView: YTPlayerView!
    @IBOutlet weak var Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if self.UsuarioEnSesion.typeuser == "operator" {
            self.YoutubeView.load(withVideoId: "TKMAVZL0JvQ");
        }else{
            self.YoutubeView.load(withVideoId: "Zq-eDrnqW1s");
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "User_About_Tutorial")
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject]);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func CloseModal(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
}
