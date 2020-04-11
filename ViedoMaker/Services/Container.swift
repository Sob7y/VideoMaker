//
//  Container.swift
//  MVVMDemo
//
//  Created by Mohammed Khaled on 11/26/19.
//  Copyright © 2019 Ibtikar. All rights reserved.
//

import Foundation
import UIKit

class Container {
        class AppBase {
        class func baseNavigationController() -> UINavigationController {
               
               let navigation = UINavigationController()
               navigation.interactivePopGestureRecognizer?.isEnabled = false
               navigation.edgesForExtendedLayout = []
               navigation.extendedLayoutIncludesOpaqueBars = false
               navigation.setNavigationBarHidden(false, animated: false)
               navigation.view.backgroundColor = .clear
               navigation.navigationBar.setBackgroundImage(UIImage(), for: .default)
               navigation.navigationBar.shadowImage = UIImage()
               navigation.navigationBar.backgroundColor = .clear
               navigation.navigationBar.tintColor = .white
               return navigation
           }
    }
    
    class Controllers {
        
        class func createCropOriginalController() -> UIViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let originalVC = storyboard.instantiateViewController(
                withIdentifier: "CropOriginalViewController") as? CropOriginalViewController else {return UIViewController()}
            
            let navigation = Container.AppBase.baseNavigationController()
            navigation.setViewControllers([originalVC], animated: true)
            return navigation
        }

        class func createVideoCreatorViewController() -> UIViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let createVC = storyboard.instantiateViewController(
                withIdentifier: "CreateVideoViewController") as? CreateVideoViewController else {return UIViewController()}
            
            return createVC
        }
    }
}
