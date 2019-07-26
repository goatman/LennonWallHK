//
//  ARSettingViewController.swift
//  LennonWallHK
//
//  Created by Adrian Yeung on 24/7/2019.
//  Copyright © 2019 adrianyeung. All rights reserved.
//

import UIKit
import PDColorPicker

protocol ARSettingsViewControllerDelegate: class {
    func settingsViewControllerFinished(_ settingsViewController: ARSettingViewController)
}

class ARSettingViewController: UIViewController, Dimmable {

    weak var arsvcDelegate: ARSettingsViewControllerDelegate!
    
    var recordMode : Int = 0
    var paperSize : Int = 0
    var paperColorMode : Int = 0
    var paperColor : UIColor = UIColor.yellow
    var boolResetScene : Bool = false
    
    @IBOutlet weak var segmentedRecordMode: UISegmentedControl!
    @IBOutlet weak var segmentedPaperSize: UISegmentedControl!
    @IBOutlet weak var segmentedPaperColor: UISegmentedControl!
    @IBOutlet weak var buttonPaperColor: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedRecordMode.selectedSegmentIndex = recordMode
        segmentedPaperSize.selectedSegmentIndex = paperSize
        segmentedPaperColor.selectedSegmentIndex = paperColorMode
        buttonPaperColor.backgroundColor = paperColor
        
        //segmentedPaperColor.setbac
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCloseTouchDown(_ sender: Any) {
        arsvcDelegate.settingsViewControllerFinished(self)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPaperColorChanged(_ sender: UISegmentedControl) {
    if (sender.selectedSegmentIndex == 1)
    {
        choosePaperColor()
        }
    }
    
    @IBAction func onPaperColorTouchDown(_ sender: Any) {
        self.segmentedPaperColor.selectedSegmentIndex = 1
        choosePaperColor()
    }
    
    @IBAction func onResetTouchDown(_ sender: Any) {
        boolResetScene = true
        arsvcDelegate.settingsViewControllerFinished(self)
        self.navigationController?.popViewController(animated: true)
    }
    
    func choosePaperColor(){
        let current = self.paperColor
        
        let colorPicker = PDColorPickerViewController(initialColor: current, tintColor: .blue) {
            [weak self] newColor in
            // Un-dim the view once the color picker is dismissed
            self?.undim()
            // Check to see if the user selected a new color
            guard let color = newColor else { return }
            
            self?.paperColor = color.uiColor
            self?.buttonPaperColor.backgroundColor = color.uiColor
            self?.setNeedsStatusBarAppearanceUpdate()
            
        }
        dim()
        present(colorPicker, animated: true)
    }
    /*
     
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
