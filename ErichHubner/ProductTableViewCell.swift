//
//  ProductTableViewCell.swift
//  ErichHubner
//
//  Created by erich on 26/04/2018.
//  Copyright © 2018 Hubnerspage. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    //Definindo os outlets
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var ivPhoto: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
