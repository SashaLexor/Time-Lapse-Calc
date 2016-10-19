//
//  CalculationCell.swift
//  Time Lapse Calc
//
//  Created by 1024 on 27.09.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit

class CalculationCell: UITableViewCell {
    
   
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberOfPhotosLabel: UILabel!
    @IBOutlet weak var clipLengthLabel: UILabel!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var memoryUsageLabel: UILabel!
    @IBOutlet weak var calculationImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.clear
    
        calculationImageView.layer.cornerRadius = 4.0
        calculationImageView.clipsToBounds = true
        calculationImageView.layer.borderWidth = 1.0
        calculationImageView.layer.borderColor = UIColor.white.cgColor
        
        calculationImageView.contentMode = .scaleAspectFill
 
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(forCalculation calculation: Calculation) {
        nameLabel.text = calculation.name
        numberOfPhotosLabel.text = String(calculation.numberOfPhotos)
        clipLengthLabel.text = String(calculation.clipLength.totalTimeInSeconds)
        intervalLabel.text = String(format: "%.2f", calculation.shootingInterval)
        memoryUsageLabel.text = String(calculation.memoryUsage)
        calculationImageView.image = image(forCalculation: calculation)
    }
    
    func image(forCalculation calculation: Calculation) -> UIImage {
        let imageViewSize = CGSize(width: calculationImageView.bounds.width, height: calculationImageView.bounds.height)
        if calculation.hasPhoto, let image = calculation.photoImage {
            return image.resizedImageWithBounds(bounds: imageViewSize)
        }
        return UIImage(named: "timelapseEx.jpg")!.resizedImageWithBounds(bounds: imageViewSize)
    }

}
