//
//  SettingsCell.swift
//  MTLImage
//
//  Created by Mohssen Fathi on 3/31/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

protocol SettingsCellDelegate {
    func settingsCellSliderValueChanged(sender: SettingsCell, value: Float)
}

class SettingsCell: UITableViewCell {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    lazy var gradient: CAGradientLayer? = {
        return self.trackGradient()
    }()
    
    var message: String? {
        didSet {
            if message == "" || message == nil {
                messageLabel.hidden = true
                messageLabel.text = ""
            } else {
                messageLabel.hidden = false
                messageLabel.text = message
            }
        }
    }
    
    var spectrum: Bool = false {
        didSet {
            if spectrum == true {
                slider.minimumTrackTintColor = UIColor.clearColor()
                slider.maximumTrackTintColor = UIColor.clearColor()
                slider.thumbTintColor = currentColor()
                layer.insertSublayer(gradient!, atIndex: 0)
                layoutSubviews()
            }
        }
    }
    
    var delegate: SettingsCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if spectrum == true {
            gradient?.frame = CGRectMake(25, slider.center.y - 1.0, CGRectGetWidth(frame) - 100, 2.0)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func sliderValueChanged(sender: UISlider) {
        delegate?.settingsCellSliderValueChanged(self, value: sender.value)
        
        if spectrum {
            slider.thumbTintColor = currentColor()
        }
    }
    
    func currentColor() -> UIColor {
        return UIColor(hue: CGFloat(slider.value) * (5.0/6.0) + (1.0/6.0), saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
    
    func trackGradient() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        
        var colors = [CGColor]()
        var locations = [Float]()
        for i in 1 ..< 7 {
            colors.append(UIColor(hue: (1.0/6.0) * CGFloat(i), saturation: 1.0, brightness: 1.0, alpha: 1.0).CGColor)
            locations.append((1.0/6.0) * Float(i))
        }
        
        gradientLayer.colors     = colors
        gradientLayer.locations  = locations
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1.0, y: 0.5)
       
        return gradientLayer
    }
}