//
//  CellOneTruck.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/14/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class CellOneTruck: UITableViewCell {

    @IBOutlet weak var TruckImgView: UIImageView!
    
    @IBOutlet weak var TruckNameLbl: UILabel!
    
    @IBOutlet weak var TruckReview: CosmosView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
