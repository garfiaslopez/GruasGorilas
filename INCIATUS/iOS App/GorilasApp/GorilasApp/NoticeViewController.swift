//
//  NoticeViewController.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 10/26/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit
import SwiftyJSON


class NoticeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var NoticeArray:Array<NoticeTemplate> = [];

    @IBOutlet weak var DataTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad();

        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil);
        self.DataTableView.register(nib, forCellReuseIdentifier: "CustomCell");
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NoticeArray.count;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:CustomTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell;

        let newDate = Formatter().ParseMomentDate(self.NoticeArray[(indexPath as NSIndexPath).row].created);
        cell.DescriptionLabel.text = "\(self.NoticeArray[(indexPath as NSIndexPath).row].description)";
        cell.ValueLabel.text = "\(Formatter().DatePretty.string(from: newDate))";
        
        return cell
    }
    
    @IBAction func CloseModal(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil);
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
