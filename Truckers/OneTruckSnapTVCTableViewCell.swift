//
//  OneSnapTVCTableViewCell.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/13/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import AVFoundation

class OneTruckSnapTVCTableViewCell: UITableViewCell {

    @IBOutlet weak var SnapVideoTitle: UILabel!
    @IBOutlet weak var SnapVideoDT: UILabel!
    @IBOutlet weak var VideoWebview: UIWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
