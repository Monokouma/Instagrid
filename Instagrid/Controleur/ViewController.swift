//
//  ViewController.swift
//  Instagrid
//
//  Created by Thomas Aurange on 13/03/2020.
//  Copyright © 2020 Thomas Aurange. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {


    //MARK:- viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rectangleOnBottomPatternButton.isSelected = true
        bottomLeftView.isHidden = true
        
        imagePicker.delegate = self
        
        swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeOutMainBlueView(sender:)))
        
        guard let swipeGesture = swipeGestureRecognizer else {fatalError()}
        mainBlueView.addGestureRecognizer(swipeGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(swipeDirection), name: UIDevice.orientationDidChangeNotification, object: nil)
        

    }//End of viewDidLoad
    
    
    //MARK: -Outlet Connection

    

    @IBOutlet var patternBouton: [UIButton]!
    
    @IBOutlet weak var topLeftView: UIView!
    @IBOutlet weak var topRightView: UIView!
    @IBOutlet weak var bottomLeftView: UIView!
    @IBOutlet weak var bottomRightView: UIView!
    
    @IBOutlet weak var rectangleOnTopPatternButton: UIButton!
    @IBOutlet weak var rectangleOnBottomPatternButton: UIButton!
    @IBOutlet weak var fourSquarePatternButton: UIButton!
    
    
    
    //MARK: -Label Portrait/Landscape modification
    
    @IBOutlet weak var swipeUpOrLeftLabel: UILabel!
    
    var isMyFirstStart = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if (isMyFirstStart) {
            
            isMyFirstStart = false
            detectOrientation()
            
        }//End of if (myFirstStart)
        
    }//End of override func viewDidLayoutSubviews()
    
   fileprivate func detectOrientation() {
        if UIDevice.current.orientation.isLandscape {
            print("Landsacape")
            self.swipeUpOrLeftLabel.text = "Swipe left to share"
            
        } else {
            print("Portrait")
            self.swipeUpOrLeftLabel.text = "Swipe up to share"
            
        }//End of if UIDevice.current.orientation.isLandscape
        
    }//End of func detectOrientation()
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        detectOrientation()
        
    }//End of override func viewWillTransition
    
    
    
    
    
    //MARK: -Image Picker - Source Choice - Set Image for buttons
    
    private var selectedButton : UIButton?
    
    //instance de la classe UIImagePickerController()
    private let imagePicker = UIImagePickerController()
    
    @IBAction func imageButton(_ sender: UIButton) {
        selectedButton = sender
        
        imagePicker.allowsEditing = true
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(imagePicker, animated: true, completion: nil)
        
    }//End of @IBAction func imageButton(_ sender: UIButton)
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        let pickedImage = info[.originalImage] as? UIImage
            selectedButton?.setImage(pickedImage, for: .normal)
            selectedButton?.contentMode = .scaleAspectFill
        picker.dismiss(animated: true, completion: nil)
        
    }//End of func imagePickerController
    

    //MARK: -Pattern Modifications
    
    
    @IBAction func didPatternButtonTaped(_ sender: UIButton) {
        
        patternBouton.forEach{$0.isSelected = false}
        sender.isSelected = true
        
        patternManagement(sender)
        
    }//End of @IBAction func patternButtonTaped(_ sender: UIButton)
    
    fileprivate func patternManagement(_ sender: UIButton) {
        
        switch sender.tag {
            
        case 1 :
            topLeftView.isHidden = true
            bottomLeftView.isHidden = false
        case 2 :
            bottomLeftView.isHidden = true
            topLeftView.isHidden = false
        case 3 :
            bottomLeftView.isHidden = false
            topLeftView.isHidden = false
        default:
            break
        }//End of switch sender.tag
    }//End of fileprivate func patternManagement(_ sender: UIButton)
    
    //MARK: -Swipe Gesture for Sharing + View Moving while sharing
    
    
    @IBOutlet weak var mainBlueView: UIView!
    
    var swipeGestureRecognizer: UISwipeGestureRecognizer?
    
    @objc func swipeDirection() {
        if UIDevice.current.orientation == .portrait {
            swipeGestureRecognizer?.direction = .up
        } else if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            swipeGestureRecognizer?.direction = .left
        }//End of if UIDevice.current.orientation == .portrait
    }//End of @objc func swipeDirection()
    
    
    @objc func swipeOutMainBlueView(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            switch sender.direction {
            case .up :
                swipeUp(gesture: sender)
            case .left :
                swipeLeft(gesture: sender)
            default :
                break
            }//End of switch sender.direction
        }//End of if sender.state == .ended
    }//End of @objc func swipeOutMainBlueView(sender: UISwipeGestureRecognizer)
    

    
   fileprivate func swipeUp(gesture: UISwipeGestureRecognizer) {

    UIView.animate(withDuration: 0.5, animations: {
            self.mainBlueView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        }, completion: {
            (true) in
            self.shareView()
        })
        
    }//End of  func swipeUp(gesture: UISwipeGestureRecognizer)
    
    fileprivate func swipeLeft(gesture: UISwipeGestureRecognizer) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.mainBlueView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        }, completion: {
            (true) in
            self.shareView()
        })
        
    }//End of func swipeLeft(gesture: UISwipeGestureRecognizer)


    
    //MARK: -Share Sheet Animation + UIActivityController + reset mainBlueView after sharing
    
    fileprivate func shareView() {

        let items = [mainBlueView.asImage]

        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)

        present(activityController, animated: true)

        activityController.completionWithItemsHandler = { activity, sucess, items, error in

            UIView.animate(withDuration: 1, animations: {

                self.mainBlueView.transform = .identity
            }//End of UIView.animate(withDuration: 0.5, animations:
                
        )}//End of activityController.completionWithItemsHandler =
        
    }//End of func shareView()

}//End of class ViewController: UIViewController

//MARK: -Transfrom mainBlueView to UIImage object

extension UIView {
    
    var asImage : UIImage {

        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)

        let image = renderer.image { i  in

            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }

        return image
    }
    

    
}
