//
//  JedilnikViewController.swift
//  GimVic
//
//  Created by Vid Drobnic on 11/13/15.
//  Copyright © 2015 Vid Drobnič. All rights reserved.
//

import UIKit

class JedilnikViewController: UIViewController {
    let mainScrollView = UIScrollView()
    let tabBarScroll = UIScrollView()
    let malicaTableView = JedilnikTableView()
    let kosiloTableView = JedilnikTableView()
    
    let refreshButton = UIButton()
    let refreshing = UIActivityIndicatorView()
    
    var sideMenuTransitioningDelegate = VDDSideMenuTransitioningDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadViews", name: "VDDJedilnikFetchComplete", object: nil)
        
        mainScrollView.frame = CGRect(x: 0, y: 60, width: view.bounds.size.width, height: view
        .bounds.size.height - 60)
        mainScrollView.pagingEnabled = true
        mainScrollView.userInteractionEnabled = true
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.contentSize = CGSize(width: 2 * view.bounds.size.width, height: view.bounds.size.height - 60)
        mainScrollView.delegate = self
        mainScrollView.backgroundColor = UIColor(red: 165.0 / 255.0, green: 214.0 / 255.0, blue: 167.0 / 255.0, alpha: 1.0)
        view.addSubview(mainScrollView)
        
        malicaTableView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - 60)
        malicaTableView.type = .Malica
        kosiloTableView.frame = CGRect(x: view.bounds.size.width, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - 60)
        kosiloTableView.type = .Kosilo
        
        let tabBar = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 60))
        tabBar.backgroundColor = UIColor(red: 76.0 / 255.0, green: 175.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
        view.addSubview(tabBar)
        
        let sideMenuImage = UIImage(named: "Menu.png")
        let button = UIButton()
        button.addTarget(self, action: "showSideMenu", forControlEvents: .TouchUpInside)
        button.setImage(sideMenuImage, forState: .Normal)
        button.frame = CGRect(x: 20, y: 20, width: 30, height: 30)
        view.addSubview(button)
        
        let refreshImage = UIImage(named: "Reload.png")
        refreshButton.addTarget(self, action: "refresh", forControlEvents: .TouchUpInside)
        refreshButton.setImage(refreshImage, forState: .Normal)
        refreshButton.frame = CGRect(x: view.bounds.size.width - 50, y: 20, width: 30, height: 30)
        view.addSubview(refreshButton)
        
        refreshing.frame = CGRect(x: view.bounds.size.width - 50, y: 20, width: 30, height: 30)
        refreshing.color = UIColor(red: 200.0 / 255.0, green: 230.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0)
        view.addSubview(refreshing)
        refreshing.stopAnimating()
        
        tabBarScroll.frame = CGRect(x: 70, y: 20, width: view.bounds.size.width - 2 * 70, height: 30)
        view.addSubview(tabBarScroll)
        tabBarScroll.userInteractionEnabled = false
        tabBarScroll.showsHorizontalScrollIndicator = false
        tabBarScroll.showsVerticalScrollIndicator = false
        tabBarScroll.pagingEnabled = true
        tabBarScroll.contentSize = CGSize(width: 2 * tabBarScroll.bounds.size.width, height: tabBarScroll.bounds.size.height)
        
        let malicaLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tabBarScroll.bounds.size.width, height: tabBarScroll.bounds.size.height))
        let kosiloLabel = UILabel(frame: CGRect(x: tabBarScroll.bounds.size.width, y: 0, width: tabBarScroll.bounds.size.width, height: tabBarScroll.bounds.size.height))
        
        malicaLabel.text = "Malica"
        kosiloLabel.text = "Kosilo"
        
        malicaLabel.textAlignment = .Center
        kosiloLabel.textAlignment = .Center
        
        malicaLabel.textColor = UIColor(red: 200.0 / 255.0, green: 230.0 / 255.0, blue: 201.0 / 255.0, alpha: 1.0)
        kosiloLabel.textColor = malicaLabel.textColor
        
        tabBarScroll.addSubview(malicaLabel)
        tabBarScroll.addSubview(kosiloLabel)
    }
    
    func reloadViews() {
        if refreshing.isAnimating() {
            refreshing.stopAnimating()
            refreshButton.hidden = false
        }
        
        malicaTableView.reloadData()
        kosiloTableView.reloadData()
    }
    
    func refresh() {
        if !refreshButton.hidden {
            refreshButton.hidden = true
            refreshing.startAnimating()
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            JedilnikDataFetch.sharedInstance.downloadJedilnik()
        }
    }
    
    func showSideMenu() {
        let sideMenu = VDDSideMenuViewController(selectedView: .JedilnikView)
        sideMenu.modalPresentationStyle = .Custom
        sideMenu.transitioningDelegate = sideMenuTransitioningDelegate
        
        presentViewController(sideMenu, animated: true, completion: nil)
    }
}

extension JedilnikViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let percentageScrolled = scrollView.contentOffset.x / scrollView.contentSize.width
        tabBarScroll.contentOffset.x = tabBarScroll.contentSize.width * percentageScrolled
    }
}