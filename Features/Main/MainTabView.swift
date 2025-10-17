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
                Text("\(transit.planet.symbol) \(transit.aspectType?.symbol ?? "-") \(transit.natalPlanet?.symbol ?? "")")
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

