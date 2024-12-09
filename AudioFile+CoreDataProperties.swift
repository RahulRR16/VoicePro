//
//  AudioFile+CoreDataProperties.swift
//  
//
//  Created by Rahul on 21/10/24.
//
//

import Foundation
import CoreData


extension AudioFile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioFile> {
        return NSFetchRequest<AudioFile>(entityName: "AudioFile")
    }

    @NSManaged public var fileName: String?
    @NSManaged public var fileURL: String?

}
