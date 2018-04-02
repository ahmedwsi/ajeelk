//
//  ServiceCellVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/3/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class ServiceCellVC: UITableViewCell {

    @IBOutlet weak var ServiceIdLbl: UILabel!
    @IBOutlet weak var ServiceNameLabl: UILabel!
    @IBOutlet weak var ServicePriceLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
