import SwiftUI

struct ProgressRingViewRingoSPinner: View {
    let progress: Double
    let theme: String
    var lineWidth: CGFloat = 8
    var size: CGFloat = 100

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    ColorsRingoSPinner.accent(for: theme).opacity(0.15),
                    lineWidth: adaptyW(lineWidth)
                )

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [
                            ColorsRingoSPinner.accent(for: theme),
                            ColorsRingoSPinner.secondary(for: theme),
                            ColorsRingoSPinner.accent(for: theme)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(
                        lineWidth: adaptyW(lineWidth),
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .shadow(
                    color: ColorsRingoSPinner.accent(for: theme).opacity(0.5),
                    radius: 6
                )

            VStack(spacing: adaptyH(2)) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: adaptyW(size * 0.22), weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
        }
        .frame(width: adaptyW(size), height: adaptyW(size))
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedProgress = min(progress, 1.0)
            }
        }
        .onChange(of: progress) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = min(progress, 1.0)
            }
        }
    }
}

#Preview {
    ProgressRingViewRingoSPinner(progress: 0.72, theme: "default")
        .background(Color.black)
}
