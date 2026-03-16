import SwiftUI
import SwiftData

struct TrajectorySimulatorViewRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var angle: Double = 45
    @State private var power: Double = 50
    @State private var distance: Double = 3
    @State private var showTrajectory = false
    @State private var hitChance: Double = 0
    @State private var trajectoryPoints: [CGPoint] = []
    @State private var isSaved = false

    var body: some View {
        ZStack {
            GlowingBackgroundViewRingoSPinner(theme: viewModel.selectedTheme)

            VStack(spacing: 0) {
                CustomHeaderRingoSPinner(
                    title: "Trajectory Simulator",
                    showBack: true,
                    theme: viewModel.selectedTheme,
                    backAction: { dismiss() }
                )

                ScrollView {
                    VStack(spacing: adaptyH(16)) {
                        SimulatorVisualizationRingoSPinner(
                            points: trajectoryPoints,
                            showTrajectory: showTrajectory,
                            hitChance: hitChance
                        )

                        SimulatorControlRingoSPinner(
                            label: "Angle",
                            value: $angle,
                            range: 10...80,
                            unit: "°",
                            icon: "angle"
                        )

                        SimulatorControlRingoSPinner(
                            label: "Power",
                            value: $power,
                            range: 10...100,
                            unit: "%",
                            icon: "bolt.fill"
                        )

                        SimulatorControlRingoSPinner(
                            label: "Distance",
                            value: $distance,
                            range: 1...8,
                            unit: "m",
                            icon: "ruler"
                        )

                        if showTrajectory {
                            CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
                                VStack(spacing: adaptyH(8)) {
                                    HStack {
                                        Text("Hit Probability")
                                            .font(.system(size: adaptyW(15), weight: .bold, design: .rounded))
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Text("\(Int(hitChance))%")
                                            .font(.system(size: adaptyW(22), weight: .black, design: .rounded))
                                            .foregroundStyle(hitChanceColor)
                                    }

                                    RoundedRectangle(cornerRadius: adaptyW(4))
                                        .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
                                        .frame(height: adaptyH(8))
                                        .overlay(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: adaptyW(4))
                                                .fill(hitChanceColor)
                                                .frame(width: adaptyW(CGFloat(hitChance / 100.0) * 300))
                                        }
                                }
                            }
                        }

                        HStack(spacing: adaptyW(12)) {
                            CustomButtonRingoSPinner(
                                title: "Simulate",
                                theme: viewModel.selectedTheme,
                                icon: "play.fill"
                            ) {
                                runSimulation()
                            }

                            CustomButtonRingoSPinner(
                                title: isSaved ? "Saved!" : "Save",
                                theme: viewModel.selectedTheme,
                                icon: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down",
                                isSecondary: true
                            ) {
                                saveSession()
                            }
                            .disabled(isSaved)
                        }
                    }
                    .padding(.horizontal, adaptyW(16))
                    .padding(.top, adaptyH(8))
                }
                .scrollIndicators(.hidden)
                .contentMargins(.bottom, adaptyH(100))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBackWithSwipe()
    }

    private var hitChanceColor: Color {
        if hitChance >= 70 { return .green }
        if hitChance >= 40 { return .orange }
        return .red
    }

    private func runSimulation() {
        let radians = angle * .pi / 180.0
        let v = power / 100.0 * 15.0
        let g = 9.81

        var points: [CGPoint] = []
        let steps = 40
        let totalTime = (2.0 * v * sin(radians)) / g

        for i in 0...steps {
            let t = totalTime * Double(i) / Double(steps)
            let x = v * cos(radians) * t
            let y = v * sin(radians) * t - 0.5 * g * t * t

            let screenX = adaptyW(40) + CGFloat(x / distance * 8.0) * adaptyW(30)
            let screenY = adaptyH(200) - CGFloat(y) * adaptyH(25)
            points.append(CGPoint(x: screenX, y: max(screenY, adaptyH(40))))
        }

        trajectoryPoints = points

        let optimalAngle = 42.0
        let optimalPower = 60.0 + distance * 5.0
        let angleDiff = abs(angle - optimalAngle)
        let powerDiff = abs(power - optimalPower)

        hitChance = max(0, min(100, 100 - angleDiff * 1.5 - powerDiff * 0.8 + Double.random(in: -5...5)))

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showTrajectory = true
        }
    }

    private func saveSession() {
        let session = SimulatorSessionRingoSPinner(
            angle: angle,
            power: power,
            distance: distance,
            successRate: hitChance,
            date: .now
        )
        modelContext.insert(session)
        try? modelContext.save()
        viewModel.addScore(Int(hitChance / 10))
        
        withAnimation {
            isSaved = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isSaved = false
            }
        }
    }
}

struct SimulatorVisualizationRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let points: [CGPoint]
    let showTrajectory: Bool
    let hitChance: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: adaptyW(16))
                .fill(ColorsRingoSPinner.cardBackground(for: viewModel.selectedTheme))
                .frame(height: adaptyH(220))

            if showTrajectory, points.count > 1 {
                Path { path in
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            ColorsRingoSPinner.accent(for: viewModel.selectedTheme),
                            ColorsRingoSPinner.secondary(for: viewModel.selectedTheme)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.4), radius: 6)

                if let last = points.last {
                    Circle()
                        .fill(hitChance > 50 ? Color.green : Color.red)
                        .frame(width: adaptyW(12), height: adaptyW(12))
                        .position(last)
                        .shadow(color: hitChance > 50 ? .green.opacity(0.5) : .red.opacity(0.5), radius: 6)
                }
            } else {
                VStack(spacing: adaptyH(8)) {
                    Image(systemName: "scope")
                        .font(.system(size: adaptyW(36)))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme).opacity(0.3))
                    Text("Adjust parameters and tap Simulate")
                        .font(.system(size: adaptyW(13)))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
    }
}

struct SimulatorControlRingoSPinner: View {
    @Environment(ViewModelRingoSPinner.self) private var viewModel
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    let icon: String

    var body: some View {
        CustomCardRingoSPinner(theme: viewModel.selectedTheme) {
            VStack(spacing: adaptyH(8)) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                    Text(label)
                        .font(.system(size: adaptyW(14), weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(label == "Distance" ? String(format: "%.1f", value) : "\(Int(value))")\(unit)")
                        .font(.system(size: adaptyW(16), weight: .bold, design: .rounded))
                        .foregroundStyle(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
                }

                Slider(value: $value, in: range, step: label == "Distance" ? 0.5 : 1)
                    .tint(ColorsRingoSPinner.accent(for: viewModel.selectedTheme))
            }
        }
    }
}

#Preview {
    NavigationStack {
        TrajectorySimulatorViewRingoSPinner()
    }
    .environment(ViewModelRingoSPinner())
    .modelContainer(for: [MiniGameScoreRingoSPinner.self, SimulatorSessionRingoSPinner.self, FavoritesRingoSPinner.self])
}
