import SwiftUI

struct SplashViewRingoSPinner: View {
    let onFinish: () -> Void
    @State private var ringRotation: Double = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: "default")

            VStack(spacing: adaptyH(24)) {
                ZStack {
                    Circle()
                        .stroke(
                            AngularGradient(
                                colors: [
                                    ColorsRingoSPinner.accent(for: "default"),
                                    ColorsRingoSPinner.secondary(for: "default"),
                                    ColorsRingoSPinner.accent(for: "default")
                                ],
                                center: .center
                            ),
                            lineWidth: adaptyW(6)
                        )
                        .frame(width: adaptyW(120), height: adaptyW(120))
                        .rotationEffect(.degrees(ringRotation))
                        .scaleEffect(ringScale)
                        .shadow(
                            color: ColorsRingoSPinner.accent(for: "default").opacity(glowOpacity),
                            radius: 20
                        )

                    Circle()
                        .stroke(
                            ColorsRingoSPinner.secondary(for: "default").opacity(0.3),
                            lineWidth: adaptyW(3)
                        )
                        .frame(width: adaptyW(80), height: adaptyW(80))
                        .rotationEffect(.degrees(-ringRotation * 0.7))
                        .scaleEffect(ringScale)
                }

                VStack(spacing: adaptyH(8)) {
                    Text("RingoSPinner")
                        .font(.system(size: adaptyW(32), weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    ColorsRingoSPinner.accent(for: "default"),
                                    ColorsRingoSPinner.secondary(for: "default")
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Ring Coordination Training")
                        .font(.system(size: adaptyW(14), weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                ringScale = 1.0
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                ringRotation = 360
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                logoOpacity = 1.0
                glowOpacity = 0.6
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onFinish()
            }
        }
    }
}

#Preview {
    SplashViewRingoSPinner {}
}
