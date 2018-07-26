//
//  DetailCarworkshopTableViewCell.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 16/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class DetailCarworkshopTableViewCell: UITableViewCell {

    @IBOutlet weak var CountryLabel: UILabel!
    @IBOutlet weak var PhoneLabel: UILabel!
    @IBOutlet weak var AddressLabel: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
