//
//  CropOriginalViewController.swift
//  ViedoMaker
//
//  Created by Mahmoud Nasser on 4/11/20.
//  Copyright © 2020 Ibtikar. All rights reserved.
//

import UIKit

class CropOriginalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    

    @IBAction func cropButtonTapped(_ sender: Any) {
        let videoCreateVC = Container.Controllers.createVideoCreatorViewController()
        self.navigationController?.pushViewController(videoCreateVC, animated: true)
        }
}
