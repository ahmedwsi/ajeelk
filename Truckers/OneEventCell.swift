//
//  OneEventCell.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 6/29/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

class OneEventCell: UITableViewCell {

    @IBOutlet weak var EventTitleLabel: UILabel!
    @IBOutlet weak var CalendarBgImg: UIImageView!
    @IBOutlet weak var EventDayLabel: UILabel!
    @IBOutlet weak var EventMonthLabel: UILabel!
    @IBOutlet weak var EventYearLabel: UILabel!
    @IBOutlet weak var EventLocationLabel: UILabel!
    
    @IBOutlet weak var EventOrganizer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
