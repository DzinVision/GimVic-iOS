//
//  RootViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/19/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit
import GimVicData

class RootViewController: UIViewController, UIScrollViewDelegate, TimetableDataDelegate {
    static var sharedInstance: RootViewController?
    
    var suplenceViewControllers = [SuplenceViewController]()
    var currentIndex = 0
    var scrollingLocked = false
    var timer: Timer?
    var initialLoad = true
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var dataAgeLabel: UILabel!
    
    var startingIndex: Int {
        let calendar = Calendar(identifier: .gregorian)
        let weekday = calendar.component(.weekday, from: Date())
        
        if weekday == 1 || weekday == 7 {
            return 0
        }
        return weekday - 2
    }
    
    // MARK: - Status Bar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View Lifecylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RootViewController.sharedInstance = self
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate(sender:)), name: .UIDeviceOrientationDidChange, object: nil)
        TimetableData.sharedInstance.delegates[.rootViewController] = self
        
        setDataAgeLabel()
        setTimer()
        
        if TimetableData.sharedInstance.isEmpty {
            TimetableData.sharedInstance.update()
        }
        
        for i in 0..<5 {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "SuplenceViewController")
                as? SuplenceViewController {
                viewController.index = i
                
                suplenceViewControllers.append(viewController)
                addChildViewController(viewController)
                scrollView.addSubview(viewController.view)
            }
        }
        
        currentIndex = startingIndex
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults().object(forKey: UserSettings.lastRefreshedTimetableData.rawValue) as? Date == nil {
            let setupStoryboard = UIStoryboard(name: "Setup", bundle: nil)
            let viewController = setupStoryboard.instantiateInitialViewController()!
            present(viewController, animated: true, completion: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = scrollView.bounds.size.height
        scrollView.contentSize.width = 5 * scrollView.bounds.size.width

        scrollView.contentOffset.x = CGFloat(currentIndex) * view.bounds.size.width
        
        for viewController in suplenceViewControllers {
            viewController.view.frame.size = scrollView.bounds.size
            viewController.view.frame.origin.x = CGFloat(viewController.index) * scrollView.bounds.size.width
            viewController.view.frame.origin.y = 0
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        scrollingLocked = true
    }
    
    func didRotate(sender: AnyObject) {
        scrollingLocked = false
    }
    
    func setTimer() {
        if timer != nil {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 60,
                                     target: self,
                                     selector: #selector(setDataAgeLabel),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    // MARK: - Change Day
    func transitionToDay(_ day: Int) {
        scrollView.contentOffset.x = CGFloat(day) * scrollView.bounds.size.width
    }
    
    // MARK: - Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollingLocked {
            return
        }
        currentIndex = Int(scrollView.contentOffset.x / view.bounds.size.width)
        pageControl.currentPage = currentIndex
    }
    
    @IBAction func settingsButtonPressed(_ sender: AnyObject) {
        let settingsStoryboard = UIStoryboard(name: "Settings", bundle: nil)
        let settingsNavigationViewController = settingsStoryboard.instantiateInitialViewController()!
        settingsNavigationViewController.modalPresentationStyle = .formSheet
        present(settingsNavigationViewController, animated: true, completion: nil)
    }
    
    func setDataAgeLabel() {
        let lastRefreshed = UserDefaults().object(forKey: UserSettings.lastRefreshedTimetableData.rawValue) as? Date
        if lastRefreshed == nil {
            dataAgeLabel.text = "N/A"
        } else {
            let ageText = FuzzyDate.timeSince(lastRefreshed!)
            dataAgeLabel.text = ageText
        }
    }
    
    func timetableDataDidUpdateWithStatus(_ status: DataGetterStatus) {
        if status == .error {
            let alertController = UIAlertController(title: "Napaka pri nalaganju podatkov.",
                                                    message: "Prikazani so podatki od zadnje uspešne osvežitve.",
                                                    preferredStyle: .alert)
            let tryAgain = UIAlertAction(title: "Poskusi ponovno",
                                         style: .default,
                                         handler: {action in
                                            TimetableData.sharedInstance.update()
            })
            let dismiss = UIAlertAction(title: "Vredu", style: .cancel, handler: nil)
            alertController.addAction(dismiss)
            alertController.addAction(tryAgain)
            present(alertController, animated: true, completion: nil)
        } else if status == .success {
            setDataAgeLabel()
        }
    }
}
