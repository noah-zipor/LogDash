import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    let columns = [
        GridItem(.adaptive(minimum: 120))
    ]

    @State private var isLoaded = false

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()
                .scaleEffect(isLoaded ? 1.0 : 1.1)
                .animation(.easeOut(duration: 1.5), value: isLoaded)

            Color.black.opacity(0.4).ignoresSafeArea()
                .filmGrain()

            HStack(spacing: 40) {
                    // Left Column: Time & Apps
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(viewModel.currentTime)
                                .font(.system(size: 130, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            Text(viewModel.currentDate)
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.bottom, 40)

                        HStack(spacing: 20) {
                            SystemStatView(label: "CPU", value: viewModel.systemStats.cpuUsage, unit: "%")
                            SystemStatView(label: "MEM", value: viewModel.systemStats.memoryUsage, unit: "%")
                        }
                        .padding(.bottom, 20)

                        Text("Applications")
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))

                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(Array(viewModel.apps.enumerated()), id: \.element.id) { index, app in
                                    AppGridItem(app: app) {
                                        viewModel.launchApp(app: app)
                                    }
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.apps.count)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Right Column: Now Playing
                    VStack {
                        Spacer()
                        if let media = viewModel.nowPlaying, media.isPlaying {
                            NowPlayingView(media: media)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: media.title)
                        }
                    }
                .frame(width: 300)
            }
            .padding(60)
            .opacity(isLoaded ? 1 : 0)
            .animation(.easeOut(duration: 1.0).delay(0.2), value: isLoaded)
        }
        .onAppear {
            isLoaded = true
        }
    }
}

struct AppGridItem: View {
    let app: AppEntry
    let action: () -> Void
    @State private var isHovered = false
    @State private var iconImage: NSImage? = nil

    var body: some View {
        Button(action: action) {
            VStack {
                if let image = iconImage {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                        .shadow(color: .black.opacity(0.3), radius: isHovered ? 8 : 4, x: 0, y: isHovered ? 4 : 2)
                } else if let iconData = app.icon, let image = NSImage(data: iconData) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                } else {
                    Image(systemName: "app.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .foregroundColor(.white.opacity(0.4))
                }
                Text(app.name)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(isHovered ? 1.0 : 0.8))
                    .lineLimit(1)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isHovered ? 0.15 : 0.0))
            )
            .scaleEffect(isHovered ? 1.08 : 1.0)
            .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .onAppear {
            if app.icon == nil {
                DispatchQueue.global(qos: .userInitiated).async {
                    let img = NSWorkspace.shared.icon(forFile: app.bundleIdentifier)
                    // Standardize size to reduce memory usage
                    img.size = NSSize(width: 128, height: 128)
                    DispatchQueue.main.async {
                        self.iconImage = img
                    }
                }
            }
        }
    }
}

struct SystemStatView: View {
    let label: String
    let value: Double
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.0f", value))
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                Text(unit)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }
}

struct NowPlayingView: View {
    let media: MediaInfo

    var body: some View {
        VStack(alignment: .leading) {
            if let artData = media.albumArt, let image = NSImage(data: artData) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 8)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(Image(systemName: "music.note").font(.system(size: 40)).foregroundColor(.white.opacity(0.3)))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(media.title)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(media.artist)
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
            .padding(.top, 16)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.clear)
                .background(VisualEffectView(material: .popover, blendingMode: .withinWindow).cornerRadius(32))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }
}
