//
//  ViewController.swift
//  DocParser
//
//  Created by Wesley Yang on 16/4/20.
//  Copyright © 2016年 paf. All rights reserved.
//

import UIKit
import Zip
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do{
        
//            let documentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.UserDomainMask, true)
            if let filePath = NSBundle.mainBundle().URLForResource("Fable", withExtension: "docx") {
                
                let unzipDirectory = try Zip.quickUnzipFile(filePath)
                print(unzipDirectory)
            }
            
        }catch{
            print(error)
        }
        
    }



}

//-(NSString *) getDocumentsDirectory {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains
//    (NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    return documentsDirectory;
//}