import SwiftUI

class ColorSchemeManager: ObservableObject {

    @AppStorage("appColorScheme") private var storedScheme: String = "light"

    var scheme: ColorScheme {
        get {
            storedScheme == "dark" ? .dark : .light
        }
        set {
            storedScheme = (newValue == .dark ? "dark" : "light")
            objectWillChange.send()   // 뷰 리프레시
        }
    }
}
