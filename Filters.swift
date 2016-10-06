import Foundation

// Exp
// 1. use "filterSel" to sign the current filter instance based on enum
// 2. use "filterArray" to store the parameter of the current filter instance
// 3. use "filterChannel" to enable/disable the channel we need to concern
// 4. use "passing func" to avoid extra judgements within pixel loop

// implement colorFilter
public class ColorFilter {
    // ---------------------------------------------------------------------------------------
    //@Var
    // set FilterSelector
    private var filterSel: FilterSelector?
    
    // set Filter's parameters
    public var name:String?
    private var filterArray = [UInt8](repeating: 0, count:5)
    private var filterChannel = [Bool](repeating: false, count:5)
    // Red, Green, Blue, Alpha, Lum
    
    
    // ---------------------------------------------------------------------------------------
    //@Interface
    public enum FilterSelector: Int {
        case redFilter = 1, greenFilter, blueFilter, alphaFilter, luminFilter, mixedFilter
    }
    // get the length of "filterArray"
    public var getLenArray: Int {
        return filterArray.count
    }
    
    // test catalogy
    public func testing(singleFilter: FilterSelector) -> Bool {
        if singleFilter == FilterSelector.mixedFilter {
            return false
        }
        return true
    }
    // call "setting" to set filter's parameter
    public func setting(enumFilter: FilterSelector, to value: Int) {
        // reset filter to default
        resetFilter()
        
        // input check
        filterSel = enumFilter
        if filterSel == nil {
            return
        }
        
        let safeValue = UInt8(min(255, max(0, value)))
        let channel = value > -1 ? true : false
    
        switch filterSel! {
        case .redFilter:
            filterArray[0] = safeValue
            filterChannel[0] = channel
        case .greenFilter:
            filterArray[1] = safeValue
            filterChannel[1] = channel
        case .blueFilter:
            filterArray[2] = safeValue
            filterChannel[2] = channel
        case .alphaFilter:
            filterArray[3] = safeValue
            filterChannel[3] = channel
        case .luminFilter:
            filterArray[4] = safeValue
            filterChannel[4] = channel
        default:
            break
        }
    }
    // mixedFilter setting
    public func setting(enumFilter: FilterSelector, to array: [Int]) {
        // reset filter to default
        resetFilter()
        
        // input check
        filterSel = enumFilter
        if filterSel == nil {
            return
        }
        if filterSel != FilterSelector.mixedFilter {
            return
        }
    
        for index in 0..<array.count {
            let safeValue = UInt8(min(255, max(0, array[index])))
            let channel = array[index] > -1 ? true : false
            filterArray[index] = safeValue
            filterChannel[index] = channel
        }
    }

    // call "performing" to apply selected filter
    // maybe we need multiple filters in the same time
    public func performing(image: inout RGBAImage) {
        
        if filterSel == nil {
            print("FilterSel is not inited")
            return
        }
        if filterChannel[0] {
            performingImplement(image: &image, with: performingRedFilter)
        }
        if filterChannel[1] {
            performingImplement(image: &image, with: performingGreenFilter)
        }
        if filterChannel[2] {
            performingImplement(image: &image, with: performingBlueFilter)
        }
        if filterChannel[3] {
            performingImplement(image: &image, with: performingAlphaFilter)
        }
        if filterChannel[4] {
            performingImplement(image: &image, with: performingLuminFilter)
        }
        print("Perform: \(filterSel!)")
        
    }
    
    
    // ------------------------------------------------------------------------------------
    //@Interal
    // get the implement func
    private func performingImplement(image: inout RGBAImage, with performingFilter: (inout Pixel) -> Void) {
        // get every pixel's value
        let size = image.size
        var pixel = image.pixels[0]
        for pixelIndex in 0..<size {
            pixel = image.pixels[pixelIndex]
            performingFilter(&pixel)
            image.pixels[pixelIndex] = pixel
        }
    }
    // performing filter for one pixel
    private func performingRedFilter (_ pixel: inout Pixel) {
        pixel.red = filterArray[0]
    }
    private func performingGreenFilter (_ pixel: inout Pixel) {
        pixel.green = filterArray[1]
    }
    private func performingBlueFilter (_ pixel: inout Pixel) {
        pixel.blue = filterArray[2]
    }
    private func performingAlphaFilter (_ pixel: inout Pixel) {
        pixel.alpha = filterArray[3]
    }
    private func performingLuminFilter (_ pixel: inout Pixel) {
        
        // displaystyle Y=0.2126R+0.7152G+0.0722B
        let normRed = 0.2125 * Double(pixel.red)
        let normGreen = 0.7152 * Double(pixel.green)
        let normBlue = 0.0722 * Double(pixel.blue)
        let relativeLumin = normRed + normGreen + normBlue
        pixel.red = UInt8(min(255, relativeLumin))
        pixel.green = UInt8(min(255, relativeLumin))
        pixel.blue = UInt8(min(255, relativeLumin))
    }
    private func resetFilter() {
        let len = self.getLenArray
        //reset "filterSel"
        filterSel = nil
        //reset the "filterArray" and "filterChannel"
        for index in 0..<len {
            filterArray[index] = 0
            filterChannel[index] = false
        }
    }
    // -----------------------------------------------------------------------------------------
}




