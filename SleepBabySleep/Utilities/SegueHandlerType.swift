//
//  SegueHandlerType.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 08/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

protocol SegueHandlerType {
    associatedtype SegueIdentifier: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String
{
    
    func performSegueWithIdentifier(_ segueIdentifier: SegueIdentifier, sender: AnyObject?) {
        
        performSegue(withIdentifier: segueIdentifier.rawValue, sender: sender)
    }
    
    func segueIdentifierForSegue(_ segue: UIStoryboardSegue) -> SegueIdentifier {
        
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
                fatalError("Invalid segue identifier \(segue.identifier).") }
        
        return segueIdentifier
    }
}
