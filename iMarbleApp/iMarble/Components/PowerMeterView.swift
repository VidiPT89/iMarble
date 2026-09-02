import SwiftUI

struct PowerMeterView: View {
    let ratio: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.3))
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppTheme.accentGradient)
                        .frame(width: geo.size.width * ratio)
                        .animation(.easeOut(duration: 0.08), value: ratio)
                }
            }
            .frame(height: 10)
        }
    }
}

#Preview {
    PowerMeterView(ratio: 0.6)
        .frame(width: 150)
        .padding()
        .background(Color.black)
}
