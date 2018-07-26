
//
//  ConditionsTableViewCell.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 11/6/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class ConditionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ConditionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
