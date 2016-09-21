//
//  SetupViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/21/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class SetupViewController: UIViewController, ChooserDataDelegate {
    let animationDuration = 0.2
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !ChooserData.sharedInstance.isDataValid {
            ChooserData.sharedInstance.delegates[.setupViewController] = self
            ChooserData.sharedInstance.update()
        } else {
            loadingLabel.isHidden = true
            loadingIndicator.stopAnimating()
            nextButton.isHidden = false
        }
    }
    
    func chooserDataDidUpdateWithStatus(_ status: DataGetterStatus) {
        if ChooserData.sharedInstance.isDataValid {
            nextButton.alpha = 0.0
            nextButton.isHidden = false
            UIView.animate(withDuration: animationDuration,
                           animations: {
                            self.loadingLabel.alpha = 0.0
                            self.loadingIndicator.alpha = 0.0
                            self.nextButton.alpha = 1.0
                }, completion: {comletition in
                    self.loadingLabel.isHidden = true
                    self.loadingIndicator.stopAnimating()
            })
        } else {
            let message: String?
            if status == .networkError {
                message = "Za prenos podatkov je potrebna internetna povezava."
            } else {
                message = nil
            }
            
            let alertController = UIAlertController(title: "Napaka pri nalaganju podatkov.",
                                                    message: message,
                                                    preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "Poskusi znova", style: .default, handler: {(action) in
                ChooserData.sharedInstance.update()
            })
            alertController.addAction(tryAgain)
            present(alertController, animated: true, completion: nil)
        }
    }
}
