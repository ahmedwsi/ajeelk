//
//  OnePhotoTVC.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/17/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class OnePhotoTVC: UITableViewCell {

    @IBOutlet weak var ImageV: UIImageView!
    @IBOutlet weak var photoTitleTxt: UILabel!
    @IBOutlet weak var PhotoDateTimeTxt: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
