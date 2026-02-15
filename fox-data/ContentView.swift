//
//  ContentView.swift
//  fox-data
//
//  Created by blackrossay on 17/08/2025.
//

import SwiftUI
import Charts

// --- Theme Colors ---
extension Color {
    static let brandPrimary = Color(red: 0.224, green: 1.0, blue: 0.078) // #39FF14 (Neon Green)
    static let brandBackground = Color(red: 0.02, green: 0.02, blue: 0.02)
    static let brandSurface = Color(red: 0.08, green: 0.08, blue: 0.08)
    static let brandSurfaceHighlight = Color(red: 0.12, green: 0.12, blue: 0.12)
}

// --- Custom View Modifiers ---
struct TechHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.subheadline, design: .monospaced))
            .fontWeight(.bold)
            .textCase(.uppercase)
            .tracking(1.5)
            .foregroundStyle(Color.gray)
    }
}
struct NeonGlowStyle: ViewModifier {
    var color: Color; var radius: CGFloat = 8
    func body(content: Content) -> some View {
        content.shadow(color: color.opacity(0.6), radius: radius).shadow(color: color.opacity(0.3), radius: radius * 2)
    }
}
extension View {
    func techHeader() -> some View { modifier(TechHeaderStyle()) }
    func neonGlow(color: Color = .brandPrimary, radius: CGFloat = 8) -> some View { modifier(NeonGlowStyle(color: color, radius: radius)) }
}

// Optimized GlassCard with conditional blur for performance (QA Glitch)
struct GlassCard<Content: View>: View {
    var content: Content
    @Environment(\.colorScheme) var colorScheme
    
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    
    var body: some View {
        content
            .padding(20)
            .background(.ultraThinMaterial) // Kept for premium feel
            .background(Color.brandSurface.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.15), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

// --- Data Models ---
struct Tank: Identifiable, Hashable {
    let id = UUID(); var name: String; var species: String; var temperature: Double; var pH: Double; var dissolvedOxygen: Double; var ammonia: Double; var salinity: Double; var lastUpdate: Date; var connectionStatus: ConnectionStatus; var aiStatus: AIAnalysisStatus
    var tempHistory: [Double] = (0..<24).map { _ in Double.random(in: 27...29) }
    var phHistory: [Double] = (0..<24).map { _ in Double.random(in: 6.8...7.4) }
    var doHistory: [Double] = (0..<24).map { _ in Double.random(in: 5.5...7.0) }
    
    // Inventory
    var sensorCount: Int = 3; var pumpCount: Int = 1; var feederStatus: String = "Auto"
}
enum ConnectionStatus: String, Codable { case online, offline, syncing }
enum AIAnalysisStatus: Hashable {
    case optimal, warning(reason: String), critical(reason: String), analyzing
    var color: Color { switch self { case .optimal: return .brandPrimary; case .warning: return .orange; case .critical: return .red; case .analyzing: return .cyan } }
}
struct ChatMessage: Identifiable, Equatable { let id = UUID(); let text: String; let isUser: Bool; let timestamp: Date; let isSystemEvent: Bool; let reasoning: String? }

class DataManager: ObservableObject {
    @Published var tanks: [Tank] = []
    @Published var farmHealthScore: Int = 92
    @Published var chatHistory: [ChatMessage] = [ChatMessage(text: "Edge AI Module (SiMa.ai) connected.", isUser: false, timestamp: Date(), isSystemEvent: true, reasoning: nil)]
    @Published var isAIThinking = false
    @Published var isDemoMode = false // Marketing: Demo Mode
    
    // New Metrics
    @Published var solarPower: Double = 12.5
    @Published var solarHistory: [Double] = (0..<24).map { i in max(0, 15 * sin((Double(i) - 6) * Double.pi / 12)) }
    @Published var batteryLevel: Double = 85.0
    @Published var boreholeFlow: Double = 450.0
    @Published var boreholeHistory: [Double] = (0..<24).map { _ in Double.random(in: 400...480) }
    
    // Financials
    @Published var monthlyRevenue: Double = 15400
    @Published var monthlyCost: Double = 4200
    
    // Automation
    @Published var autoManageAll: Bool = true
    
    init() {
        resetData()
    }
    
    func resetData() {
        tanks = [
            Tank(name: "Pond 01", species: "Tilapia", temperature: 28.5, pH: 7.2, dissolvedOxygen: 6.5, ammonia: 0.02, salinity: 0.5, lastUpdate: Date(), connectionStatus: .online, aiStatus: .optimal),
            Tank(name: "Pond 02", species: "Tilapia", temperature: 29.8, pH: 6.8, dissolvedOxygen: 4.2, ammonia: 0.5, salinity: 0.5, lastUpdate: Date(), connectionStatus: .online, aiStatus: .warning(reason: "Low Oxygen")),
            Tank(name: "Raceway B", species: "Vannamei", temperature: 26.0, pH: 8.1, dissolvedOxygen: 7.0, ammonia: 0.0, salinity: 15.0, lastUpdate: Date(), connectionStatus: .online, aiStatus: .optimal),
            Tank(name: "Nursery", species: "Catfish", temperature: 31.5, pH: 6.5, dissolvedOxygen: 5.8, ammonia: 1.2, salinity: 0.2, lastUpdate: Date(), connectionStatus: .offline, aiStatus: .critical(reason: "Offline"))
        ]
    }
    
    func toggleDemoMode() {
        isDemoMode.toggle()
        if isDemoMode {
            // Marketing: Perfect Scenario
            farmHealthScore = 99
            monthlyRevenue = 25000
            monthlyCost = 3000
            solarPower = 18.2
            tanks = tanks.map { var t = $0; t.aiStatus = .optimal; t.connectionStatus = .online; return t }
        } else {
            resetData()
            farmHealthScore = 92
            monthlyRevenue = 15400
        }
    }
    
    func sendMessage(_ text: String) {
        let userMsg = ChatMessage(text: text, isUser: true, timestamp: Date(), isSystemEvent: false, reasoning: nil)
        chatHistory.append(userMsg)
        isAIThinking = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isAIThinking = false
            let reasoning = "Analyzing semantic intent: '\(text)'. Checking vector DB for similar incidents. Correlating with real-time sensor stream from Pond 02 (Low O2 event)."
            let response = "Based on the telemetry, Pond 02 oxygen levels dropped to 4.2 mg/L at 03:00 AM. This correlates with the borehole pump cycling off. I recommend inspecting the backup solar battery circuit."
            self.chatHistory.append(ChatMessage(text: response, isUser: false, timestamp: Date(), isSystemEvent: false, reasoning: reasoning))
        }
    }
    
    // Helper to get average metrics for analysis
    var avgTemp: Double { tanks.map { $0.temperature }.reduce(0, +) / Double(tanks.count) }
    var avgPH: Double { tanks.map { $0.pH }.reduce(0, +) / Double(tanks.count) }
}

// --- Views ---

struct ContentView: View {
    @StateObject private var dataManager = DataManager()
    @State private var isHighContrast = false // QA: High Contrast Mode
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color.brandBackground.opacity(0.95))
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            NavigationStack { DashboardView(dataManager: dataManager, isHighContrast: $isHighContrast) }
                .tabItem { Label("Monitor", systemImage: "chart.bar.xaxis") }
            
            NavigationStack { AIInsightView(dataManager: dataManager) }
                .tabItem { Label("AI Core", systemImage: "cpu") }
            
            NavigationStack { FinancialView(dataManager: dataManager) }
                .tabItem { Label("Exec", systemImage: "briefcase.fill") }
            
            NavigationStack { ChatView(dataManager: dataManager) }
                .tabItem { Label("Comms", systemImage: "message.fill") }
            
            NavigationStack { TankListView(tanks: dataManager.tanks) }
                .tabItem { Label("Units", systemImage: "square.grid.2x2.fill") }
        }
        .tint(isHighContrast ? .white : .brandPrimary)
        .preferredColorScheme(.dark)
        .environment(\.colorScheme, .dark) // Force dark mode base
    }
}

// --- DASHBOARD ---
struct DashboardView: View {
    @ObservedObject var dataManager: DataManager
    @Binding var isHighContrast: Bool
    
    var body: some View {
        ZStack {
            (isHighContrast ? Color.black : Color.brandBackground).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        TiboLogo(isHighContrast: isHighContrast)
                        Spacer()
                        
                        // Marketing: Demo Mode Toggle
                        Button(action: { withAnimation { dataManager.toggleDemoMode() } }) {
                            Text(dataManager.isDemoMode ? "DEMO ACTIVE" : "DEMO")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(dataManager.isDemoMode ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        
                        // QA: High Contrast Toggle
                        Button(action: { withAnimation { isHighContrast.toggle() } }) {
                            Image(systemName: isHighContrast ? "sun.max.fill" : "moon.fill")
                                .foregroundStyle(isHighContrast ? .white : .yellow)
                        }
                    }.padding(.horizontal).padding(.top)
                    
                    // Main Health
                    GlassCard {
                        VStack(spacing: 16) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("SYSTEM HEALTH").techHeader()
                                    Text("\(dataManager.farmHealthScore)%")
                                        .font(.system(size: 56, design: .rounded))
                                        .fontWeight(.heavy)
                                        .foregroundStyle(isHighContrast ? .white : Color.brandPrimary)
                                        .shadow(color: isHighContrast ? .clear : Color.brandPrimary.opacity(0.6), radius: 8)
                                }
                                Spacer()
                                ZStack {
                                    Circle().stroke(Color.white.opacity(0.1), lineWidth: 10).frame(width: 80, height: 80)
                                    Circle().trim(from: 0, to: CGFloat(dataManager.farmHealthScore)/100)
                                        .stroke(isHighContrast ? .white : Color.brandPrimary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                        .frame(width: 80, height: 80)
                                        .shadow(color: isHighContrast ? .clear : Color.brandPrimary.opacity(0.6), radius: 8)
                                }
                            }
                            
                            // Social: Share Button (Kai)
                            Button(action: { shareStatus() }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share Status")
                                }
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isHighContrast ? .white : Color.brandPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }.padding(.horizontal)

                    
                    // Telemetry Grid
                    VStack(alignment: .leading) {
                        Text("TELEMETRY").techHeader().padding(.horizontal)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            
                            // 1. Temp Analysis Link
                            NavigationLink(destination: MetricDetailView(
                                title: "Temperature Analysis",
                                value: String(format: "%.1f°C", dataManager.avgTemp),
                                status: "OPTIMAL",
                                statusColor: .brandPrimary,
                                description: "Average water temperature is within the optimal growth range (26°C - 30°C) for Tilapia and Catfish. Metabolic rates are at peak efficiency.",
                                recommendation: "Maintain current heating/shading protocols.",
                                dataPoints: dataManager.tanks.first?.tempHistory ?? [], // Using first tank mock history for aggregate
                                color: .orange
                            )) {
                                MetricCard(title: "AVG TEMP", value: String(format: "%.1f", dataManager.avgTemp), unit: "°C", icon: "thermometer.medium", color: .orange, trend: dataManager.tanks.first?.tempHistory ?? [])
                            }
                            
                            // 2. pH Analysis Link
                            NavigationLink(destination: MetricDetailView(
                                title: "pH Analysis",
                                value: String(format: "%.1f", dataManager.avgPH),
                                status: "STABLE",
                                statusColor: .brandPrimary,
                                description: "pH levels are neutral (6.5 - 7.5). Ammonia toxicity risk is low. Buffering capacity (Alkalinity) is sufficient.",
                                recommendation: "No dosing required. Continue routine monitoring.",
                                dataPoints: dataManager.tanks.first?.phHistory ?? [],
                                color: .purple
                            )) {
                                MetricCard(title: "AVG pH", value: String(format: "%.1f", dataManager.avgPH), unit: "", icon: "flask.fill", color: .purple, trend: dataManager.tanks.first?.phHistory ?? [])
                            }
                            
                            // 3. Solar Analysis Link
                            NavigationLink(destination: MetricDetailView(
                                title: "Solar Output Analysis",
                                value: String(format: "%.1f kW", dataManager.solarPower),
                                status: "PEAK GEN",
                                statusColor: .yellow,
                                description: "Solar array is operating at 92% efficiency. Current output exceeds farm load (8.4 kW). Excess power is charging battery banks.",
                                recommendation: "Consider running heavy pumps now to utilize excess yield.",
                                dataPoints: dataManager.solarHistory,
                                color: .yellow
                            )) {
                                MetricCard(title: "SOLAR", value: "\(Int(dataManager.solarPower))", unit: "kW", icon: "bolt.fill", color: .yellow, trend: dataManager.solarHistory)
                            }
                            
                            // 4. Pumps Analysis Link
                            NavigationLink(destination: MetricDetailView(
                                title: "Borehole Pump Efficiency",
                                value: String(format: "%.0f L/m", dataManager.boreholeFlow),
                                status: "NOMINAL",
                                statusColor: .cyan,
                                description: "Main borehole pump is delivering steady flow. Pressure head is consistent. No cavitation detected.",
                                recommendation: "Routine maintenance due in 14 days.",
                                dataPoints: dataManager.boreholeHistory,
                                color: .cyan
                            )) {
                                MetricCard(title: "PUMPS", value: "\(Int(dataManager.boreholeFlow))", unit: "L/m", icon: "drop.circle.fill", color: .cyan, trend: dataManager.boreholeHistory)
                            }
                            
                        }.padding(.horizontal)
                    }
                    
                    // Live Units
                    VStack(alignment: .leading) {
                        Text("LIVE UNITS").techHeader().padding(.horizontal)
                        ForEach(dataManager.tanks) { tank in
                            TankRowCard(tank: tank)
                        }
                        .padding(.horizontal)
                    }
                    Spacer(minLength: 50)
                }
            }
        }
    }
    
    func shareStatus() {
        print("Sharing status: \(dataManager.farmHealthScore)% Health")
        // In a real app, this would open UIActivityViewController
    }
}

// --- METRIC DETAIL VIEW (Analysis) ---
struct MetricDetailView: View {
    let title: String
    let value: String
    let status: String
    let statusColor: Color
    let description: String
    let recommendation: String
    let dataPoints: [Double]
    let color: Color
    
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header Card
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(title).techHeader()
                                Spacer()
                                Text(status)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(statusColor.opacity(0.2))
                                    .foregroundStyle(statusColor)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(statusColor, lineWidth: 1))
                                    .neonGlow(color: statusColor, radius: 5)
                            }
                            
                            HStack(alignment: .lastTextBaseline) {
                                Text(value)
                                    .font(.system(size: 48, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.title)
                                    .foregroundStyle(color)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Chart
                    VStack(alignment: .leading) {
                        Text("24-HOUR TREND").techHeader().padding(.horizontal)
                        GlassCard {
                            Chart {
                                ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, val in
                                    LineMark(
                                        x: .value("Hour", index),
                                        y: .value("Value", val)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(color.gradient)
                                    .symbol(Circle())
                                    
                                    AreaMark(
                                        x: .value("Hour", index),
                                        y: .value("Value", val)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [color.opacity(0.3), .clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                }
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .automatic) { _ in
                                    AxisGridLine().foregroundStyle(.gray.opacity(0.2))
                                    AxisTick().foregroundStyle(.gray)
                                    AxisValueLabel().foregroundStyle(.gray)
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .automatic) { _ in
                                    AxisGridLine().foregroundStyle(.gray.opacity(0.2))
                                    AxisValueLabel().foregroundStyle(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // AI Analysis Block
                    VStack(alignment: .leading) {
                        Text("AI INTERPRETATION").techHeader().padding(.horizontal)
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundStyle(Color.brandPrimary)
                                    Text("ANALYSIS COMPLETE")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.brandPrimary)
                                }
                                
                                Text(description)
                                    .font(.body)
                                    .foregroundStyle(.white)
                                    .lineSpacing(4)
                                
                                Divider().background(.gray.opacity(0.3))
                                
                                HStack(alignment: .top) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundStyle(.yellow)
                                    Text(recommendation)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// ... AIInsightView, FinancialView, ChatView, TankDetailView, etc. (kept same) ...

// (Re-pasting necessary helper views to ensure compilation)

struct AIInsightView: View {
    @ObservedObject var dataManager: DataManager
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Text("AI CORE MANAGEMENT").techHeader().frame(maxWidth: .infinity, alignment: .leading).padding()
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "brain.head.profile").font(.title).foregroundStyle(Color.brandPrimary).neonGlow()
                                VStack(alignment: .leading) { Text("AUTOPILOT").font(.headline).foregroundStyle(.white); Text("Global Farm Management").font(.caption).foregroundStyle(.gray) }
                                Spacer(); Toggle("", isOn: $dataManager.autoManageAll).tint(Color.brandPrimary)
                            }
                            Divider().background(.gray)
                            HStack { StatusPill(label: "FEEDING", isActive: true); StatusPill(label: "AERATION", isActive: true); StatusPill(label: "HARVEST", isActive: false) }
                        }
                    }.padding(.horizontal)
                    VStack(alignment: .leading) {
                        Text("SECTOR AUTOMATION").techHeader().padding(.horizontal)
                        ForEach(["Grow-out A", "Grow-out B", "Nursery", "Hatchery"], id: \.self) { sector in
                            HStack {
                                Text(sector).foregroundStyle(.white).fontWeight(.medium); Spacer()
                                Text(dataManager.autoManageAll ? "AI MANAGED" : "MANUAL").font(.caption).foregroundStyle(dataManager.autoManageAll ? Color.brandPrimary : .orange).neonGlow(color: dataManager.autoManageAll ? .brandPrimary : .clear)
                            }.padding().background(Color.brandSurface).clipShape(RoundedRectangle(cornerRadius: 12)).padding(.horizontal)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("NEURAL LOGS").techHeader().padding(.horizontal)
                        ForEach(0..<3) { i in
                            HStack(alignment: .top) {
                                Text(Date().addingTimeInterval(Double(-i*300)), style: .time).font(.caption2).foregroundStyle(.gray).monospacedDigit()
                                Text("Optimized feeding curve for Pond 0\(i+1) based on solar radiation forecast.").font(.caption).foregroundStyle(.white.opacity(0.8))
                            }.padding(.horizontal).padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }
}

struct FinancialView: View {
    @ObservedObject var dataManager: DataManager
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Text("EXECUTIVE OVERVIEW").techHeader().frame(maxWidth: .infinity, alignment: .leading).padding()
                    GlassCard {
                        VStack {
                            Text("NET PROFIT (MTD)").font(.caption).foregroundStyle(.gray)
                            Text("$\(Int(dataManager.monthlyRevenue - dataManager.monthlyCost))").font(.system(size: 48, design: .rounded)).fontWeight(.bold).foregroundStyle(.white)
                            HStack { Image(systemName: "arrow.up.right").foregroundStyle(Color.brandPrimary); Text("+12.4% vs last month").font(.caption).foregroundStyle(Color.brandPrimary) }
                        }
                    }.padding(.horizontal)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        MetricCard(title: "REVENUE", value: "$\(Int(dataManager.monthlyRevenue/1000))k", unit: "", icon: "dollarsign.circle", color: .green, trend: [])
                        MetricCard(title: "OPEX", value: "$\(Int(dataManager.monthlyCost/1000))k", unit: "", icon: "creditcard.fill", color: .red, trend: [])
                        MetricCard(title: "BIOMASS", value: "4.2", unit: "TONS", icon: "fish.fill", color: .cyan, trend: [])
                        MetricCard(title: "POWER SAVED", value: "1.2", unit: "MWh", icon: "sun.max.fill", color: .yellow, trend: [])
                    }.padding(.horizontal)
                }
            }
        }
    }
}

struct ChatView: View {
    @ObservedObject var dataManager: DataManager; @State private var text = ""
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(dataManager.chatHistory) { msg in
                        VStack(alignment: .leading, spacing: 4) {
                            if !msg.isUser && !msg.isSystemEvent, let reasoning = msg.reasoning {
                                Text("Reasoning Process:").font(.caption2).foregroundStyle(.gray).textCase(.uppercase); Text(reasoning).font(.caption).foregroundStyle(.gray).italic().padding(.bottom, 4)
                            }
                            HStack {
                                if !msg.isUser && !msg.isSystemEvent { Image(systemName: "cpu").foregroundStyle(Color.brandPrimary) }
                                Text(msg.text).padding().background(msg.isUser ? Color.brandPrimary.opacity(0.2) : Color.brandSurface).clipShape(RoundedRectangle(cornerRadius: 16)).foregroundStyle(.white).frame(maxWidth: .infinity, alignment: msg.isUser ? .trailing : .leading)
                            }
                        }
                    }
                    if dataManager.isAIThinking { HStack { Image(systemName: "waveform").symbolEffect(.bounce); Text("Thinking...") }.font(.caption).foregroundStyle(.gray) }
                }.padding()
            }
            HStack { TextField("Command...", text: $text).textFieldStyle(.roundedBorder).colorScheme(.dark); Button(action: { dataManager.sendMessage(text); text = "" }) { Image(systemName: "arrow.up.circle.fill").font(.title2) } }.padding().background(Color.brandSurface)
        }.background(Color.brandBackground)
    }
}

struct TankDetailView: View {
    let tank: Tank
    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(tank.name).font(.largeTitle).fontWeight(.black).foregroundStyle(.white).padding(.horizontal)
                    Text("INVENTORY & SPECS").techHeader().padding(.horizontal)
                    GlassCard {
                        VStack(spacing: 16) {
                            InventoryRow(icon: "sensor.fill", label: "IoT Sensors", value: "\(tank.sensorCount) Active")
                            Divider().background(.gray)
                            InventoryRow(icon: "drop.fill", label: "Pumps", value: "\(tank.pumpCount) (Variable Speed)")
                            Divider().background(.gray)
                            InventoryRow(icon: "fork.knife", label: "Feeder", value: tank.feederStatus)
                            Divider().background(.gray)
                            InventoryRow(icon: "fish.fill", label: "Species", value: tank.species)
                        }
                    }.padding(.horizontal)
                }
            }
        }
    }
}
struct InventoryRow: View { let icon: String, label: String, value: String; var body: some View { HStack { Image(systemName: icon).foregroundStyle(Color.brandPrimary).frame(width: 24); Text(label).foregroundStyle(.gray); Spacer(); Text(value).foregroundStyle(.white).fontWeight(.bold) } } }
struct StatusPill: View { let label: String, isActive: Bool; var body: some View { Text(label).font(.system(size: 10, weight: .bold)).padding(.horizontal, 8).padding(.vertical, 4).background(isActive ? Color.brandPrimary.opacity(0.2) : Color.gray.opacity(0.2)).foregroundStyle(isActive ? Color.brandPrimary : .gray).clipShape(Capsule()).overlay(Capsule().stroke(isActive ? Color.brandPrimary : .clear, lineWidth: 1)) } }

// --- SHARED COMPS ---
struct TiboLogo: View {
    var isHighContrast: Bool = false
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHighContrast ? .white : Color.brandPrimary)
                    .frame(width: 28, height: 28)
                    .neonGlow(color: isHighContrast ? .clear : .brandPrimary, radius: 8)
                Image(systemName: "drop.fill")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.black)
            }
            VStack(alignment: .leading, spacing: -4) {
                Text("TIBO")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(isHighContrast ? .white : .white)
                    .tracking(2)
                Text("AQUACULTURE AI")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(isHighContrast ? .white : Color.brandPrimary)
                    .tracking(1)
            }
        }
    }
}
struct MetricCard: View { let title: String; let value: String; let unit: String; let icon: String; let color: Color; let trend: [Double]; var body: some View { GlassCard { VStack(alignment: .leading, spacing: 12) { HStack { Image(systemName: icon).foregroundStyle(color).padding(8).background(color.opacity(0.1)).clipShape(Circle()).neonGlow(color: color, radius: 5); Spacer() }; VStack(alignment: .leading, spacing: 0) { HStack(alignment: .firstTextBaseline, spacing: 2) { Text(value).font(.system(size: 24, weight: .semibold, design: .rounded)).foregroundStyle(.white); Text(unit).font(.system(size: 12, weight: .bold)).foregroundStyle(.gray) }; Text(title).font(.system(size: 10, weight: .bold)).foregroundStyle(.gray.opacity(0.8)) }; if !trend.isEmpty { Chart { ForEach(Array(trend.enumerated()), id: \.offset) { i, v in LineMark(x: .value("T", i), y: .value("V", v)).interpolationMethod(.catmullRom).foregroundStyle(LinearGradient(colors: [color, color.opacity(0.1)], startPoint: .top, endPoint: .bottom)); AreaMark(x: .value("T", i), y: .value("V", v)).interpolationMethod(.catmullRom).foregroundStyle(LinearGradient(colors: [color.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)) } }.chartXAxis(.hidden).chartYAxis(.hidden).frame(height: 25) } } } } }
struct TankRowCard: View { let tank: Tank; var body: some View { NavigationLink(destination: TankDetailView(tank: tank)) { GlassCard { HStack(spacing: 16) { Capsule().fill(tank.aiStatus.color).frame(width: 4).neonGlow(color: tank.aiStatus.color, radius: 5); VStack(alignment: .leading, spacing: 8) { HStack { Text(tank.name).font(.headline).foregroundStyle(.white); Spacer(); if tank.connectionStatus == .offline { Text("OFFLINE").font(.system(size: 9, weight: .bold)).padding(.horizontal, 6).padding(.vertical, 2).background(Color.red.opacity(0.2)).foregroundStyle(.red).clipShape(Capsule()) } else { Circle().fill(tank.aiStatus.color).frame(width: 6, height: 6).neonGlow(color: tank.aiStatus.color, radius: 4) } }; HStack(spacing: 16) { DataPoint(label: "TEMP", value: "\(String(format: "%.1f", tank.temperature))°"); DataPoint(label: "pH", value: String(format: "%.1f", tank.pH)); DataPoint(label: "O2", value: String(format: "%.1f", tank.dissolvedOxygen)); Spacer(); Chart { ForEach(Array(tank.tempHistory.enumerated()), id: \.offset) { i, v in LineMark(x: .value("T", i), y: .value("V", v)).foregroundStyle(tank.aiStatus.color.gradient) } }.chartXAxis(.hidden).chartYAxis(.hidden).frame(width: 40, height: 20) } }; Image(systemName: "chevron.right").font(.caption).foregroundStyle(.gray) } } } } }
struct DataPoint: View { let label: String, value: String; var body: some View { VStack(alignment: .leading, spacing: 2) { Text(label).font(.system(size: 8, weight: .bold)).foregroundStyle(.gray); Text(value).font(.system(.callout, design: .monospaced)).fontWeight(.medium).foregroundStyle(.white) } } }
struct TankListView: View { let tanks: [Tank]; var body: some View { List(tanks) { t in NavigationLink(t.name, destination: TankDetailView(tank: t)) }.scrollContentBackground(.hidden).background(Color.brandBackground) } }

#Preview { ContentView() }
