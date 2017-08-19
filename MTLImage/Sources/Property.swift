//
//  Property.swift
//  Pods
//
//  Created by Mohssen Fathi on 4/1/16.
//
//

import UIKit

public protocol PropertyBase {
    
//    associatedtype ClassType
//    associatedtype ValueType
    
    var title: String { get set }
//    var keyPath: ReferenceWritableKeyPath<ClassType, ValueType> { get set }
    var range: (Float, Float, Float) { get set }
    
    var valueType: Any.Type { get }
    var rootType: Any.Type { get }
}

public
struct Property<C, V>: PropertyBase {
    
    public var title: String
    public var keyPath: ReferenceWritableKeyPath<C, V>
    public var range: (Float, Float, Float) = (0.0, 0.5, 1.0)
 
    public var valueType: Any.Type {
        return type(of: keyPath).valueType
    }
    
    public var rootType: Any.Type {
        return type(of: keyPath).rootType
    }
    
    public init(title: String, keyPath: ReferenceWritableKeyPath<C, V>) {
        self.title = title
        self.keyPath = keyPath
    }
}

public
extension Filter {
    
    // Make an optional?
    public subscript<C, V>(property: Property<C, V>) -> V {
        get {
            return (self as! C)[keyPath: property.keyPath]
        }
        set {
            (self as! C)[keyPath: property.keyPath] = newValue
        }
    }
    
}


public
class Property1: NSObject, NSCoding {

    public
    enum PropertyType: Int {
        case value = 0,
        bool,
        point,
        rect,
        color,
        selection,
        image
    }
    
    public var title: String!
    public var key: String!
    public var keyPath: AnyKeyPath!
    public var propertyType: PropertyType!
    public var minimumValue: Float = 0.0
    public var defaultValue: Float = 0.5
    public var maximumValue: Float = 1.0
    public var selectionItems: [Int : String]?
    
    init(key: String, title: String) {
        super.init()
        self.key = key
        self.title = title
        self.propertyType = .value
    }
    
    init(keyPath: AnyKeyPath, title: String) {
        super.init()
        self.keyPath = keyPath
        self.title = title
        self.propertyType = .value
    }
    
    init(key: String, title: String, propertyType: PropertyType) {
        super.init()
        self.key = key
        self.title = title
        self.propertyType = propertyType
    }
    
    
    
    //    MARK: - NSCoding
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title , forKey: "title")
        aCoder.encode(key, forKey: "key")
        aCoder.encode(minimumValue, forKey: "minimumValue")
        aCoder.encode(maximumValue, forKey: "maximumValue")
        aCoder.encode(defaultValue, forKey: "defaultValue")
        aCoder.encode(selectionItems, forKey: "selectionItems")
        aCoder.encode(propertyType.rawValue, forKey: "propertType")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        key = aDecoder.decodeObject(forKey: "key") as! String
        title = aDecoder.decodeObject(forKey: "title") as! String
        minimumValue = aDecoder.decodeFloat(forKey: "minimumValue")
        maximumValue = aDecoder.decodeFloat(forKey: "maximumValue")
        defaultValue = aDecoder.decodeFloat(forKey: "defaultValue")
        selectionItems = aDecoder.decodeObject(forKey: "selectionItems") as? [Int: String]
        propertyType = PropertyType(rawValue: aDecoder.decodeInteger(forKey: "propertyType"))
    }
    
}
