//
//  RootViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/19/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIScrollViewDelegate {
    static var sharedInstance: RootViewController?
    var suplenceViewControllers = [SuplenceViewController]()
    var currentIndex: CGFloat = 0
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
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
        
        for i in 0..<5 {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "SuplenceViewController")
                as? SuplenceViewController {
                viewController.index = i
                
                suplenceViewControllers.append(viewController)
                addChildViewController(viewController)
                scrollView.addSubview(viewController.view)
            }
        }
        currentIndex = CGFloat(startingIndex)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = scrollView.bounds.height
        scrollView.contentSize.width = 5 * scrollView.bounds.width
        
        scrollView.contentOffset.x = currentIndex * scrollView.bounds.width
        
        for viewController in suplenceViewControllers {
            viewController.view.frame.size = scrollView.bounds.size
            viewController.view.frame.origin.x = CGFloat(viewController.index) * scrollView.bounds.size.width
            viewController.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Change Day
    func transitionToDay(_ day: Int) {
        scrollView.contentOffset.x = CGFloat(day) * scrollView.bounds.size.width
    }
    
    // MARK: - Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = scrollView.contentOffset.x / scrollView.bounds.size.width
        pageControl.currentPage = Int(currentIndex)
    }
}
