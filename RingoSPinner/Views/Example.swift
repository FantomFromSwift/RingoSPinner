import SwiftUI

struct Example: View {
    var body: some View {
        RoundedRectangle(cornerRadius:38)
            .fill(.clear)
            .frame(width: 190, height: 190)
            .background{
                Image(.elEight)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 243, height: 243)
                    
            }
            .clipShape(RoundedRectangle(cornerRadius: 39))
            
    }
}

#Preview {
    Example()
}
