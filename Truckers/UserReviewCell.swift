//
//  UserReviewCell.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/22/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class UserReviewCell: UITableViewCell {

    
    @IBOutlet weak var ReviewUserNameLbl: UILabel!
    @IBOutlet weak var ReviewCommentTxt: UILabel!
    @IBOutlet weak var ReviewDateTimeLbl: UILabel!
    @IBOutlet weak var ReviewUserImage: UIImageView!
    @IBOutlet weak var ReviewUserRating: CosmosView!
    @IBOutlet weak var ReviewAttachedImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
