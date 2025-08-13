import SwiftUI
import FirebaseAuth

struct BottomBarView: View {
    @Binding var selectedIndex: Int
    @Binding var isLoggedIn: Bool

    var body: some View {
        HStack {
            Spacer()
            barItem(icon: "house", label: "Inicio", index: 0)
            Spacer()
            barItem(icon: "cart", label: "Pedidos", index: 1)
            Spacer()
            barItem(icon: "plus.circle", label: "Vender", index: 2)
            Spacer()
            Button(action: {
                try? Auth.auth().signOut()
                isLoggedIn = false
            }) {
                VStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Log Out").font(.caption)
                }
                .foregroundColor(.red)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .background(
            Group {
                #if os(iOS)
                Color(UIColor.systemBackground)
                #elseif os(macOS)
                Color(NSColor.windowBackgroundColor)
                #endif
            }
            .shadow(radius: 3)
        )

    }

    func barItem(icon: String, label: String, index: Int) -> some View {
        Button(action: { selectedIndex = index }) {
            VStack {
                Image(systemName: icon)
                Text(label).font(.caption)
            }
            .foregroundColor(selectedIndex == index ? .blue : .primary)
        }
    }
}
