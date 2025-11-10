import SwiftUI

struct settingsView: View {
    var body: some View {
        LiquidChromeView(
            baseColor: [0.28, 0.63, 0.63],
            speed: 0.4,
            amplitude: 0.25,
            freqX: 4,
            freqY: 3
        )
        
        .ignoresSafeArea()
    }
}
