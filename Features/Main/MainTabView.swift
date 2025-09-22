//
//  MainTabView.swift
//  Astrolog
//
//  Created by Sergey on 19.09.2025.
//
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Сегодня")
                }
            
            ChartView()
                .tabItem {
                    Image(systemName: "star")
                    Text("Карта")
                }
            
            SocialView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Друзья")
                }
            
            MindfulnessView()
                .tabItem {
                    Image(systemName: "leaf")
                    Text("Практики")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Профиль")
                }
        }
    }
}

// Временные заглушки для табов
struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Секция гороскопа
                    HoroscopeSection(
                        horoscope: viewModel.dailyHoroscope,
                        isLoading: viewModel.isLoadingHoroscope,
                        errorMessage: viewModel.errorMessage
                    )
                    
                    // Секция транзитов
                    if !viewModel.currentTransits.isEmpty {
                        TransitsSection(transits: viewModel.currentTransits)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .navigationTitle("Сегодня")
            .refreshable {
                viewModel.refreshContent()
            }
            .onAppear {
                if viewModel.dailyHoroscope == nil {
                    viewModel.loadTodayContent()
                }
            }
        }
    }
}

// MARK: - Horoscope Section

struct HoroscopeSection: View {
    let horoscope: DailyHoroscope?
    let isLoading: Bool
    let errorMessage: String?
    @StateObject private var subscriptionManager = SubscriptionManager()
    @State private var showSubscription = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Гороскоп на сегодня")
                    .font(.headline)
                Spacer()
                if let horoscope = horoscope {
                    Text("\(horoscope.sunSign.symbol) \(horoscope.sunSign.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
            }
            
            if isLoading {
                // Loading UI...
            } else if let horoscope = horoscope {
                VStack(alignment: .leading, spacing: 12) {
                    Text(horoscope.generalForecast)
                        .font(.body)
                    
                    // Premium gated content
                    if subscriptionManager.hasAccess(to: .detailedHoroscope) {
                        DisclosureGroup("Подробный прогноз") {
                            VStack(alignment: .leading, spacing: 8) {
                                DetailRow(title: "💕 Любовь и отношения", text: horoscope.loveAndRelationships)
                                DetailRow(title: "💼 Карьера и финансы", text: horoscope.careerAndFinances)
                                DetailRow(title: "🏃‍♂️ Здоровье и энергия", text: horoscope.healthAndEnergy)
                            }
                            .padding(.top, 8)
                        }
                    } else {
                        Button(action: {
                            showSubscription = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Подробный прогноз")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("Любовь, карьера, здоровье и финансы")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.purple)
                                
                                Text("Pro")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.purple)
                                    .cornerRadius(4)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Rest of the UI...
                }
            }
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView()
        }
    }
}

struct DetailRow: View {
    let title: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Transits Section

struct TransitsSection: View {
    let transits: [Transit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Текущие транзиты")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(transits) { transit in
                TransitCard(transit: transit)
            }
        }
    }
}

struct TransitCard: View {
    let transit: Transit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(transit.planet.symbol) \(transit.aspectType.symbol) \(transit.natalPlanet.symbol)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("до \(transit.endDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(transit.description)
                .font(.caption)
                .foregroundColor(.primary)
            
            Text(transit.influence)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct ChartView: View {
    @StateObject private var viewModel = ChartViewModel()
    @State private var showBirthDataInput = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Рассчитываем вашу натальную карту...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else if !viewModel.hasBirthData {
                    VStack(spacing: 30) {
                        Image(systemName: "star.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.purple.opacity(0.6))
                        
                        VStack(spacing: 12) {
                            Text("Добавьте данные рождения")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Для расчета натальной карты нужны точные данные о дате, времени и месте рождения")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Добавить данные рождения") {
                            showBirthDataInput = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Spacer()
                    }
                    .padding()
                } else if let chart = viewModel.birthChart {
                    ScrollView {
                        VStack(spacing: 20) {
                            ChartSummaryCard(chart: chart)
                            PlanetsListView(planets: chart.planets)
                            AspectsList(aspects: chart.aspects)
                        }
                        .padding()
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Ошибка расчета")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(errorMessage)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Попробовать снова") {
                            viewModel.refreshChart()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Натальная карта")
            .toolbar {
                if viewModel.hasBirthData {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Обновить") {
                            viewModel.refreshChart()
                        }
                    }
                }
            }
            .sheet(isPresented: $showBirthDataInput) {
                BirthDataInputView()
                    .onDisappear {
                        viewModel.loadBirthData()
                    }
            }
        }
    }
}

struct ChartSummaryCard: View {
    let chart: BirthChart
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Основные позиции")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(chart.sunSign.symbol)")
                        .font(.title)
                    Text("Солнце в \(chart.sunSign.displayName)")
                        .font(.caption)
                }
                
                VStack {
                    Text("\(chart.moonSign.symbol)")
                        .font(.title)
                    Text("Луна в \(chart.moonSign.displayName)")
                        .font(.caption)
                }
                
                VStack {
                    Text("\(chart.ascendant.symbol)")
                        .font(.title)
                    Text("Асцендент \(chart.ascendant.displayName)")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PlanetsListView: View {
    let planets: [Planet]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Планеты")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(planets.filter { $0.type != .ascendant && $0.type != .midheaven }) { planet in
                    PlanetCard(planet: planet)
                }
            }
        }
    }
}

struct PlanetCard: View {
    let planet: Planet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(planet.type.symbol)
                    .font(.title2)
                Text(planet.type.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                if planet.isRetrograde {
                    Text("R")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(2)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(3)
                }
            }
            
            Text("\(planet.zodiacSign.symbol) \(planet.zodiacSign.displayName)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Дом \(planet.house)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AspectsList: View {
    let aspects: [Aspect]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Аспекты")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(aspects.prefix(10)) { aspect in
                    AspectRow(aspect: aspect)
                }
            }
        }
    }
}

struct AspectRow: View {
    let aspect: Aspect
    
    var body: some View {
        HStack {
            Text("\(aspect.planet1.symbol)")
                .font(.title3)
            
            Text(aspect.type.symbol) // ИСПРАВЛЕНО: aspect.type вместо aspect.aspectType
                .font(.title3)
                .foregroundColor(aspect.type.isHarmonic ? .green : .orange) // ИСПРАВЛЕНО: aspect.type
            
            Text("\(aspect.planet2.symbol)")
                .font(.title3)
            
            Spacer()
            
            Text("\(aspect.orb, specifier: "%.1f")°")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct SocialView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Друзья и совместимость")
                    .font(.title)
                Spacer()
            }
            .navigationTitle("Друзья")
        }
    }
}

struct MindfulnessView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Медитации и практики")
                    .font(.title)
                Spacer()
            }
            .navigationTitle("Практики")
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var showBirthDataInput = false
    @State private var savedBirthData: BirthData?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Аватар
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.purple.opacity(0.6))
                
                VStack(spacing: 8) {
                    Text("Пользователь")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Базовый план")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Секция данных рождения
                VStack(spacing: 12) {
                    if let birthData = savedBirthData {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📍 Данные рождения")
                                .font(.headline)
                            
                            Text("\(birthData.date.formatted(date: .abbreviated, time: .shortened))")
                                .font(.subheadline)
                            
                            Text("\(birthData.cityName), \(birthData.countryName)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if !birthData.isTimeExact {
                                Text("⏰ Время приблизительное")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        Button("Изменить данные рождения") {
                            showBirthDataInput = true
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button("Добавить данные рождения") {
                            showBirthDataInput = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                // Другие кнопки настроек
                VStack(spacing: 12) {
                    Button("Настройки уведомлений") {
                        // TODO
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Пройти онбординг заново") {
                        UserDefaults.standard.set(false, forKey: "onboarding_completed")
                        appCoordinator.startOnboarding()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Профиль")
            .onAppear {
                loadBirthData()
            }
            .sheet(isPresented: $showBirthDataInput) {
                BirthDataInputView()
                    .onDisappear {
                        // Обновляем данные при закрытии модала
                        loadBirthData()
                    }
            }
        }
    }
    
    private func loadBirthData() {
        if let data = UserDefaults.standard.data(forKey: "user_birth_data"),
           let birthData = try? JSONDecoder().decode(BirthData.self, from: data) {
            savedBirthData = birthData
        }
    }
}
