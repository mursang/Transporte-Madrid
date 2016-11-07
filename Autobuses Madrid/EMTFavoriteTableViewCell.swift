//
//  EMTFavoriteTableViewCell.swift
//  Transporte Madrid
//
//  Created by Angel Sans Muro on 7/11/16.
//  Copyright © 2016 Angel Sans. All rights reserved.
//

import UIKit

class EMTFavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var stopNumberLabel: UILabel!
    @IBOutlet weak var linesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
