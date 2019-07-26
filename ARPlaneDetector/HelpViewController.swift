//
//  HelpViewController.swift
//  LennonWallHK
//
//  Created by Adrian Yeung on 16/7/2019.
//  Copyright © 2019 adrianyeung. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onCloseTouchDown(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
}
