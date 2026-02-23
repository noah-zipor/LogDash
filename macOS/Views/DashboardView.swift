import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var isLoaded = false

    let columns = [GridItem(.adaptive(minimum: 110))]

    var body: some View {
        ZStack {
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .ignoresSafeArea()
                .scaleEffect(isLoaded ? 1.0 : 1.08)
                .animation(.easeOut(duration: 1.2), value: isLoaded)

            Color.black.opacity(0.4).ignoresSafeArea()
                .filmGrain()

            HStack(spacing: 40) {

                // ── Left Column ──────────────────────────────────────────
                VStack(alignment: .leading, spacing: 0) {

                    // Clock
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.currentTime)
                            .font(.system(size: 120, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
                        Text(viewModel.currentDate)
                            .font(.system(.title2, design: .rounded).weight(.medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 28)

                    // System Stats Row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            SystemStatView(label: "CPU",  value: viewModel.systemStats.cpuUsage,    unit: "%",  color: .blue)
                            SystemStatView(label: "MEM",  value: viewModel.systemStats.memoryUsage, unit: "%",  color: .purple)
                            SystemStatView(label: "DISK", value: viewModel.systemStats.diskUsage,   unit: "%",  color: .orange)
                            if viewModel.systemStats.batteryLevel >= 0 {
                                BatteryStatView(level: viewModel.systemStats.batteryLevel, isCharging: viewModel.systemStats.isCharging)
                            }
                        }
                    }
                    .padding(.bottom, 24)

                    // Quick Actions
                    QuickActionsRow()
                        .padding(.bottom, 24)

                    // Apps header + search
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Applications")
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundColor(.white.opacity(0.9))

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.5))
                            TextField("Search apps…", text: $viewModel.searchQuery)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 0.5))
                        )
                    }

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(viewModel.filteredApps.enumerated()), id: \.element.id) { index, app in
                                AppGridItem(app: app) {
                                    viewModel.launchApp(app: app)
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .opacity
                                ))
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.04), value: viewModel.filteredApps.count)
                            }
                        }
                        .padding(.top, 12)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // ── Right Column ─────────────────────────────────────────
                VStack(spacing: 20) {
                    Spacer()
                    if let media = viewModel.nowPlaying, media.isPlaying {
                        NowPlayingView(media: media)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                            .animation(.spring(response: 0.7, dampingFraction: 0.8), value: media.title)
                    } else {
                        NowPlayingIdleView()
                            .transition(.opacity)
                    }
                }
                .frame(width: 300)
            }
            .padding(60)
            .opacity(isLoaded ? 1 : 0)
            .animation(.easeOut(duration: 0.9).delay(0.15), value: isLoaded)
        }
        .onAppear { isLoaded = true }
    }
}

// MARK: - Quick Actions

struct QuickActionsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            QuickActionButton(icon: "terminal", label: "Terminal") {
                NSWorkspace.shared.launchApplication("Terminal")
            }
            QuickActionButton(icon: "safari", label: "Safari") {
                NSWorkspace.shared.launchApplication("Safari")
            }
            QuickActionButton(icon: "folder", label: "Finder") {
                NSWorkspace.shared.launchApplication("Finder")
            }
            QuickActionButton(icon: "gear", label: "System") {
                NSWorkspace.shared.launchApplication("System Preferences")
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(isHovered ? 1 : 0.7))
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(isHovered ? 1 : 0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(isHovered ? 0.2 : 0.08))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.12), lineWidth: 0.5))
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.05 : 1)
        .animation(.interpolatingSpring(stiffness: 320, damping: 22), value: isHovered)
        .onHover { isHovered = $0 }
    }
}

// MARK: - App Grid Item

struct AppGridItem: View {
    let app: AppEntry
    let action: () -> Void
    @State private var isHovered = false
    @State private var iconImage: NSImage? = nil

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Group {
                    if let image = iconImage {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if let iconData = app.icon, let image = NSImage(data: iconData) {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Image(systemName: "app.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .frame(width: 56, height: 56)
                .shadow(color: .black.opacity(0.4), radius: isHovered ? 10 : 4, x: 0, y: isHovered ? 6 : 2)

                Text(app.name)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(isHovered ? 1.0 : 0.75))
                    .lineLimit(1)
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isHovered ? 0.18 : 0.0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(isHovered ? 0.2 : 0), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isHovered ? 1.1 : 1.0)
        .animation(.interpolatingSpring(stiffness: 300, damping: 20), value: isHovered)
        .onHover { isHovered = $0 }
        .onAppear {
            guard app.icon == nil, iconImage == nil else { return }
            DispatchQueue.global(qos: .userInitiated).async {
                let img = NSWorkspace.shared.icon(forFile: app.bundleIdentifier)
                img.size = NSSize(width: 128, height: 128)
                DispatchQueue.main.async { self.iconImage = img }
            }
        }
    }
}

// MARK: - System Stat Views

struct SystemStatView: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color

    var barColor: Color {
        value > 80 ? .red : (value > 60 ? .yellow : color)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundColor(.white.opacity(0.6))
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value >= 0 ? String(format: "%.0f", value) : "—")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                Text(value >= 0 ? unit : "")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }
            // Mini bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor.opacity(0.8))
                        .frame(width: max(0, geo.size.width * CGFloat(min(max(value, 0), 100)) / 100))
                        .animation(.easeOut(duration: 0.4), value: value)
                }
            }
            .frame(height: 3)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        .frame(minWidth: 72)
    }
}

struct BatteryStatView: View {
    let level: Double
    let isCharging: Bool

    var batteryColor: Color {
        if isCharging { return .green }
        if level < 20  { return .red }
        if level < 40  { return .yellow }
        return .green
    }

    var icon: String {
        if isCharging { return "battery.100.bolt" }
        if level > 75 { return "battery.100" }
        if level > 50 { return "battery.75" }
        if level > 25 { return "battery.50" }
        return "battery.25"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("BATT")
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundColor(.white.opacity(0.6))
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.0f", level))
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                Text("%")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
            }
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(batteryColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        .frame(minWidth: 72)
    }
}

// MARK: - Now Playing

struct NowPlayingView: View {
    let media: MediaInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let artData = media.albumArt, let image = NSImage(data: artData) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 252, height: 252)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(LinearGradient(colors: [.purple.opacity(0.4), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 252, height: 252)
                    Image(systemName: "music.note")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(media.title)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(media.artist)
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                        .shadow(color: .green, radius: 4)
                    Text("Now Playing")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 4)
            }
            .padding(.top, 18)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.black.opacity(0.3))
                .background(VisualEffectView(material: .popover, blendingMode: .withinWindow).cornerRadius(32))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(
                    LinearGradient(colors: [.white.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
    }
}

struct NowPlayingIdleView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "music.note.list")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.2))
            Text("Nothing Playing")
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white.opacity(0.03))
                .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.white.opacity(0.07), lineWidth: 0.5))
        )
    }
}
