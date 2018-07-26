//
//  CustomSegue.swift
//  GorilasApp
//
//  Created by Jose De Jesus Garfias Lopez on 07/04/16.
//  Copyright © 2016 Jose De Jesus Garfias Lopez. All rights reserved.
//

import UIKit

class MenuBusquedaSegue: UIStoryboardSegue {
    
    override func perform() {
        
        let ContainerVC:ViewController = self.source as! ViewController;
        
        let NextViewController:UIViewController = self.destination;
        let CurrentViewController:UIViewController = ContainerVC.CurrentViewController;
        
        ContainerVC.addChildViewController(NextViewController);
        CurrentViewController.willMove(toParentViewController: nil);
        
        NextViewController.view.autoresizingMask = [UIViewAutoresizing.flexibleWidth , UIViewAutoresizing.flexibleHeight];
        NextViewController.view.frame = CurrentViewController.view.frame;
        NextViewController.view.translatesAutoresizingMaskIntoConstraints = true;
        
        ContainerVC.transition(
            from: CurrentViewController,
            to: NextViewController,
            duration:0.1 ,
            options: UIViewAnimationOptions.transitionCrossDissolve,
            animations:nil,
            completion: { finished in
                ContainerVC.CurrentViewController = NextViewController;
                CurrentViewController.removeFromParentViewController();
                NextViewController.didMove(toParentViewController: ContainerVC);
            }
        )
        
        
    }
    
}
