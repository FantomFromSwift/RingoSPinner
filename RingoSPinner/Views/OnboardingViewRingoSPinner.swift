import SwiftUI
internal import StoreKit

struct OnboardingViewRingoSPinner: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @Environment(\.requestReview) private var requestReview

    private let backgroundImages = ["onbO", "onbT", "onbTh", "onbF"]
    
    private let pages: [(title: String, subtitle: String, icon: String, colors: [Color])] = [
        (
            "Master Ring Precision",
            "Train your coordination with interactive ring exercises and real-time feedback",
            "elOne",
            [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.6, green: 0.4, blue: 1.0)]
        ),
        (
            "Play Mini Games",
            "Challenge yourself with ring toss, reaction tests, balance challenges and more",
            "elTwo",
            [Color(red: 1.0, green: 0.5, blue: 0.3), Color(red: 1.0, green: 0.3, blue: 0.5)]
        ),
        (
            "Track Your Progress",
            "See your improvement over time with detailed stats and training history",
            "elThree",
            [Color(red: 0.2, green: 0.9, blue: 0.7), Color(red: 0.0, green: 0.6, blue: 0.8)]
        ),
        (
            "Ready to Train?",
            "Start your ring coordination journey today and unlock your full potential",
            "elFour",
            [Color(red: 1.0, green: 0.7, blue: 0.0), Color(red: 1.0, green: 0.4, blue: 0.2)]
        )
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: adaptyH(16)) {
                    HStack(spacing: adaptyW(6)) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ?
                                    ColorsRingoSPinner.accent(for: "neon") :
                                    Color.white.opacity(0.15)
                                )
                                .frame(
                                    width: index == currentPage ? adaptyW(24) : adaptyW(8),
                                    height: adaptyH(4)
                                )
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.bottom, adaptyH(8))

                    Text(pages[currentPage].title.uppercased())
                        .font(.system(size: adaptyW(28), weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .shadow(color: ColorsRingoSPinner.accent(for: "neon").opacity(0.8), radius: 10)
                        .id(currentPage)
                        .transition(.asymmetric(insertion: .push(from: .trailing), removal: .opacity))

                    RoundedRectangle(cornerRadius: 2)
                        .fill(ColorsRingoSPinner.accent(for: "neon"))
                        .frame(width: adaptyW(45), height: adaptyH(3))

                    Text(pages[currentPage].subtitle)
                        .font(.system(size: adaptyW(16), weight: .medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .padding(.trailing, adaptyW(24))
                        .id("sub\(currentPage)")
                        .transition(.asymmetric(insertion: .push(from: .trailing), removal: .opacity))
                        .padding(.bottom, adaptyH(12))

                    Button {
                        handleContinue()
                    } label: {
                        Text(currentPage == pages.count - 1 ? "START" : "CONTINUE")
                            .font(.system(size: adaptyW(16), weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, adaptyH(18))
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: adaptyW(14)))
                            .shadow(color: ColorsRingoSPinner.accent(for: "neon").opacity(0.5), radius: 10, y: 5)
                    }
                }
                .padding(adaptyW(24))
                .padding(.bottom, adaptyH(30))
                .background {
                    UnevenRoundedRectangle(topLeadingRadius: 45, topTrailingRadius: 45)
                        .fill(Color(red: 0.05, green: 0.08, blue: 0.07).opacity(0.95))
                        .frame(height: adaptyH(380))
                        .overlay {
                            UnevenRoundedRectangle(topLeadingRadius: 45, topTrailingRadius: 45)
                                .stroke(
                                    LinearGradient(
                                        colors: [ColorsRingoSPinner.accent(for: "neon").opacity(0.6), .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                        .offset(y: 10)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .background {
            GeometryReader { geometry in
                Image(backgroundImages[currentPage])
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
        }
    }

    private func handleContinue() {
        if currentPage == 2 {
            requestReview()
        }

        if currentPage < pages.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage += 1
            }
        } else {
            onComplete()
        }
    }
}

struct OnboardingIllustrationRingoSPinner: View {
    let icon: String
    let colors: [Color]
    @State private var rotation: Double = 0
    @State private var pulse: CGFloat = 1.0

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        colors[0].opacity(0.1 + Double(i) * 0.05),
                        lineWidth: adaptyW(2)
                    )
                    .frame(
                        width: adaptyW(CGFloat(180 + i * 50)),
                        height: adaptyW(CGFloat(180 + i * 50))
                    )
                    .rotationEffect(.degrees(rotation + Double(i) * 30))
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [colors[0].opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: adaptyW(100)
                    )
                )
                .frame(width: adaptyW(200), height: adaptyW(200))
                .scaleEffect(pulse)

            Circle()
                .fill(.clear)
                .frame(width: adaptyW(64), height: adaptyW(64))
                .background {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: adaptyW(82), height: adaptyW(82))
                }
                .clipShape(Circle())
                .shadow(color: colors[0].opacity(0.5), radius: 15)
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever()) {
                pulse = 1.1
            }
        }
    }
}

#Preview {
    OnboardingViewRingoSPinner {}
}
