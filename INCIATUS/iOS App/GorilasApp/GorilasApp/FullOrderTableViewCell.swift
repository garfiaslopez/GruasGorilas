//
//  FullOrderTableViewCell.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 2/1/17.
//  Copyright © 2017 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class FullOrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var OrderNumberLabel: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var OriginLabel: UILabel!
    @IBOutlet weak var DestinyLabel: UILabel!
    @IBOutlet weak var GroupLabel: UILabel!
    @IBOutlet weak var TotalLabel: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
