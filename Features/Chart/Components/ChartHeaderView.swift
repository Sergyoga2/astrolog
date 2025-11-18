//
//  ChartHeaderView.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Components/ChartHeaderView.swift
import SwiftUI

/// Заголовок экрана натальной карты с переключателем режимов
struct ChartHeaderView: View {
    let birthChart: BirthChart
    @ObservedObject var displayModeManager: ChartDisplayModeManager
    @EnvironmentObject var tooltipService: TooltipService

    @State private var showModeInfo = false
    @State private var animateTitle = false

    var body: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Основной заголовок
            titleSection

            // Переключатель режимов
            modeSelector

            // Краткая информация о карте
            if displayModeManager.currentMode != .beginner {
                chartSummary
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(.horizontal, CosmicSpacing.large)
        .padding(.vertical, CosmicSpacing.medium)
        .background(headerBackground)
        .onAppear {
            animateTitle = true
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(spacing: CosmicSpacing.small) {
            // Заголовок карты
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Натальная карта")
                        .font(CosmicTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.starWhite)
                        .scaleEffect(animateTitle ? 1.0 : 0.8)
                        .opacity(animateTitle ? 1.0 : 0.0)
                }

                Spacer()
            }
        }
    }

    private var chartIcon: some View {
        ZStack {
            Circle()
                .fill(CosmicGradients.nebula)
                .frame(width: 50, height: 50)

            Text("⭐️")
                .font(.title)
                .rotationEffect(.degrees(animateTitle ? 360 : 0))
        }
        .animation(.easeInOut(duration: 1.0).delay(0.3), value: animateTitle)
    }

    private var locationInfo: some View {
        HStack(spacing: CosmicSpacing.small) {
            Image(systemName: "location.fill")
                .font(.caption)
                .foregroundColor(.neonCyan)

            Text(birthChart.location)
                .font(CosmicTypography.caption)
                .foregroundColor(.starWhite.opacity(0.9))

            if displayModeManager.currentMode == .intermediate {
                Text("(\(String(format: "%.1f", birthChart.latitude))°, \(String(format: "%.1f", birthChart.longitude))°)")
                    .font(.caption2)
                    .foregroundColor(.starWhite.opacity(0.6))
            }
        }
    }

    // MARK: - Mode Selector
    private var modeSelector: some View {
        VStack(spacing: CosmicSpacing.small) {
            // Кликабельный заголовок секции
            Button(action: { showModeInfo.toggle() }) {
                HStack {
                    Text("Подробнее об уровнях сложности")
                        .font(CosmicTypography.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.neonCyan)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.neonCyan)
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(PlainButtonStyle())

            // Сегментированный контрол
            modeSegmentedControl
        }
        .sheet(isPresented: $showModeInfo) {
            ModeInfoSheet(displayModeManager: displayModeManager)
        }
    }


    private var modeSegmentedControl: some View {
        HStack(spacing: 4) {
            ForEach(DisplayMode.allCases, id: \.self) { mode in
                modeButton(mode)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmicPurple.opacity(0.3))
                .background(.ultraThinMaterial)
        )
    }

    private func modeButton(_ mode: DisplayMode) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                displayModeManager.setMode(mode)
            }
        }) {
            HStack(spacing: CosmicSpacing.tiny) {
                Image(systemName: mode.icon)
                    .font(.caption)

                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(displayModeManager.currentMode == mode ? .cosmicDarkPurple : .starWhite)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(displayModeManager.currentMode == mode ? mode.color : Color.clear)
                    .shadow(
                        color: displayModeManager.currentMode == mode ? mode.color.opacity(0.5) : .clear,
                        radius: displayModeManager.currentMode == mode ? 4 : 0
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(displayModeManager.currentMode == mode ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: displayModeManager.currentMode)
    }

    // MARK: - Chart Summary
    private var chartSummary: some View {
        VStack(spacing: CosmicSpacing.small) {
            // Основная троица (Солнце, Луна, Асцендент)
            bigThreeSection

            // Дополнительная информация для экспертного режима
            if displayModeManager.currentMode == .intermediate {
                additionalChartInfo
            }
        }
        .padding(CosmicSpacing.medium)
        .background(summaryBackground)
    }

    private var bigThreeSection: some View {
        HStack(spacing: CosmicSpacing.large) {
            bigThreeItem(
                title: "Солнце",
                symbol: "☀️",
                sign: birthChart.sunSign,
                description: "Личность"
            )

            Divider()
                .background(Color.starWhite.opacity(0.3))

            bigThreeItem(
                title: "Луна",
                symbol: "🌙",
                sign: birthChart.moonSign,
                description: "Эмоции"
            )

            Divider()
                .background(Color.starWhite.opacity(0.3))

            bigThreeItem(
                title: "ASC",
                symbol: "↗",
                sign: birthChart.ascendant,
                description: "Внешность"
            )
        }
    }

    private func bigThreeItem(title: String, symbol: String, sign: ZodiacSign, description: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Text(symbol)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite.opacity(0.8))
            }

            HStack(spacing: 2) {
                Text(sign.symbol)
                    .font(.caption)
                    .foregroundColor(sign.color)

                Text(sign.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(sign.color)
            }

            Text(description)
                .font(.caption2)
                .foregroundColor(.starWhite.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    private var additionalChartInfo: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            chartStatItem("Планеты", value: "\(birthChart.planets.count)")
            chartStatItem("Аспекты", value: "\(birthChart.aspects.count)")
            chartStatItem("Дата расчета", value: formatCalculationDate())
        }
    }

    private func chartStatItem(_ title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.neonCyan)

            Text(title)
                .font(.caption2)
                .foregroundColor(.starWhite.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.cosmicViolet.opacity(0.2))
        )
    }

    // MARK: - Background & Styling
    private var headerBackground: some View {
        LinearGradient(
            colors: [
                .cosmicDarkPurple.opacity(0.8),
                .cosmicPurple.opacity(0.6),
                .clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .background(.ultraThinMaterial)
    }

    private var summaryBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        .cosmicViolet.opacity(0.2),
                        .cosmicPurple.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.starWhite.opacity(0.2), lineWidth: 1)
            )
    }

    // MARK: - Helper Methods
    private func formatBirthDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: birthChart.birthDate)
    }

    private func formatCalculationDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: birthChart.calculatedAt)
    }
}

// MARK: - Mode Info Sheet
struct ModeInfoSheet: View {
    @ObservedObject var displayModeManager: ChartDisplayModeManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: CosmicSpacing.large) {
                    // Заголовок
                    headerSection

                    // Описания режимов
                    ForEach(DisplayMode.allCases, id: \.self) { mode in
                        modeDescriptionCard(mode)
                    }

                    // Настройки
                    settingsSection
                }
                .padding()
            }
            .background(CosmicGradients.mainCosmic)
            .navigationTitle("Режимы отображения")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Готово") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.neonCyan)
            )
        }
    }

    private var headerSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            Text("🎯")
                .font(.largeTitle)

            Text("Выберите подходящий уровень сложности для отображения натальной карты")
                .font(CosmicTypography.body)
                .foregroundColor(.starWhite.opacity(0.9))
                .multilineTextAlignment(.center)
        }
    }

    private func modeDescriptionCard(_ mode: DisplayMode) -> some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            // Заголовок режима
            HStack {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(mode.color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.rawValue)
                        .font(CosmicTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.starWhite)

                    Text(mode.description)
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.8))
                }

                Spacer()

                if displayModeManager.currentMode == mode {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.positive)
                }
            }

            Divider()
                .background(Color.starWhite.opacity(0.3))

            // Характеристики режима
            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                characteristicRow("Планеты", value: "\(mode.maxPlanets)")
                characteristicRow("Аспекты", value: mode.allowedAspects.map { $0.symbol }.joined(separator: " "))
                characteristicRow("Дома", value: mode.showHouses ? "Показывать" : "Скрывать")
                characteristicRow("Детализация", value: mode.recommendedDepth.description)
            }
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(mode.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(mode.color.opacity(0.3), lineWidth: displayModeManager.currentMode == mode ? 2 : 1)
                )
        )
        .onTapGesture {
            withAnimation(.spring()) {
                displayModeManager.setMode(mode)
            }
        }
    }

    private func characteristicRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title + ":")
                .font(.caption)
                .foregroundColor(.starWhite.opacity(0.7))

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.starWhite.opacity(0.9))
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            Text("Настройки")
                .font(CosmicTypography.headline)
                .fontWeight(.semibold)
                .foregroundColor(.starWhite)

            VStack(spacing: CosmicSpacing.small) {
                Toggle("Автоматическая подстройка режима", isOn: $displayModeManager.shouldAutoAdjustMode)
                    .foregroundColor(.starWhite.opacity(0.9))

                Toggle("Показывать продвинутые возможности", isOn: $displayModeManager.shouldShowAdvancedFeatures)
                    .foregroundColor(.starWhite.opacity(0.9))
            }
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cosmicPurple.opacity(0.2))
        )
    }
}

// MARK: - Preview
struct ChartHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleChart = BirthChart(
            id: "sample",
            userId: "user1",
            name: "Анна Иванова",
            birthDate: Date(),
            birthTime: "14:30",
            location: "Москва, Россия",
            latitude: 55.7558,
            longitude: 37.6176,
            planets: [],
            houses: [],
            aspects: [],
            calculatedAt: Date()
        )

        let displayModeManager = ChartDisplayModeManager()

        ChartHeaderView(
            birthChart: sampleChart,
            displayModeManager: displayModeManager
        )
        .background(CosmicGradients.mainCosmic)
        .environmentObject(TooltipService())
        .previewDevice("iPhone 15")
    }
}