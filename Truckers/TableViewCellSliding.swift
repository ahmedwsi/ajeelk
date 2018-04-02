//
//  TableViewCellSliding.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 7/11/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit

protocol SlidingCellDelegate {
    // tell the TableView that a swipe happened
    func hasPerformedSwipe(touch: CGPoint)
    func hasPerformedTap(touch: CGPoint)
}

class SlidingTableViewCell: UITableViewCell {

    @IBOutlet weak var ServiceIdLbl: UILabel!
    @IBOutlet weak var ServiceNameLabl: UILabel!
    @IBOutlet weak var ServicePriceLbl: UILabel!
    
    var delegate: SlidingCellDelegate?
    var originalCenter = CGPoint()
    var isSwipeSuccessful = false
    var touch = CGPoint()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // add a PAN gesture
        let pRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SlidingTableViewCell.handlePan(_:)))
        pRecognizer.delegate = self
        addGestureRecognizer(pRecognizer)
        
        // add a TAP gesture
        // note that adding the PAN gesture to a cell disables the built-in tap responder (didSelectRowAtIndexPath)
        // so we can add in our own here if we want both swipe and tap actions
        let tRecognizer = UITapGestureRecognizer(target: self, action: #selector(SlidingTableViewCell.handleTap(_:)))
        tRecognizer.delegate = self
        addGestureRecognizer(tRecognizer)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: superview!)
            //look for right-swipe
            if (fabs(translation.x) > fabs(translation.y)) && (translation.x > 0){
                
                // look for left-swipe
                //if (fabs(translation.x) > fabs(translation.y)) && (translation.x < 0){
                //print("gesture 1")
                touch = panGestureRecognizer.location(in: superview)
                return true
            }
            //not left or right - must be up or down
            return false
        }else if gestureRecognizer is UITapGestureRecognizer {
            touch = gestureRecognizer.location(in: superview)
            return true
        }
        return false
    }
    
    func handleTap(_ recognizer: UITapGestureRecognizer){
        // call function to get indexPath since didSelectRowAtIndexPath will be disabled
        delegate?.hasPerformedTap(touch: touch)
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            originalCenter = center
        }
        
        if recognizer.state == .changed {
            checkIfSwiped(recongizer: recognizer)
        }
        
        if recognizer.state == .ended {
            let originalFrame = CGRect(x: 0, y: frame.origin.y, width: bounds.size.width, height: bounds.size.height)
            if isSwipeSuccessful{
                delegate?.hasPerformedSwipe(touch: touch)
                
                //after 'short' swipe animate back to origin quickly
                moveViewBackIntoPlaceSlowly(originalFrame: originalFrame)
            } else {
                //after successful swipe animate back to origin slowly
                moveViewBackIntoPlace(originalFrame: originalFrame)
            }
        }
    }
    
    func checkIfSwiped(recongizer: UIPanGestureRecognizer) {
        let translation = recongizer.translation(in: self)
        center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
        
        //this allows only swipe-right
        isSwipeSuccessful = frame.origin.x > frame.size.width / 2.0  //pan is 1/2 width of the cell
        
        //this allows only swipe-left
        //isSwipeSuccessful = frame.origin.x < -frame.size.width / 3.0  //pan is 1/3 width of the cell
    }
    
    func moveViewBackIntoPlace(originalFrame: CGRect) {
        UIView.animate(withDuration: 0.2, animations: {self.frame = originalFrame})
    }
    func moveViewBackIntoPlaceSlowly(originalFrame: CGRect) {
        UIView.animate(withDuration: 1.5, animations: {self.frame = originalFrame})
    }
    
}
