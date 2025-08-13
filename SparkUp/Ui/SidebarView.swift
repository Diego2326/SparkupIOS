import SwiftUI
import FirebaseAuth

struct SidebarView: View {
    @Binding var selectedTab: Tab
    @Binding var isLoggedIn: Bool

    var body: some View {
        #if os(macOS)
        List(selection: $selectedTab) {
            ForEach(Tab.allCases) { tab in
                Label(tab.title, systemImage: tab.icon)
                    .tag(tab)
            }

            Button(role: .destructive) {
                try? Auth.auth().signOut()
                isLoggedIn = false
            } label: {
                Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .navigationTitle("SparkUp")
        .listStyle(.sidebar)

        #else
        List {
            ForEach(Tab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Label(tab.title, systemImage: tab.icon)
                        .foregroundColor(.primary)
                }
            }

            Button(role: .destructive) {
                try? Auth.auth().signOut()
                isLoggedIn = false
            } label: {
                Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .navigationTitle("SparkUp")
        #endif
    }
}
