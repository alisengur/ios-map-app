//
//  LocationTableViewCell.swift
//  iosMapApplication
//
//  Created by Ali Şengür on 5.04.2020.
//  Copyright © 2020 Ali Şengür. All rights reserved.
//

import UIKit


protocol LocationCellDelegate {
    func didTappedViewButton(index: Int)
}



class LocationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var viewLocationButton: UIButton!
    
    
    var delegate: LocationCellDelegate?
    var index: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewLocationButton.layer.cornerRadius = 6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func viewButtonDidTapped(_ sender: Any) {
        delegate?.didTappedViewButton(index: (index!.row))
    }
}
