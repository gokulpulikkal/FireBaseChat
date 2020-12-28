//
//  LocalDataBase+CoreDataProperties.swift
//  
//
//  Created by Gokul on 28/06/20.
//
//

import Foundation
import CoreData


extension LocalDataBase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalDataBase> {
        return NSFetchRequest<LocalDataBase>(entityName: "Entity")
    }

    @NSManaged public var name: String?
    @NSManaged public var userId: String?

}
