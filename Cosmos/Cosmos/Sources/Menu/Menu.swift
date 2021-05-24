//
//  Menu.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit
import Cos

typealias SelectionAction = (_ selection: Int) -> Void
typealias InfoAction = () -> Void

class Menu : CanvasController {
    //MARK: -
    //MARK: Properties
    //A canvas that handles drawing and animating the menu's rings
    var menuRings : MenuRings!
    //A canvas that handles drawing and animating the menu's icons
    var menuIcons : MenuIcons!
    //A canvas for handling the gesture and selection highlight
    var menuSelector : MenuSelector!
    //A canvas for animating the shadow of the menu
    var menuShadow : MenuShadow!

    //A boolean for tracking when the menu is expanded (or expanding)
    var menuIsVisible = false
    //A boolean to track if the menu should revert to its closed state
    var shouldRevert = false

    //A label that instructs the user to press and hold on the menu
    var instructionLabel : UILabel!
    //A timer that will reveal the menu, shortly after the app opens and if the user doesn't press the menu
    var timer : Cos.Timer!

    //An action to trigger when the user has selected one of the icons from the menu
    var selectionAction : SelectionAction?
    //An action to trigger when the user has chosen the info button from the menu
    var infoAction : InfoAction?

    //A sound to play when the menu closes
    let hideMenuSound = AudioPlayer("menuClose.mp3")!
    //A sound to play when the menu opens
    let revealMenuSound = AudioPlayer("menuOpen.mp3")!

    //MARK: -
    //MARK: Setup
    override func setup() {
        //clear the background
        canvas.backgroundColor = clear
        //make the canvas frame fairly small
        canvas.frame = Rect(0,0,80,80)

        //create the rings
        menuRings = MenuRings()

        //create the selector
        menuSelector = MenuSelector()

        //create the icons
        menuIcons = MenuIcons()

        //create the shadow
        menuShadow = MenuShadow()
        menuShadow.canvas.center = canvas.bounds.center

        //add the canvases of each object in specific order (back to front)
        canvas.add(menuShadow.canvas)
        canvas.add(menuRings.canvas)
        canvas.add(menuSelector.canvas)
        canvas.add(menuIcons.canvas)

        //create a gesture to handle interaction
        createGesture()
        //create the instruction label
        createInstructionLabel()

        //create and start the timer, it will execute one time
        timer = Timer(interval: 5.0, count: 1) {
            self.showInstruction()
        }
        timer?.start()

        //makes the sounds a little quieter
        hideMenuSound.volume = 0.64
        revealMenuSound.volume = 0.64
    }

    //MARK: -
    //MARK: Gesture
    func createGesture() {
        //add a long press gesture to the menu's canvas
        canvas.addLongPressGestureRecognizer { [weak self] _ , location, state in
            guard let self = self else { return }
            switch state {
            case .began:
                self.revealMenu() //reveals the menu when the gesture begins
            case .changed:
                self.menuSelector.update(location: location) //updates the menu based on the user's press location
            case .cancelled, .ended, .failed:
                //if the selection action exists
                if let sa = self.selectionAction,
                   self.menuSelector.currentSelection >= 0 {
                    //trigger it with the current selection
                    sa(self.menuSelector.currentSelection)
                }
                //hide the menu label
                self.menuSelector.menuLabel?.hidden = true
                //reset the current selection
                self.menuSelector.currentSelection = -1
                //disable interaction (temporarily)
                self.canvas.interactionEnabled = false

                //hide the highlight if it is visible
                if self.menuSelector.highlight?.hidden == false {
                    self.menuSelector.highlight?.hidden = true
                }
                //hide the menu if it is visible
                if self.menuIsVisible {
                    self.hideMenu()
                } else {
                    //if the menu isn't visible (i.e. still animating out), flag it to revert
                    self.shouldRevert = true
                }
                //if the infobutton exists
                if let ib = self.menuSelector.infoButton {
                    //hit test it to see if the user has selected info
                    if ib.hitTest(location, from: self.canvas),
                       //if so, wait a bit (for the menu to close) and then run the info action
                       let ia = self.infoAction {
                        wait(0.75) {
                            ia()
                        }
                    }
                }
            default:
                _ = ""
            }
        }
    }

    //MARK: -
    //MARK: Menu Reveal / Hide
    func revealMenu() {
        //stop the timer
        timer?.stop()
        //hide the instruction label
        hideInstruction()

        //flag the menu as not visible (just in case)
        menuIsVisible = false
        //play the reveal sound
        revealMenuSound.play()
        //reveal the shadow
        menuShadow.reveal?.animate()
        //animate the thick ring
        menuRings.thickRingOut?.animate()
        //animate the thin rings
        menuRings.thinRingsOut?.animate()
        //move the icons to their outer positions
        menuIcons.signIconsOut?.animate()

        //wait a bit
        wait(0.33) {
            //reveal the dividing lines
            self.menuRings.revealHideDividingLines(1.0)
            //reveal the sign icons
            self.menuIcons.revealSignIcons?.animate()
        }
        //wait a little bit more
        wait(0.66) {
            //reveal the dashed rings
            self.menuRings.revealDashedRings?.animate()
            //reveal the info button
            self.menuSelector.revealInfoButton?.animate()
        }
        //the menu should be open at this point
        wait(1.0) {
            //so, set visible to true
            self.menuIsVisible = true
            //check if the menu should revert (i.e. if the user released the press while the menu was animating out
            if self.shouldRevert {
                self.hideMenu()
                self.shouldRevert = false
            }
        }
    }

    func hideMenu() {
        //if the instruction label is visible, hide it
        if (instructionLabel?.alpha ?? 0) > 0.0 {
            hideInstruction()
        }

        //treat the menu as not visible while animating back to its closed state
        menuIsVisible = false
        //play the hide sound
        hideMenuSound.play()
        //hide the dashed rings
        menuRings.hideDashedRings?.animate()
        //hide the info button
        menuSelector.hideInfoButton?.animate()
        //hide the dashed lines
        menuRings.revealHideDividingLines(0.0)

        //wait a little bit
        wait(0.16) {
            //hide the icons
            self.menuIcons.hideSignIcons?.animate()
        }
        //wait a little bit longer
        wait(0.57) {
            //animate the thin rings
            self.menuRings.thinRingsIn?.animate()
        }
        //wait just a tiny bit more
        wait(0.66) {
            //move the menu icons back to their close position
            self.menuIcons.signIconsIn?.animate()
            //animate the thick ring in
            self.menuRings.thickRingIn?.animate()
            //hide the shadow
            self.menuShadow.hide?.animate()
            //re-enable interaction on the canvas
            self.canvas.interactionEnabled = true
        }
    }

    //MARK: -
    //MARK: Instruction Label
    func createInstructionLabel() {
        //create a basic label, style it and add it to the canvas
        instructionLabel = UILabel(frame: CGRect(x: 0,y: 0,width: 320, height: 44))
        instructionLabel.text = "press and hold to open menu\nthen drag to choose a sign"
        instructionLabel.font = UIFont(name: "Menlo-Regular", size: 13)
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .white
        instructionLabel.isUserInteractionEnabled = false
        instructionLabel.center = CGPoint(x: view.center.x, y: view.center.y - 128)
        instructionLabel.numberOfLines = 2
        instructionLabel.alpha = 0.0
        canvas.add(instructionLabel)
    }

    func showInstruction() {
        ViewAnimation(duration: 2.5) {
            self.instructionLabel?.alpha = 1.0
        }.animate()
    }

    func hideInstruction() {
        ViewAnimation(duration: 0.25) {
            self.instructionLabel?.alpha = 0.0
        }.animate()
    }
}
