//
//  CarworkshopTableViewCell.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 15/02/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class CarworkshopTableViewCell: UITableViewCell {

    @IBOutlet weak var BackgroundLogoView: UIView!
    @IBOutlet weak var LogoImageView: UIImageView!
    @IBOutlet weak var PromoImageView: UIImageView!
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var SubsidiariesLabel: UILabel!
    @IBOutlet weak var CategorieLabel: UILabel!
    @IBOutlet weak var PhoneLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
