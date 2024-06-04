//
//  ScoreTableViewCell.swift
//  Math Buster
//
//  Created by Мухаммед Каипов on 11/5/24.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {
    
    static let identfier: String = "cellIdentifier"

    @IBOutlet var scoreTextLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        scoreTextLabel.text = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //Reset to initial val
        scoreTextLabel.text = nil
    }
    
}
