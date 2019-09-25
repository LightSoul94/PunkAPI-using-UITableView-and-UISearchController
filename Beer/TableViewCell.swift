//
//  TableViewCell.swift
//  Beer
//
//  Created by Gianluca Caliendo on 17/09/2019.
//  Copyright © 2019 Gianluca Caliendo. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var descrp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
