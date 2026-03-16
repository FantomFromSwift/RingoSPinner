import SwiftUI

struct GlowingBackgroundViewRingoSPinner: View {
    let theme: String
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            ColorsRingoSPinner.background(for: theme)

            if theme == "default" {
                
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: adaptyW(2), height: adaptyW(2))
                        .offset(
                            x: CGFloat.random(in: -adaptyW(200)...adaptyW(200)),
                            y: CGFloat.random(in: -adaptyH(400)...adaptyH(400))
                        )
                        .blur(radius: 0.5)
                        .opacity(0.3 + 0.7 * sin(phase * 2 + Double(i)))
                }
            } else if theme == "neon" {
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: adaptyW(2), height: adaptyW(2))
                        .offset(
                            x: CGFloat.random(in: -adaptyW(200)...adaptyW(200)),
                            y: CGFloat.random(in: -adaptyH(400)...adaptyH(400))
                        )
                        .blur(radius: 0.5)
                        .opacity(0.3 + 0.7 * sin(phase * 2 + Double(i)))
                }
            } else {
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: adaptyW(2), height: adaptyW(2))
                        .offset(
                            x: CGFloat.random(in: -adaptyW(200)...adaptyW(200)),
                            y: CGFloat.random(in: -adaptyH(400)...adaptyH(400))
                        )
                        .blur(radius: 0.5)
                        .opacity(0.3 + 0.7 * sin(phase * 2 + Double(i)))
                }
            }

            
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ColorsRingoSPinner.accent(for: theme).opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: adaptyW(200)
                        )
                    )
                    .frame(width: adaptyW(300), height: adaptyW(300))
                    .offset(
                        x: sin(phase + Double(i) * 2.1) * (theme == "neon" ? adaptyW(120) : adaptyW(80)),
                        y: cos(phase + Double(i) * 1.7) * (theme == "neon" ? adaptyH(90) : adaptyH(60))
                    )
                    .blur(radius: theme == "default" ? 80 : 60)
            }
        }
        .clipped()
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

#Preview {
    GlowingBackgroundViewRingoSPinner(theme: "neon")
}
