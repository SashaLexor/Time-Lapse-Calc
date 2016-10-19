//
//  HudView.swift
//  Time Lapse Calc
//
//  Created by 1024 on 16.08.16.
//  Copyright © 2016 Sasha Lexor. All rights reserved.
//

import UIKit

class HudView: UIView {
    var text = ""
    class func hudInView (_ view : UIView, animated : Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.showAnimated(animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxHeight: CGFloat = 96.0
        let boxWidth: CGFloat = 96.0
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth)/2), y: round((bounds.size.height - boxHeight)/2), width: boxWidth, height: boxHeight)
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 8)
        let color = UIColor(red: 59/256, green: 67/256, blue: 78/256, alpha: 0.9) // Color as navigationBar
        color.setFill()
        roundedRect.fill()
        
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        let font = UIFont(name: "HelveticaNeue-Light", size: 17.0)
        let attributes = [NSFontAttributeName:font! ,NSForegroundColorAttributeName:UIColor.white]
        let textSize = text.size(attributes: attributes)
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at: textPoint, withAttributes: attributes)
    }
    
    func showAnimated(_ animated: Bool) { if animated {
        // 1
        alpha = 0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3) // 2
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}
