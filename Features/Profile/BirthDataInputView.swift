//
//  BirthDataInputView.swift
//  Astrolog
//
//  Created by Sergey on 20.09.2025.
//
// Features/Profile/BirthDataInputView.swift
import SwiftUI

struct BirthDataInputView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BirthDataInputViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Дата и время рождения") {
                    DatePicker(
                        "Дата рождения",
                        selection: $viewModel.birthDate,
                        displayedComponents: [.date]
                    )
                    
                    HStack {
                        Toggle("Точное время известно", isOn: $viewModel.isTimeKnown)
                        
                        if !viewModel.isTimeKnown {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    viewModel.showTimeInfoSheet = true
                                }
                        }
                    }
                    
                    if viewModel.isTimeKnown {
                        DatePicker(
                            "Время рождения",
                            selection: $viewModel.birthTime,
                            displayedComponents: [.hourAndMinute]
                        )
                    }
                }
                
                Section("Место рождения") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("Город (например: Moscow)", text: $viewModel.cityName)
                                .onChange(of: viewModel.cityName) { _, newValue in
                                    viewModel.searchLocation(for: newValue)
                                }
                            
                            if viewModel.isSearchingLocation {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        
                        TextField("Страна (например: Russia)", text: $viewModel.countryName)
                        
                        // Предложения городов
                        if viewModel.showingSuggestions && !viewModel.locationSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Предложения:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ForEach(viewModel.locationSuggestions.prefix(5)) { suggestion in
                                    Button(action: {
                                        viewModel.selectLocation(suggestion)
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(suggestion.city)
                                                    .fontWeight(.medium)
                                                Text(suggestion.country)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "location.fill")
                                                .foregroundColor(.blue)
                                                .font(.caption)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                    
                    if viewModel.hasCoordinates {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("✅ Координаты найдены:")
                                .font(.caption)
                                .foregroundColor(.green)
                            
                            Text("Широта: \(viewModel.latitude, specifier: "%.4f")°")
                                .font(.caption)
                            Text("Долгота: \(viewModel.longitude, specifier: "%.4f")°")
                                .font(.caption)
                        }
                        .padding(.top, 4)
                    } else if !viewModel.cityName.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ℹ️ Координаты не найдены")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("Попробуйте выбрать из предложений или введите точнее")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Часовой пояс") {
                    Picker("Часовой пояс", selection: $viewModel.selectedTimeZone) {
                        ForEach(viewModel.availableTimeZones, id: \.identifier) { timeZone in
                            Text(timeZone.localizedName(for: .standard, locale: .current) ?? timeZone.identifier)
                                .tag(timeZone)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Секция для ручного ввода координат (для продвинутых пользователей)
                Section("Альтернативный ввод") {
                    DisclosureGroup("Ввести координаты вручную") {
                        VStack(spacing: 12) {
                            Text("Если не можете найти город, введите координаты вручную")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Широта:")
                                TextField("55.7558", value: $viewModel.latitude, format: .number)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            HStack {
                                Text("Долгота:")
                                TextField("37.6173", value: $viewModel.longitude, format: .number)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            Button("Применить координаты") {
                                viewModel.manuallySetCoordinates(lat: viewModel.latitude, lon: viewModel.longitude)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Данные рождения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.saveBirthData()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .sheet(isPresented: $viewModel.showTimeInfoSheet) {
                TimeInfoSheet()
            }
            .onChange(of: viewModel.isSaved) { _, saved in
                if saved {
                    dismiss()
                }
            }
        }
    }
}

struct TimeInfoSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "clock")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                VStack(spacing: 12) {
                    Text("Зачем нужно точное время?")
                        .font(.headline)
                    
                    Text("Время рождения влияет на:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("•")
                            Text("Асцендент (восходящий знак)")
                        }
                        HStack {
                            Text("•")
                            Text("Положение домов")
                        }
                        HStack {
                            Text("•")
                            Text("Точное положение Луны")
                        }
                        HStack {
                            Text("•")
                            Text("Середину неба (MC)")
                        }
                    }
                    .font(.subheadline)
                }
                
                Text("Если точное время неизвестно, мы используем полдень для расчетов.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                Spacer()
            }
            .padding()
            .navigationTitle("О времени рождения")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Понятно") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    BirthDataInputView()
}
