struct RootTabView: View {
var body: some View {
TabView {
HomeView()
.tabItem { Label("Inicio", systemImage: "camera") }


LearnView()
.tabItem { Label("Aprender", systemImage: "book") }


ProfileView()
.tabItem { Label("Perfil", systemImage: "person.circle") }
}
.tint(.ka_coffee)
}
}