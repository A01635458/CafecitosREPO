struct ProgressBar: View {
var progress: Double // 0...1
var body: some View {
GeometryReader { geo in
ZStack(alignment: .leading) {
Capsule().fill(Color.ka_divider)
Capsule()
.fill(Color.ka_coffee)
.frame(width: max(0, min(progress, 1)) * geo.size.width)
}
}
.frame(height: 12)
}
}