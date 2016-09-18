//
//  RootViewController.swift
//  GimVic
//
//  Created by Vid Drobnič on 9/18/16.
//  Copyright © 2016 Vid Drobnič. All rights reserved.
//

import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDataSource {
    static var sharedInstance: RootViewController?
    var suplenceViewControllers = [SuplenceViewController]()
    let imageView = UIImageView(image: UIImage(named: "bakcground.jpg"))
    
    var startingIndex: Int {
        let calendar = Calendar(identifier: .gregorian)
        let weekday = calendar.component(.weekday, from: Date())
        
        if weekday == 1 || weekday == 7 {
            return 0
        }
        return weekday - 2
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RootViewController.sharedInstance = self
        
        for i in 0..<5 {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "SuplenceViewController")
                as? SuplenceViewController {
                viewController.index = i
                suplenceViewControllers.append(viewController)
            }
        }
        
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        view.insertSubview(imageView, at: 0)
        
        dataSource = self
        setViewControllers([suplenceViewControllers[startingIndex]], direction: .forward, animated: false, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        imageView.frame.size = size
    }
    
    func transitionToDay(index: Int) {
        setViewControllers([suplenceViewControllers[startingIndex]], direction: .forward, animated: true, completion: nil)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return suplenceViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return startingIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? SuplenceViewController)?.index else {
            return nil
        }
        
        if index == 0 {
            return nil
        }
        
        return suplenceViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? SuplenceViewController)?.index else {
            return nil
        }
        
        if index + 1 == suplenceViewControllers.count {
            return nil
        }
        
        return suplenceViewControllers[index + 1]
    }
}
