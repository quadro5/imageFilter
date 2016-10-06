import Foundation
import UIKit

// Exp
// 1. use singlton to instantiate "FilterManager"
// 2. use "FilterTemplateDict" to store the template filter's enum
// 3. use "filterQueue" to store the filters' sequence of performing
// 4. use "FilterListDict" to store the filters' parameters
// 5. use one template filter to fit all possible filters
// 6. use "lazy load" for several @var

public class FilterManager {
    // ---------------------------------------------------------------------------------------
    //@Singleton
    private static var singleton:FilterManager?
    private init() {}
    public static func getFilterManager() -> FilterManager {
        if FilterManager.singleton == nil {
            FilterManager.singleton = FilterManager();
        }
        return FilterManager.singleton!
    }
    
    // ---------------------------------------------------------------------------------------
    //@var
    // the default template "ColorFilter" and parameters
    private lazy var templateFilter = ColorFilter()
    private let defaultValue = 100
    private let defaultArray = [-1, 50, 180, -1, 1]
    
    // list for storing sequence filters
    private lazy var filterQueue = queue<String>()
    // list for storing the parameter of filters
    private lazy var FilterListDict: [String: queue<Int>] = [:]
    
    // dict for storing template filters
    private let FilterTemplateDict: [String: ColorFilter.FilterSelector] = [
        "redFilter": .redFilter,
        "greenFilter": .greenFilter,
        "blueFilter": .blueFilter,
        "alphaFilter": .alphaFilter,
        "luminFilter": .luminFilter,
        "mixedFilter": .mixedFilter,
    ]
    
    // ---------------------------------------------------------------------------------------
    //@Interface
    // add filter to sequence
    public func adding(singleFilter: String, to value: Int? = nil){
        // match the key word
        if FilterTemplateDict[singleFilter] == nil || FilterTemplateDict[singleFilter]!  == .mixedFilter {
            return
        }
        // add to "filterList"
        filterQueue.push(singleFilter)
        // update "FilterListDict"
        if FilterListDict[singleFilter]  == nil {
            FilterListDict[singleFilter] = queue<Int>()
        }
        // load "defaultValue" or "value" from input
        if let inputValue = value {
            FilterListDict[singleFilter]!.push(inputValue)
        } else {
            FilterListDict[singleFilter]!.push(defaultValue)
        }
    }
    
    // add filter to sequence
    public func adding(mixedFilter: String, to array: [Int?] = [nil, nil, nil, nil, nil]) {
        // match the key word
        if FilterTemplateDict[mixedFilter] == nil || FilterTemplateDict[mixedFilter]! != .mixedFilter {
            return
        }
        if array.count < templateFilter.getLenArray {
            return
        }
        
        // add to "filterList"
        filterQueue.push(mixedFilter)
        // update "FilterListDict"
        if FilterListDict[mixedFilter] == nil {
            FilterListDict[mixedFilter] = queue<Int>()
        }
        
        // load "defaultArray" or "Array" from input
        for index in 0..<templateFilter.getLenArray {
            if let inputValue = array[index] {
                FilterListDict[mixedFilter]!.push(inputValue)
            } else {
                FilterListDict[mixedFilter]!.push(defaultArray[index])
            }
        }
        //FilterListDict[mixedFilter]!.printAll()
    }
    
    // performing filter sequence
    public func performing(image: UIImage?) -> UIImage?{
        // input test
        if image == nil {
            return nil
        }
        //guard let imageCopy = image else {
        //    return nil
        //}
        
        // transforming test
        guard var rgbaImage = RGBAImage(image: image!) else {
             return nil
        }
        // perform filter seq
        while filterQueue.isEmpty == false {
            guard let filterName = filterQueue.pop() else {
                break
            }
            guard let enumName = FilterTemplateDict[filterName] else {
                continue
            }
            updateFilter(filter: &templateFilter, enumFilter: enumName, name: filterName)
            templateFilter.performing(image: &rgbaImage)
        }
        let newImage = rgbaImage.toUIImage()
        return newImage
    }
    
    
    // ---------------------------------------------------------------------------------------
    //@Interal
    // get value or array from queues of "FilterListDict"
    private func updateFilter(filter: inout ColorFilter, enumFilter: ColorFilter.FilterSelector, name: String) {
        
        if filter.testing(singleFilter: enumFilter) {
            guard let value = FilterListDict[name]?.pop() else {
                return
            }
            filter.setting(enumFilter: enumFilter, to: value)
        } else {
            guard var q = FilterListDict[name] else {
                return
            }
            if q.count < filter.getLenArray {
                return
            }
            var nums:[Int] = []
            for _ in 0..<filter.getLenArray {
                if let num = q.pop() {
                    nums.append(num)
                }else {
                    break
                }
            }
            filter.setting(enumFilter: enumFilter, to: nums)
        }
    }
    // -----------------------------------------------------------------------------------------
}
