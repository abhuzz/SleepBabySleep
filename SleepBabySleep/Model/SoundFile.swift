//
//  SoundFile.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 17/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit

protocol SoundFile {
    var Identifier: UUID { get }
    var Name: String { get }
    var URL: Foundation.URL { get }
    var Image: UIImage { get }
    var Deletable: Bool { get }
}


struct AssetSoundFile: SoundFile, Equatable {
    
    private var fileName: String
    private var fileExtension: String
    private var image: UIImage
    
    init(Name: String, File: String, Extension:String, Image: UIImage) {
        self.Identifier = UUID()
        self.Name = Name
        self.fileName = File
        self.fileExtension = Extension
        self.image = Image
    }
    
    init(Name: String, File: String, Extension:String) {
        self.init(Name: Name, File: File, Extension: Extension, Image: UIImage())
    }
    
    private(set) var Identifier: UUID
    private(set) var Name: String
    
    var URL: Foundation.URL {
        get {
            return Bundle.main
                    .url(forResource: fileName, withExtension: fileExtension)!
        }
    }
    
    var Image: UIImage {
        get { return image }
    }
    
    var Deletable: Bool {
        get { return false }
    }
}

func ==(lhs: AssetSoundFile, rhs: AssetSoundFile) -> Bool {
    return lhs.Name == rhs.Name
        && lhs.URL  == rhs.URL
}


struct RecordedAudioFile: SoundFile, Equatable{
    
    init(identifier: UUID, name: String, url: URL, image: UIImage) {
        self.Identifier = identifier
        self.URL = url
        self.Name = name
        self.image = image
    }
    
    init(identifier: UUID, name: String, url: URL) {
        self.init(identifier: identifier, name: name, url: url, image: UIImage())
    }

    private(set) var Identifier: UUID
    private(set) var Name: String
    private(set) var URL: Foundation.URL
    private var image: UIImage
    
    var Image: UIImage {
        get { return image }
    }
    
    var Deletable: Bool {
        get { return true }
    }
}

func ==(lhs: RecordedAudioFile, rhs: RecordedAudioFile) -> Bool {
    return lhs.Name == rhs.Name
        && lhs.URL  == rhs.URL
}
