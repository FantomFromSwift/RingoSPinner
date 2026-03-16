import SwiftUI

struct CustomHeaderRingoSPinner: View {
    let title: String
    var showBack: Bool = false
    var showSettings: Bool = false
    var theme: String = "default"
    var backAction: () -> Void = {}
    var settingsAction: () -> Void = {}
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            HStack {
                if showBack {
                    Button(action: backAction) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: adaptyW(18), weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: adaptyW(40), height: adaptyW(40))
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
                
                if showSettings {
                    Button(action: settingsAction) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: adaptyW(18), weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: adaptyW(40), height: adaptyW(40))
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, adaptyW(16))
            .padding(.bottom, adaptyH(16))
            .frame(maxWidth: .infinity)

            Text(title)
                .font(.system(size: adaptyW(20), weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, adaptyW(20))
                .padding(.vertical, adaptyH(8))
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        )
                )
                .padding(.bottom, adaptyH(16))
        }
        .background {
            Rectangle()
                .fill(Color.clear)
                .overlay(
                    Group {
                        if theme == "neon" {
                            Image("headerNeon")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if theme == "sunrise" {
                            Image("headerSunrise")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Image("headerCosmic")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                )
                .clipped()
                .ignoresSafeArea(edges: .top)
        }

    }
}

#Preview {
    VStack {
        CustomHeaderRingoSPinner(title: "RingoSPinner", showSettings: true)
        Spacer()
    }
    .background(Color.black)
}
