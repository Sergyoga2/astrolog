//
//  CosmicBirthDataInputView.swift
//  Astrolog
//
//  Created by Claude on 22.09.2025.
//

// Features/Profile/CosmicBirthDataInputView.swift
import SwiftUI

struct CosmicBirthDataInputView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BirthDataInputViewModel()
    @State private var showingSteps: [Bool] = [true, false, false, false]
    @State private var currentStep: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Космический фон
                StarfieldBackground()

                ScrollView {
                    VStack(spacing: CosmicSpacing.large) {
                        // Космический заголовок
                        CosmicHeaderSection()

                        // Прогресс бар
                        CosmicProgressBar(currentStep: currentStep)

                        // Шаги ввода данных
                        VStack(spacing: CosmicSpacing.large) {
                            // Шаг 1: Дата рождения
                            if showingSteps[0] {
                                CosmicDateStepCard(
                                    viewModel: viewModel,
                                    onNext: { nextStep(to: 1) }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }

                            // Шаг 2: Время рождения
                            if showingSteps[1] {
                                CosmicTimeStepCard(
                                    viewModel: viewModel,
                                    onNext: { nextStep(to: 2) },
                                    onPrevious: { previousStep(to: 0) }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }

                            // Шаг 3: Место рождения
                            if showingSteps[2] {
                                CosmicLocationStepCard(
                                    viewModel: viewModel,
                                    onNext: { nextStep(to: 3) },
                                    onPrevious: { previousStep(to: 1) }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }

                            // Шаг 4: Подтверждение и сохранение
                            if showingSteps[3] {
                                CosmicConfirmationCard(
                                    viewModel: viewModel,
                                    onSave: { saveData() },
                                    onPrevious: { previousStep(to: 2) }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, CosmicSpacing.medium)
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.isSaved) { saved in
            if saved {
                dismiss()
            }
        }
        .sheet(isPresented: $viewModel.showTimeInfoSheet) {
            CosmicTimeInfoSheet()
        }
    }

    private func nextStep(to step: Int) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showingSteps[currentStep] = false
            currentStep = step
            showingSteps[step] = true
        }
    }

    private func previousStep(to step: Int) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showingSteps[currentStep] = false
            currentStep = step
            showingSteps[step] = true
        }
    }

    private func saveData() {
        viewModel.saveBirthData()
    }
}

// MARK: - Header Section
struct CosmicHeaderSection: View {
    var body: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Космическая иконка
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.neonPurple.opacity(0.3), Color.cosmicViolet.opacity(0.1)],
                            center: .center,
                            startRadius: 10,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                    .modifier(NeonGlow(color: .neonPurple, intensity: 0.8))

                Image(systemName: "star.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.starWhite, .neonPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .floatingAnimation()

            VStack(spacing: CosmicSpacing.small) {
                Text("Ваш космический профиль")
                    .font(CosmicTypography.title)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.starWhite, .neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Введите данные рождения для создания натальной карты")
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, CosmicSpacing.large)
    }
}

// MARK: - Progress Bar
struct CosmicProgressBar: View {
    let currentStep: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<4) { step in
                Circle()
                    .fill(step <= currentStep ? Color.neonPurple : Color.starWhite.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .modifier(NeonGlow(
                        color: step <= currentStep ? .neonPurple : .clear,
                        intensity: step <= currentStep ? 0.8 : 0
                    ))
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentStep)

                if step < 3 {
                    Rectangle()
                        .fill(step < currentStep ? Color.neonPurple : Color.starWhite.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
        .padding(.horizontal, CosmicSpacing.large)
    }
}

// MARK: - Date Step Card
struct CosmicDateStepCard: View {
    @ObservedObject var viewModel: BirthDataInputViewModel
    let onNext: () -> Void

    var body: some View {
        CosmicCard(glowColor: .neonBlue.opacity(0.4)) {
            VStack(spacing: CosmicSpacing.large) {
                CosmicSectionHeader(
                    "Дата рождения",
                    subtitle: "Укажите точную дату вашего рождения",
                    icon: "calendar.circle"
                )

                VStack(spacing: CosmicSpacing.medium) {
                    DatePicker(
                        "",
                        selection: $viewModel.birthDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .colorScheme(.dark)
                }

                CosmicButton(
                    title: "Далее",
                    icon: "arrow.right",
                    color: .neonBlue,
                    action: onNext
                )
            }
        }
    }
}

// MARK: - Time Step Card
struct CosmicTimeStepCard: View {
    @ObservedObject var viewModel: BirthDataInputViewModel
    let onNext: () -> Void
    let onPrevious: () -> Void

    var body: some View {
        CosmicCard(glowColor: .neonPink.opacity(0.4)) {
            VStack(spacing: CosmicSpacing.large) {
                CosmicSectionHeader(
                    "Время рождения",
                    subtitle: "Время влияет на асцендент и дома",
                    icon: "clock.circle"
                )

                VStack(spacing: CosmicSpacing.medium) {
                    // Переключатель известности времени
                    HStack {
                        Toggle("Точное время известно", isOn: $viewModel.isTimeKnown)
                            .font(CosmicTypography.body)
                            .foregroundColor(.starWhite)

                        Button(action: {
                            viewModel.showTimeInfoSheet = true
                        }) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.neonBlue)
                                .font(.title3)
                        }
                    }

                    if viewModel.isTimeKnown {
                        DatePicker(
                            "",
                            selection: $viewModel.birthTime,
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(.wheel)
                        .colorScheme(.dark)
                    } else {
                        VStack(spacing: CosmicSpacing.small) {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundColor(.neonCyan)
                                .modifier(NeonGlow(color: .neonCyan, intensity: 0.6))

                            Text("Будет использовано время полдня")
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite.opacity(0.7))
                        }
                        .padding(CosmicSpacing.medium)
                    }
                }

                HStack(spacing: CosmicSpacing.medium) {
                    CosmicButton(
                        title: "Назад",
                        icon: "arrow.left",
                        color: .starWhite,
                        action: onPrevious
                    )

                    CosmicButton(
                        title: "Далее",
                        icon: "arrow.right",
                        color: .neonPink,
                        action: onNext
                    )
                }
            }
        }
    }
}

// MARK: - Location Step Card
struct CosmicLocationStepCard: View {
    @ObservedObject var viewModel: BirthDataInputViewModel
    let onNext: () -> Void
    let onPrevious: () -> Void

    var body: some View {
        CosmicCard(glowColor: .neonCyan.opacity(0.4)) {
            VStack(spacing: CosmicSpacing.large) {
                CosmicSectionHeader(
                    "Место рождения",
                    subtitle: "Найдем ваш город в космических картах",
                    icon: "location.circle"
                )

                VStack(spacing: CosmicSpacing.medium) {
                    // Поиск города
                    CosmicTextField("Введите город", text: $viewModel.cityName, icon: "magnifyingglass")
                        .onChange(of: viewModel.cityName) { newValue in
                            viewModel.searchLocation(for: newValue)
                        }

                    if viewModel.isSearchingLocation {
                        CosmicLoadingView()
                            .frame(height: 60)
                    }

                    // Предложения городов
                    if viewModel.showingSuggestions && !viewModel.locationSuggestions.isEmpty {
                        CosmicLocationSuggestions(
                            suggestions: Array(viewModel.locationSuggestions.prefix(5)),
                            onSelect: { suggestion in
                                viewModel.selectLocation(suggestion)
                            }
                        )
                    }

                    // Поле страны
                    CosmicTextField("Страна", text: $viewModel.countryName, icon: "globe")

                    // Статус координат
                    if viewModel.hasCoordinates {
                        CosmicCoordinatesDisplay(
                            latitude: viewModel.latitude,
                            longitude: viewModel.longitude
                        )
                    } else if !viewModel.cityName.isEmpty {
                        CosmicWarningMessage(text: "Координаты не найдены. Попробуйте выбрать из предложений.")
                    }
                }

                HStack(spacing: CosmicSpacing.medium) {
                    CosmicButton(
                        title: "Назад",
                        icon: "arrow.left",
                        color: .starWhite,
                        action: onPrevious
                    )

                    CosmicButton(
                        title: "Далее",
                        icon: "arrow.right",
                        color: .neonCyan,
                        action: onNext
                    )
                    .disabled(!viewModel.hasCoordinates)
                }
            }
        }
    }
}

// MARK: - Confirmation Card
struct CosmicConfirmationCard: View {
    @ObservedObject var viewModel: BirthDataInputViewModel
    let onSave: () -> Void
    let onPrevious: () -> Void

    var body: some View {
        CosmicCard(glowColor: .cosmicViolet.opacity(0.4)) {
            VStack(spacing: CosmicSpacing.large) {
                CosmicSectionHeader(
                    "Подтверждение",
                    subtitle: "Проверьте данные перед созданием карты",
                    icon: "checkmark.circle"
                )

                VStack(spacing: CosmicSpacing.medium) {
                    // Дата
                    CosmicDataRow(
                        icon: "calendar",
                        title: "Дата рождения",
                        value: viewModel.birthDate.formatted(date: .long, time: .omitted),
                        color: .neonBlue
                    )

                    // Время
                    CosmicDataRow(
                        icon: "clock",
                        title: "Время рождения",
                        value: viewModel.isTimeKnown
                            ? viewModel.birthTime.formatted(date: .omitted, time: .shortened)
                            : "12:00 (полдень)",
                        color: .neonPink
                    )

                    // Место
                    CosmicDataRow(
                        icon: "location",
                        title: "Место рождения",
                        value: "\(viewModel.cityName), \(viewModel.countryName)",
                        color: .neonCyan
                    )

                    // Координаты
                    if viewModel.hasCoordinates {
                        CosmicDataRow(
                            icon: "scope",
                            title: "Координаты",
                            value: String(format: "%.2f°, %.2f°", viewModel.latitude, viewModel.longitude),
                            color: .neonPurple
                        )
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    CosmicWarningMessage(text: errorMessage)
                }

                HStack(spacing: CosmicSpacing.medium) {
                    CosmicButton(
                        title: "Назад",
                        icon: "arrow.left",
                        color: .starWhite,
                        action: onPrevious
                    )

                    CosmicButton(
                        title: "Создать карту",
                        icon: "star.circle.fill",
                        color: .cosmicViolet,
                        action: onSave
                    )
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

// MARK: - Helper Components
struct CosmicLocationSuggestions: View {
    let suggestions: [LocationSuggestion]
    let onSelect: (LocationSuggestion) -> Void

    var body: some View {
        VStack(spacing: CosmicSpacing.small) {
            ForEach(suggestions) { suggestion in
                Button(action: {
                    onSelect(suggestion)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(suggestion.city)
                                .font(CosmicTypography.body)
                                .fontWeight(.medium)
                                .foregroundColor(.starWhite)

                            Text(suggestion.country)
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite.opacity(0.7))
                        }

                        Spacer()

                        Image(systemName: "location.fill")
                            .foregroundColor(.neonCyan)
                    }
                }
                .buttonStyle(.plain)
                .padding(CosmicSpacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                        )
                )
                .modifier(NeonGlow(color: .neonCyan, intensity: 0.2))
            }
        }
    }
}

struct CosmicCoordinatesDisplay: View {
    let latitude: Double
    let longitude: Double

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.neonGreen)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                Text("Координаты найдены")
                    .font(CosmicTypography.caption)
                    .foregroundColor(.neonGreen)
                    .fontWeight(.medium)

                Text(String(format: "Широта: %.4f°, Долгота: %.4f°", latitude, longitude))
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.8))
            }
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.neonGreen.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.neonGreen.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct CosmicWarningMessage: View {
    let text: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.starOrange)

            Text(text)
                .font(CosmicTypography.caption)
                .foregroundColor(.starWhite.opacity(0.8))
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.starOrange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.starOrange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct CosmicDataRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: CosmicSpacing.medium) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(color)
                .modifier(NeonGlow(color: color, intensity: 0.5))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(CosmicTypography.caption)
                    .foregroundColor(.starWhite.opacity(0.7))

                Text(value)
                    .font(CosmicTypography.body)
                    .fontWeight(.medium)
                    .foregroundColor(.starWhite)
            }

            Spacer()
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Cosmic Time Info Sheet
struct CosmicTimeInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            StarfieldBackground()

            VStack(spacing: CosmicSpacing.large) {
                // Заголовок
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.starWhite.opacity(0.6))
                    }
                }

                VStack(spacing: CosmicSpacing.medium) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.neonBlue.opacity(0.3), Color.clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)

                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.neonBlue, .starWhite],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .modifier(NeonGlow(color: .neonBlue, intensity: 0.8))
                    }
                    .rotationEffect(.degrees(15))
                    .floatingAnimation()

                    Text("Важность времени рождения")
                        .font(CosmicTypography.title)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.starWhite, .neonBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                CosmicCard(glowColor: .neonBlue.opacity(0.3)) {
                    VStack(spacing: CosmicSpacing.medium) {
                        Text("Время рождения влияет на:")
                            .font(CosmicTypography.body)
                            .foregroundColor(.starWhite.opacity(0.9))

                        VStack(spacing: CosmicSpacing.small) {
                            CosmicInfoRow(icon: "arrow.up.circle", text: "Асцендент (восходящий знак)", color: .neonPurple)
                            CosmicInfoRow(icon: "house", text: "Положение астрологических домов", color: .neonCyan)
                            CosmicInfoRow(icon: "moon.stars", text: "Точное положение Луны", color: .starWhite)
                            CosmicInfoRow(icon: "star", text: "Середину неба (MC)", color: .neonPink)
                        }

                        Text("Если точное время неизвестно, мы используем полдень для расчетов.")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.top, CosmicSpacing.small)
                    }
                }

                CosmicButton(
                    title: "Понятно",
                    icon: "checkmark.circle",
                    color: .neonBlue,
                    action: { dismiss() }
                )

                Spacer()
            }
            .padding(CosmicSpacing.medium)
        }
    }
}

struct CosmicInfoRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: CosmicSpacing.small) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(color)
                .modifier(NeonGlow(color: color, intensity: 0.5))

            Text(text)
                .font(CosmicTypography.body)
                .foregroundColor(.starWhite)

            Spacer()
        }
    }
}