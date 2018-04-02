//
//  CategoryCell.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/7/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    @IBOutlet weak var catNameLbl: UILabel!
    @IBOutlet weak var countTruckLbl: UILabel!
    @IBOutlet weak var catPic: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
