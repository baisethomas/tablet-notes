import SwiftUI

struct AudioVisualizer: View {
    @State private var drawingHeight = false
    
    var animation: Animation {
        return .linear(duration: 0.5).repeatForever()
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<8) { index in
                bar(low: [0.4, 0.3, 0.5, 0.3, 0.5, 0.4, 0.3, 0.5][index])
                    .animation(
                        animation.speed([1.5, 1.2, 1.0, 1.7, 1.0, 1.3, 1.6, 1.1][index]),
                        value: drawingHeight
                    )
            }
        }
        .frame(width: 80, height: 24)
        .onAppear {
            drawingHeight.toggle()
        }
    }
    
    func bar(low: CGFloat = 0.0, high: CGFloat = 1.0) -> some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(.blue.opacity(0.8))
            .frame(width: 3)
            .frame(height: (drawingHeight ? high : low) * 24)
            .frame(height: 24, alignment: .bottom)
    }
}

#Preview {
    AudioVisualizer()
        .padding()
        .background(.gray.opacity(0.2))
} 