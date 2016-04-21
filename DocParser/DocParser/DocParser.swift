//
//  DocParser.swift
//  DocParser
//
//  Created by Wesley Yang on 16/4/20.
//  Copyright © 2016年 paf. All rights reserved.
//

import Foundation
import Zip
import SWXMLHash

enum DocXMLAtt:String {
    
    case Value = "w:val"
}

class DocParser{
    typealias XMLNode = XMLIndexer
    
    func parseFile(fileURL:NSURL) throws -> NSAttributedString{
        //unzip
        let unzipDirectory = try Zip.quickUnzipFile(fileURL)
        print(unzipDirectory)
        
        let mainDocument = unzipDirectory.URLByAppendingPathComponent("word/document.xml")
        print(mainDocument.path)
        
        let xml = try SWXMLHash.parse(String(contentsOfURL:mainDocument));
        return parseXML(xml)
    }
    
    private func parseXML(xml:XMLNode) -> NSAttributedString{
        
        let bodyXML = xml["w:document"]["w:body"]
        
        let paragraphs = bodyXML["w:p"].all
        
        let docAttString = NSMutableAttributedString()
        
        for paragraphXML in paragraphs {
            print("found para")
            let paraPropertyXML = paragraphXML["w:pPr"]
            let paraStyle = getParagraphStyleFromXML(paraPropertyXML)
            print(paraStyle)
            
            let paragraphString = NSMutableAttributedString()
            
            for node in paragraphXML.children {
                if node.element?.name == "w:r" {
                    print("hello")
                    if let attStr = getAttStringFromRun(node){
                        paragraphString.appendAttributedString(attStr)
                    }
                }else if node.element?.name == "w:hyperlink"{
                    if let attStr = getAttStringFromRun(node["w:r"]){
                        paragraphString.appendAttributedString(attStr)
                    }
                }
            }
            
            paragraphString .mutableString .appendString("\n")
            
            let fullRange = NSRange.init(location: 0, length: paragraphString.length)
            paragraphString.addAttributes(paraStyle, range: fullRange)
            
            docAttString .appendAttributedString(paragraphString)
        }
        
        return docAttString
    }
    
    //<w:jc>
    private func getParagraphStyleFromXML(paraPropertyXML:XMLNode) -> Dictionary<String,AnyObject>{
        let jcXML = paraPropertyXML["w:jc"]
        let paraStyle = NSMutableParagraphStyle()
        if let att = jcXML.element?.attributes[DocXMLAtt.Value.rawValue]{
            switch  att{
                case "left": paraStyle.alignment = .Left
                case "right": paraStyle.alignment = .Right
                case "center": paraStyle.alignment = .Center
                case "justified": paraStyle.alignment = .Justified
                default: break
            }
        }
        return [NSParagraphStyleAttributeName:paraStyle]
    }
    
    
    private func getAttStringFromRun(run:XMLNode) -> NSAttributedString? {
        //get text
        if let text = run["w:t"].element?.text {
        
            //int
            var isBold = false
            var isItalic = false
            var isUnderline = false
            var fontSize : Float = 12.0
            var currentFontName : String? = nil
            let attString = NSMutableAttributedString.init(string: text)

            let propertyNode = run["w:rPr"]
            
            func processFontFromFontNode(node:XMLNode){
                var currentFontName = node.element?.attributes["w:ascii"]
                if currentFontName == nil {
                    currentFontName = node.element?.attributes["w:cs"]
                }
                if currentFontName == nil {
                    currentFontName = "Arial"
                }
            }
            
            func processFontSizeFromNode(node:XMLNode){
                let size = node.element?.attributes["w:val"]
                if let size2 = size{
                    fontSize = Float(size2)!/2
                }
            }
            
            if propertyNode["w:b"].element != nil {
                isBold = true
            }
            if (propertyNode["w:i"].element) != nil {
                isItalic = true
            }
            if (propertyNode["w:u"].element) != nil {
                isUnderline = true
            }
            
            var traits = UIFontDescriptorSymbolicTraits()
            if isBold {
                traits = traits.union(.TraitBold)
            }
            if isItalic {
                traits = traits.union(.TraitItalic)
            }
            //get size
            processFontSizeFromNode(propertyNode["w:sz"])
            
            //get font name
            processFontFromFontNode(propertyNode["w:rFonts"])
            
            let fontDescriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleBody)
            let font = UIFont.init(descriptor: fontDescriptor.fontDescriptorWithSymbolicTraits(traits), size:CGFloat( fontSize))

            let fullRange = NSRange.init(location: 0, length: attString.length)
            attString.beginEditing()
            attString.setAttributes([NSFontAttributeName:font], range: fullRange)
            if isUnderline {
                attString.addAttribute(NSUnderlineStyleAttributeName, value: 1, range: fullRange)
            }
            attString.endEditing()
            
            return attString
        }
      
        return nil
    }

    
    
}