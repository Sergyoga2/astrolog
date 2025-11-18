//
//  ChartView.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//
// Features/Chart/ChartView.swift
import SwiftUI

/// Главный экран натальной карты с новой архитектурой
struct ChartView: View {
    @StateObject private var viewModel: ChartViewModel
    @StateObject private var displayModeManager: ChartDisplayModeManager
    @StateObject private var tooltipService: TooltipService
    @StateObject private var tabState: ChartTabState
    @StateObject private var onboardingCoordinator: ChartOnboardingCoordinator

    // Инициализатор для правильной инициализации зависимостей
    init() {
        let displayModeManager = ChartDisplayModeManager()
        let tabState = ChartTabState(displayModeManager: displayModeManager)

        self._viewModel = StateObject(wrappedValue: ChartViewModel())
        self._displayModeManager = StateObject(wrappedValue: displayModeManager)
        self._tooltipService = StateObject(wrappedValue: TooltipService())
        self._tabState = StateObject(wrappedValue: tabState)

        // Создаем координатор онбординга с пустой картой по умолчанию
        // Реальная карта будет установлена в onAppear
        let mockChart = BirthChart.mock
        self._onboardingCoordinator = StateObject(
            wrappedValue: ChartOnboardingCoordinator(
                birthChart: mockChart,
                displayModeManager: displayModeManager
            )
        )
    }

    var body: some View {
        ZStack {
            // Космический фон
            StarfieldBackground()
                .ignoresSafeArea()

            if viewModel.hasBirthData {
                if let chart = viewModel.birthChart {
                    modernChartInterface(chart: chart)
                        .onAppear {
                            setupOnboardingIfNeeded(for: chart)
                        }
                } else if viewModel.isLoading {
                    CosmicLoadingView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                NoBirthDataView()
                    .padding(.horizontal, CosmicSpacing.medium)
            }

            // Система подсказок (поверх всего контента)
            TooltipOverlay(tooltipService: tooltipService)

            // Система онбординга (поверх всего интерфейса)
            if onboardingCoordinator.isActive {
                onboardingOverlay
                    .zIndex(1000) // Поверх всех элементов
            }

            // Debug overlay для тестирования онбординга (только в DEBUG сборках)
            #if DEBUG
            debugOnboardingButton
                .zIndex(999)
            #endif
        }
        .environmentObject(displayModeManager.interpretationEngine)
        .environmentObject(tooltipService)
        .onAppear {
            setupTooltipPresets()
        }
    }

    // MARK: - Modern Chart Interface
    @ViewBuilder
    private func modernChartInterface(chart: BirthChart) -> some View {
        VStack(spacing: 0) {
            // Заголовок с переключателем режимов
            ChartHeaderView(
                birthChart: chart,
                displayModeManager: displayModeManager
            )

            // Панель вкладок
            ChartTabBar(
                tabState: tabState,
                birthChart: chart,
                displayMode: displayModeManager.currentMode
            )

            // Содержимое вкладок
            ChartContentView(
                tabState: tabState,
                birthChart: chart,
                displayModeManager: displayModeManager
            )
        }
    }

    // MARK: - Onboarding Overlay
    @ViewBuilder
    private var onboardingOverlay: some View {
        switch onboardingCoordinator.currentStep {
        case .welcome:
            OnboardingWelcomeView(
                coordinator: onboardingCoordinator,
                birthChart: viewModel.birthChart ?? BirthChart.mock
            )

        case .basics:
            OnboardingBasicsView(
                coordinator: onboardingCoordinator,
                birthChart: viewModel.birthChart ?? BirthChart.mock
            )

        case .personalInsights:
            OnboardingPersonalView(
                coordinator: onboardingCoordinator,
                birthChart: viewModel.birthChart ?? BirthChart.mock
            )

        case .interactive:
            OnboardingInteractiveView(
                coordinator: onboardingCoordinator,
                birthChart: viewModel.birthChart ?? BirthChart.mock
            )
        }
    }

    // MARK: - Debug Components
    #if DEBUG
    @ViewBuilder
    private var debugOnboardingButton: some View {
        VStack {
            HStack {
                Spacer()

                Button(action: {
                    if onboardingCoordinator.isActive {
                        onboardingCoordinator.completeOnboarding()
                    } else {
                        onboardingCoordinator.resetOnboarding()
                        onboardingCoordinator.startOnboarding()
                    }
                }) {
                    Text(onboardingCoordinator.isActive ? "Skip Onboarding" : "Reset Onboarding")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.starWhite)
                        .cornerRadius(8)
                }
                .padding(.trailing, 16)
                .padding(.top, 50)
            }

            Spacer()
        }
    }
    #endif

    // MARK: - Setup Methods

    private func setupOnboardingIfNeeded(for chart: BirthChart) {
        // Автоматически запускаем онбординг для новых пользователей
        if !onboardingCoordinator.isCompleted && onboardingCoordinator.userProgress != .inProgress {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onboardingCoordinator.startOnboarding()
            }
        }
    }
    private func setupTooltipPresets() {
        // Применяем подходящие настройки подсказок для текущего режима
        switch displayModeManager.currentMode {
        case .human:
            tooltipService.applyBeginnerPreset() // Используем простые подсказки для режима "Понятно"
        case .beginner:
            tooltipService.applyBeginnerPreset()
        case .intermediate:
            tooltipService.applyExpertPreset()
        }
    }
}


// MARK: - Legacy Components (сохранены для совместимости)
// Эти компоненты заменены новой архитектурой, но оставлены для переходного периода

// MARK: - Отсутствуют данные рождения
struct NoBirthDataView: View {
    var body: some View {
        CosmicCard(glowColor: .neonPurple) {
            VStack(spacing: CosmicSpacing.large) {
                Image(systemName: "star.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.neonPurple)
                    .modifier(NeonGlow(color: .neonPurple, intensity: 1.0))

                VStack(spacing: CosmicSpacing.small) {
                    Text("Создадим натальную карту!")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)
                        .multilineTextAlignment(.center)

                    Text("Это быстро и просто - нужны только данные  вашего рождения")
                        .font(CosmicTypography.body)
                        .foregroundColor(.starWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                }

                CosmicButton(
                    title: "Хорошо, попробуем!",
                    icon: "plus.circle",
                    color: .neonPurple
                ) {
                    // Переход к экрану ввода данных
                }
            }
        }
        .padding(.top, CosmicSpacing.massive)
    }
}

// MARK: - Preview
#if DEBUG
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
            .preferredColorScheme(.dark)
    }
}
#endif
