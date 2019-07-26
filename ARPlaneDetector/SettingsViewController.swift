/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import PDColorPicker

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerFinished(_ settingsViewController: SettingsViewController)
}

class SettingsViewController: UIViewController, Dimmable {
    
    @IBOutlet weak var sliderBrush: UISlider!
    @IBOutlet weak var sliderOpacity: UISlider!
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var labelBrush: UILabel!
    @IBOutlet weak var labelOpacity: UILabel!
    
    @IBOutlet weak var sliderRed: UISlider!
    @IBOutlet weak var sliderGreen: UISlider!
    @IBOutlet weak var sliderBlue: UISlider!
    
    @IBOutlet weak var labelRed: UILabel!
    @IBOutlet weak var labelGreen: UILabel!
    @IBOutlet weak var labelBlue: UILabel!
    
    @IBOutlet weak var ChooseColor: UIButton!
    
    var brush: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    
    weak var svcDelegate: SettingsViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sliderBrush.value = Float(brush)
        labelBrush.text = String(format: "%.1f", brush)
        sliderOpacity.value = Float(opacity)
        labelOpacity.text = String(format: "%.1f", opacity)
        sliderRed.value = Float(red * 255.0)
        labelRed.text = Int(sliderRed.value).description
        sliderGreen.value = Float(green * 255.0)
        labelGreen.text = Int(sliderGreen.value).description
        sliderBlue.value = Float(blue * 255.0)
        labelBlue.text = Int(sliderBlue.value).description
        
        drawPreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
   //     delegate?.settingsViewControllerFinished(SettingsViewController)
    }
    
    // MARK: - Actions
    
    @IBAction func closePressed(_ sender: Any) {
        //svcDelegate.settingsViewControllerFinished(self)
    }
    
    @IBAction func brushChanged(_ sender: UISlider) {
        brush = CGFloat(sender.value)
        labelBrush.text = String(format: "%.1f", brush)
        drawPreview()
    }
    
    @IBAction func onCloseTouchDown(_ sender: Any) {
        //delegate?.settingsViewControllerFinished(self)
         svcDelegate.settingsViewControllerFinished(self)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func opacityChanged(_ sender: UISlider) {
        opacity = CGFloat(sender.value)
        labelOpacity.text = String(format: "%.1f", opacity)
        drawPreview()
    }
    
    @IBAction func colorChanged(_ sender: UISlider) {
        red = CGFloat(sliderRed.value / 255.0)
        labelRed.text = Int(sliderRed.value).description
        green = CGFloat(sliderGreen.value / 255.0)
        labelGreen.text = Int(sliderGreen.value).description
        blue = CGFloat(sliderBlue.value / 255.0)
        labelBlue.text = Int(sliderBlue.value).description
        
        drawPreview()
    }
    
    @IBAction func onChooseColorTouchDown(_ sender: Any) {
        let current = view.backgroundColor ?? .red
        
        /**
         Initializes a PDColorPickerViewController with the initial color,
         button foreground (tint color), and completion handler.
         
         The completion returns on the main thread so it is suitable for UI manipulation directly.
         
         The completion handler gives the new color as an optional PDColor object.
         If the user taps **Cancel**, the returned color is `nil`. The color is not `nil` if the
         user taps **Save**.
         */
        let colorPicker = PDColorPickerViewController(initialColor: current, tintColor: .blue) {
            [weak self] newColor in
            
            // Un-dim the view once the color picker is dismissed
            self?.undim()
            
            // Check to see if the user selected a new color
            guard let color = newColor else { return }
            
            // Use the new color to update the view
            //self?.view.backgroundColor = color.uiColor
            
            self?.red = color.rgba.r
            self?.green = color.rgba.g
            self?.blue = color.rgba.b
            
            //self?.chooseColorButton.setTitleColor(color.appropriateForegroundColor, for: .normal)
            
            self?.setNeedsStatusBarAppearanceUpdate()
            self?.drawPreview()
        }
        
        // Dim the presenting view controller for a better appearance
        dim()
        
        // Present the color picker modally
        present(colorPicker, animated: true)
        
    }
    func drawPreview() {
        UIGraphicsBeginImageContext(previewImageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setLineCap(.round)
        context.setLineWidth(brush)
        context.setStrokeColor(UIColor(red: red, green: green, blue: blue, alpha: opacity).cgColor)
        context.move(to: CGPoint(x: 45, y: 45))
        context.addLine(to: CGPoint(x: 45, y: 45))
        context.strokePath()
        previewImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}


