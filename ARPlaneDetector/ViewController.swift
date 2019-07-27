//
//  ViewController.swift
//  ARPlaneDetector
//
//  Created by Ben Lambert on 2/8/18.
//  Copyright © 2018 collectiveidea. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ARVideoKit
import OnboardKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, DrawViewControllerDelegate {
    
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var random: UIButton!
    
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var btnDraw: UIButton!
    
    @IBOutlet weak var btnPhoto: UIButton!
    
    let sceneManager = ARSceneManager()
    
    //let recorder = RPScreenRecorder.shared()
    
    var myImage: UIImage!
    
    var toggleShowGrid: Bool = false
    
    var myImageSize: Float = 1.0 // small = 1.0, medium =1.5, large = 2.0
    
    let colorArray = [UIColor(red: CGFloat(255/255), green: 126/255, blue: 185/255, alpha: 1),
                      UIColor(red: 255/255, green: 101/255, blue: 163/255, alpha: 1),
                      UIColor(red: 122/255, green: 252/255, blue: 255/255, alpha: 1),
                      UIColor(red: 254/255, green: 255/255, blue: 156/255, alpha: 1),
                      UIColor(red: 255/255, green: 247/255, blue: 64/255, alpha: 1)]

    let paperSizeArray: [[CGFloat]] = [[0.065, 0.075], [0.148, 0.21], [0.21 ,0.295]]
    
    var recorder: RecordAR?
    
    var recordMode: Int = 0 // 0 = photo, 1 = video
    
    var paperSize: Int = 0 // 0 = post-it, 1 = A3, 2 = A4
   /* enum recordMode {
        case Photo
        case Video
    }*/
    
    var paperColor: UIColor = UIColor.white
    var paperColorMode: Int = 0 // 0 = random, 1 = choose color
    enum ARWallMode {
        case Ramdon
        case Photo
        case Draw
    }
    
    var boolResetScene : Bool = false
    
    var currentMode = ARWallMode.Ramdon
    
    lazy var onboardingPages: [OnboardPage] = {
        let pageOne = OnboardPage(title: "Create AR Lennon Wall.",
                                  imageName: "hand_smartphone-17-512",
                                  description: "1. Hold your phone, scan the walls around you.")
        
        let pageTwo = OnboardPage(title: "Yellow Grid appears",
                                  imageName: "helpgrid",
                                  description: "2. Walls are detected as yellow grids.")
        
        let pageThree = OnboardPage(title: "Tap on the Grid",
                                    imageName: "hand_smartphone-18-512",
                                    description: "3. Tap on the gird to paste memos. \nYou are making a Lennon Wall!")
        
        let pageFour = OnboardPage(title: "Mode of memo source",
                                   imageName: "helpslide4",
                                   description: "Tap the icons to switch between these modes.\nDefault mode is PRESET."
        )
        
        let pageFive = OnboardPage(title: "More buttons.....",
                                   imageName: "helpslide5",
                                   description: "You are ready to make Lennon Wall EVERYWHERE.",
                                   advanceButtonTitle: "Done")
        
        return [pageOne, pageTwo, pageThree, pageFour, pageFive]
    }()
    
    func textChanged(image: UIImage?) {
        myImage = image
    }
    
    func setMyImageSize(size: Float)
    {
        myImageSize = size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager.attach(to: sceneView)
        
        sceneManager.displayDegubInfo()
        
        /*
         Prevent the screen from being dimmed after a while as users will likely
         have long periods of interaction without touching the screen or buttons.
         */
        UIApplication.shared.isIdleTimerDisabled = true
      
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScene(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // Initialize with SceneKit scene
        recorder = RecordAR(ARSceneKit: sceneView)
        
        // Specifiy supported orientations
        recorder?.inputViewOrientations = [.portrait, .landscapeLeft, .landscapeRight]
//        random.blink()

        //random.backgroundColor = UIColor.yellow
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let DrawViewController = segue.destination as? DrawViewController {
//            DrawViewController.mainImageView.image = myImage
            //viewControllerB.text = textField.text
            currentMode = ARWallMode.Draw
            DrawViewController.delegate = self
        }
        
        
        if let ARSettingViewController = segue.destination as? ARSettingViewController {
            //            DrawViewController.mainImageView.image = myImage
            //viewControllerB.text = textField.text
            //currentMode = ARWallMode.Draw
            ARSettingViewController.arsvcDelegate = self
            ARSettingViewController.recordMode = recordMode
            ARSettingViewController.paperSize = paperSize
            ARSettingViewController.paperColor = paperColor
            ARSettingViewController.paperColorMode = paperColorMode
            ARSettingViewController.boolResetScene = boolResetScene
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
       recorder?.prepare(sceneManager.configuration)
        
        if (!isAppAlreadyLaunchedOnce()){
            showHelp()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       recorder?.rest()
    }
    
    @objc func didTapScene(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            let location = gesture.location(ofTouch: 0,
                                            in: sceneView)
            let hit = sceneView.hitTest(location,
                                        types: .existingPlaneUsingGeometry)
            
            if let hit = hit.first {
                placeBlockOnPlaneAt(hit)
            }
        default:
            print("tapped default")
        }
    }
    
    func placeBlockOnPlaneAt(_ hit: ARHitTestResult) {
        
        let box = createBox()
        
        position(node: box, atHit: hit)
        
        sceneView?.scene.rootNode.addChildNode(box)
        
    }
    
    func imageByComposing(image: UIImage, over color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let imageRect = CGRect(origin: .zero, size: image.size)
        // fill with background color
        color.set()
        UIRectFill(imageRect)
        
        
        // draw image on top
        image.draw(in: imageRect, blendMode: .multiply, alpha: 1)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }
    
    private func createBox() -> SCNNode {
        //let box = SCNBox(width: 0.065, height: 0.075, length: 0.001, chamferRadius: 0.02)
        let box = SCNBox(width: paperSizeArray[paperSize][0], height: paperSizeArray[paperSize][1], length: 0.001 , chamferRadius: 0.0)
        
        //box.firstMaterial?.diffuse.contents = UIImage(named: "post0000.jpg")
        //box.firstMaterial?.multiply.contents = colorArray.randomElement()
        
        //String filename = "post000
        
        //box.firstMaterial?.diffuse.contents = imageByComposing(image: UIImage(named: "memo000"+String(Int.random(in: 0...9))+".jpg")! ,over: colorArray.randomElement()!)
        //if (myImage == nil)
        if (currentMode == ARWallMode.Ramdon)
        {
            let filename = String(format: "memo/memo%04d.jpg", Int.random(in: 0...178))
            //let image = UIImage(named: "memo/memo0000.jpg")
            if (paperColorMode == 0)
            {
            box.firstMaterial?.diffuse.contents = imageByComposing(image: UIImage(named: filename)! ,over: colorArray.randomElement()!)
            }else{
                box.firstMaterial?.diffuse.contents = imageByComposing(image: UIImage(named: filename)! ,over: paperColor)
            }
            //box.firstMaterial?.diffuse.contents = imageByComposing(image: image! ,over: colorArray.randomElement()!)
        }
        else
        {
            if (paperColorMode == 0)
            {
                box.firstMaterial?.diffuse.contents = imageByComposing(image: myImage! ,over: colorArray.randomElement()!)
            }else{
                box.firstMaterial?.diffuse.contents = imageByComposing(image: myImage! ,over: paperColor)
            }
            
        }
        //box.firstMaterial?.diffuse.contents = colorArray.randomElement()
        
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box, options: nil))
        
        return boxNode
    }
    
    private func position(node: SCNNode, atHit hit: ARHitTestResult) {
        node.transform = SCNMatrix4(hit.anchor!.transform)
        node.eulerAngles = SCNVector3Make(node.eulerAngles.x - (Float.pi / 2), node.eulerAngles.y, node.eulerAngles.z)
        node.eulerAngles = SCNVector3Make(node.eulerAngles.x , node.eulerAngles.y, node.eulerAngles.z)
        
        let position = SCNVector3Make(hit.worldTransform.columns.3.x + node.geometry!.boundingBox.min.z, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
        
        node.position = position
    }
    
    
    @IBAction func onRandomTouchDown(_ sender: UIButton) {
        currentMode = ARWallMode.Ramdon
       
    }
    

    @IBAction func onPentoolTouchDown(_ sender: Any) {
        currentMode = ARWallMode.Draw
 
    }
    
    
    @IBAction func onPhotoTouchDown(_ sender: Any) {
        
        currentMode = ARWallMode.Photo

        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.allowsEditing = true
        
        imagePickerController.preferredContentSize = CGSize(width: 1024,height: 1024)
        
        self.present(imagePickerController,animated: true)
        {
            
        }
    }
    
    func showSimpleAlert() {
        let alert = UIAlertController(title: "Video Recorded", message: "AR Lennon Wall video saved in photo gallery",         preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onResetTouchDown(_ sender: Any) {
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        sceneView.session.run(sceneManager.configuration, options: [.resetTracking, .removeExistingAnchors])
        
        sceneManager.showPlanes = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        toggleShowGrid = false
    }
    @IBAction func onRecordTouchDown(_ sender: UIButton) {
        
        if recordMode == 0 {
            //Photo
            if recorder?.status == .readyToRecord {
                let image = self.recorder?.photo()
                self.recorder?.export(UIImage: image) { saved, status in
                    /*   if saved {
                     // Inform user photo has exported successfully
                     self.exportMessage(success: saved, status: status)
                     }*/
                    let systemSoundID: SystemSoundID = 1108
                    
                    AudioServicesPlaySystemSoundWithCompletion(systemSoundID){}
                }
 
            }
        }else{
        
        
        if recorder?.status == .readyToRecord {
            
            sceneManager.showPlanes = false
            sceneView.debugOptions = []
            toggleShowGrid = true
            
            sender.blink(duration: 0.2)

            
            // Start recording
            recorder?.record()
            
            // Change button title
            //      sender.setTitle("Stop", for: .normal)
            //      sender.setTitleColor(.red, for: .normal)
            
        }
        else if recorder?.status == .recording || recorder?.status == .paused
        {
            // Stop recording and export video to camera roll
            sender.blink(enabled:false)
            recorder?.stopAndExport()
            showSimpleAlert()
            // Change button title
            //      sender.setTitle("Record", for: .normal)
            //      sender.setTitleColor(.black, for: .normal)
            
        }
        }
    }
    
    @IBAction func onTouchDownGrid(_ sender: Any) {
        if (toggleShowGrid)
        {
            sceneManager.showPlanes = true
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
            toggleShowGrid = false
        }
        else
        {
            sceneManager.showPlanes = false
            sceneView.debugOptions = []
            toggleShowGrid = true
        }
        
    }
    
    @IBAction func tappedShoot(_ sender: Any) {
        let camera = sceneView.session.currentFrame!.camera
        let projectile = Projectile()
        
        // transform to location of camera
        var translation = matrix_float4x4(projectile.transform)
        translation.columns.3.z = -0.1
        translation.columns.3.x = 0.03
        
        projectile.simdTransform = matrix_multiply(camera.transform, translation)
        
        let force = simd_make_float4(-1, 0, -3, 0)
        let rotatedForce = simd_mul(camera.transform, force)
        
        let impulse = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
        
        sceneView?.scene.rootNode.addChildNode(projectile)
        
        projectile.launch(inDirection: impulse)
    }
    
    @IBAction func tappedDraw(_ sender: Any) {
        
    }
    @IBAction func tappedShowPlanes(_ sender: Any) {
        if (toggleShowGrid)
        {
            sceneManager.showPlanes = true
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
            toggleShowGrid = false
        }
        else
        {
            sceneManager.showPlanes = false
            sceneView.debugOptions = []
            toggleShowGrid = true
        }
    }
    
    
    
    @IBAction func tappedStop(_ sender: Any) {
        sceneManager.stopPlaneDetection()
    }
    
    @IBAction func tappedStart(_ sender: Any) {
        sceneManager.startPlaneDetection()
    }
    
    @IBAction func onHelpTouchDown(_ sender: Any) {

        showHelp()
    }
    
    @IBAction func tappedPhoto(_ sender: Any) {

    }
    
    func showHelp()
    {
        let tintColor = UIColor(red: 1.00, green: 0.52, blue: 0.40, alpha: 1.00)
        let titleColor = UIColor(red: 1.00, green: 0.35, blue: 0.43, alpha: 1.00)
        let boldTitleFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        let mediumTextFont = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        let appearanceConfiguration = OnboardViewController.AppearanceConfiguration(tintColor: tintColor,
                                                                                    titleColor: titleColor,
                                                                                    textColor: .black,
                                                                                    backgroundColor: .white,
                                                                                    imageContentMode: .scaleAspectFit,
                                                                                    titleFont: boldTitleFont,
                                                                                    textFont: mediumTextFont)
        let onboardingVC = OnboardViewController(pageItems: onboardingPages,
                                                 appearanceConfiguration: appearanceConfiguration)
        onboardingVC.modalPresentationStyle = .formSheet
        onboardingVC.presentFrom(self, animated: true)
    }
    
    func setMyImage(image: UIImage)
    {
        myImage = image
    }
    
    @IBAction func tappedRecord(_ sender: UIButton) {
        
        if sender.tag == 0 {
            //Photo
            if recorder?.status == .readyToRecord {
                let image = self.recorder?.photo()
                self.recorder?.export(UIImage: image) { saved, status in
                 /*   if saved {
                        // Inform user photo has exported successfully
                        self.exportMessage(success: saved, status: status)
                    }*/
                }
            }
        }else{
        
        if recorder?.status == .readyToRecord {
            // Start recording
            btnSetting.isEnabled = false
            recorder?.record()
            
            // Change button title
      //      sender.setTitle("Stop", for: .normal)
      //      sender.setTitleColor(.red, for: .normal)
            
        }
        else if recorder?.status == .recording || recorder?.status == .paused
        {
            // Stop recording and export video to camera roll
            btnSetting.isEnabled = true
            recorder?.stopAndExport()
            
            // Change button title
      //      sender.setTitle("Record", for: .normal)
      //      sender.setTitleColor(.black, for: .normal)
        }
        }
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            myImage = image
        }
        //imageView.image = image
        
        //picker.dismiss(animated: true, completion: nil)
      /*  let SelectMyImageSizeController = UIAlertController(title: "Select Memo Size",
                                                message: "Size does matter",
                                                preferredStyle: .actionSheet)
        
        let smallAction = UIAlertAction(title:"small", style: .default, handler: {_ in self.setMyImageSize(size: 1.0)})
        let mediumAction = UIAlertAction(title:"medium", style: .default, handler: {_ in self.setMyImageSize(size: 1.5)})
        let largeAction = UIAlertAction(title:"large", style: .default, handler: {_ in self.setMyImageSize(size: 2.0)})
        
        SelectMyImageSizeController.addAction(smallAction)
        SelectMyImageSizeController.addAction(mediumAction)
        SelectMyImageSizeController.addAction(largeAction)
        
        picker.dismiss(animated: true, completion: {
            self.present(SelectMyImageSizeController, animated: true, completion: {
            })*/
        picker.dismiss(animated: true, completion: nil)
       
    }
    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            //print("App already launched")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            //print("App launched first time")
            return false
        }
    }
    
}

extension UIButton {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self.bounds.contains(point) ? self : nil
    }
    func blink(enabled: Bool = true, duration: CFTimeInterval = 1.0, stopAfter: CFTimeInterval = 0.0 ) {
        enabled ? (UIView.animate(withDuration: duration, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 0.0 },
            completion: { [weak self] _ in self?.alpha = 1.0 })) : self.layer.removeAllAnimations()
        if !stopAfter.isEqual(to: 0.0) && enabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + stopAfter) { [weak self] in
                self?.layer.removeAllAnimations()
            }
        }
    }
}

extension ViewController: ARSettingsViewControllerDelegate {
    func settingsViewControllerFinished(_ settingsViewController: ARSettingViewController) {
        recordMode = settingsViewController.segmentedRecordMode.selectedSegmentIndex
        paperSize = settingsViewController.segmentedPaperSize.selectedSegmentIndex
        paperColorMode = settingsViewController.segmentedPaperColor.selectedSegmentIndex
        paperColor = settingsViewController.paperColor
        boolResetScene = settingsViewController.boolResetScene
        
        if (boolResetScene){
            sceneView.session.pause()
            sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                node.removeFromParentNode()
            }
            sceneView.session.run(sceneManager.configuration, options: [.resetTracking, .removeExistingAnchors])
            
            sceneManager.showPlanes = true
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
            toggleShowGrid = false
            
            boolResetScene = false
        }
        //brushWidth = settingsViewController.brush
        //recordMode = settingsViewController.
        // dismiss(animated: true)
    }
}

class Projectile: SCNNode {
    
    override init() {
        super.init()
        
        let capsule = SCNCapsule(capRadius: 0.006, height: 0.06)
        
        geometry = capsule
        
        eulerAngles = SCNVector3(CGFloat.pi / 2, (CGFloat.pi * 0.25), 0)
        
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func launch(inDirection direction: SCNVector3) {
        physicsBody?.applyForce(direction, asImpulse: true)
    }
    
}
