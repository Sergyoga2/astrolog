//
//  GlossaryView.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Components/GlossaryView.swift
import SwiftUI

struct GlossaryView: View {
    @StateObject private var glossaryService = AstrologyGlossaryService()
    @State private var selectedTerm: GlossaryTerm?

    var body: some View {
        NavigationView {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Фильтры
                    filtersSection
                        .padding(.horizontal, CosmicSpacing.medium)
                        .padding(.bottom, CosmicSpacing.small)

                    // Список терминов
                    if glossaryService.filteredTerms.isEmpty {
                        emptyStateView
                    } else {
                        termsList
                    }
                }
            }
            .navigationTitle("Глоссарий")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedTerm) { term in
            TermDetailView(term: term, glossaryService: glossaryService)
        }
    }

    // MARK: - Filters
    private var filtersSection: some View {
        VStack(spacing: CosmicSpacing.medium) {
            // Фильтры по категориям
            categoryFilters

            // Фильтр по уровню
            levelFilter
        }
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CosmicSpacing.small) {
                // Кнопка "Все категории"
                CategoryFilterButton(
                    title: "Все",
                    icon: "square.grid.2x2",
                    color: .starWhite,
                    isSelected: glossaryService.selectedCategory == nil
                ) {
                    glossaryService.selectedCategory = nil
                }

                ForEach(GlossaryCategory.allCases, id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: glossaryService.selectedCategory == category
                    ) {
                        glossaryService.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, CosmicSpacing.medium)
        }
    }

    private var levelFilter: some View {
        HStack {
            Text("Уровень:")
                .font(CosmicTypography.caption)
                .foregroundColor(.starWhite.opacity(0.8))

            Spacer()

            Picker("Уровень", selection: $glossaryService.selectedLevel) {
                ForEach(DisplayMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    // MARK: - Terms List
    private var termsList: some View {
        List {
            ForEach(glossaryService.filteredTerms) { term in
                TermRowView(term: term) {
                    selectedTerm = term
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }

    private var emptyStateView: some View {
        VStack(spacing: CosmicSpacing.large) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.starWhite.opacity(0.3))

            VStack(spacing: CosmicSpacing.small) {
                Text("Термины не найдены")
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starWhite)

                Text("Попробуйте выбрать другие фильтры")
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            CosmicButton(
                title: "Сбросить фильтры",
                icon: "arrow.clockwise",
                color: .neonCyan
            ) {
                withAnimation {
                    glossaryService.selectedCategory = nil
                    glossaryService.selectedLevel = .beginner
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(CosmicSpacing.large)
    }

}

// MARK: - Supporting Views

struct CategoryFilterButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CosmicSpacing.small) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(CosmicTypography.caption)
            }
            .padding(.horizontal, CosmicSpacing.medium)
            .padding(.vertical, CosmicSpacing.small)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? color.opacity(0.3) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color, lineWidth: isSelected ? 2 : 1)
                    )
            )
            .foregroundColor(isSelected ? color : .starWhite.opacity(0.7))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TermRowView: View {
    let term: GlossaryTerm
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Иконка категории
                Image(systemName: term.category.icon)
                    .font(.title3)
                    .foregroundColor(term.category.color)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: CosmicSpacing.tiny) {
                    HStack {
                        Text(term.term)
                            .font(CosmicTypography.headline)
                            .foregroundColor(.starWhite)

                        Spacer()

                        levelBadge
                    }

                    Text(term.definition)
                        .font(CosmicTypography.caption)
                        .foregroundColor(.starWhite.opacity(0.7))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if !term.keywords.isEmpty {
                        HStack(spacing: CosmicSpacing.tiny) {
                            ForEach(Array(term.keywords.prefix(3)), id: \.self) { keyword in
                                Text(keyword)
                                    .font(.caption2)
                                    .padding(.horizontal, CosmicSpacing.tiny)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(term.category.color.opacity(0.2))
                                    )
                                    .foregroundColor(term.category.color)
                            }
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.3))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(term.category.color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var levelBadge: some View {
        Text(term.level.shortName)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(term.level.color.opacity(0.3))
            )
            .foregroundColor(term.level.color)
    }
}

struct TermDetailView: View {
    let term: GlossaryTerm
    @ObservedObject var glossaryService: AstrologyGlossaryService
    @State private var showingRelated = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: CosmicSpacing.large) {
                        // Заголовок с иконкой
                        termHeader

                        // Основное определение
                        definitionSection

                        // Детальное объяснение
                        if !term.detailedExplanation.isEmpty {
                            detailSection
                        }

                        // Примеры
                        if !term.examples.isEmpty {
                            examplesSection
                        }

                        // Синонимы
                        if !term.synonyms.isEmpty {
                            synonymsSection
                        }

                        // Ключевые слова
                        if !term.keywords.isEmpty {
                            keywordsSection
                        }

                        // Связанные термины
                        relatedTermsSection

                        Spacer(minLength: CosmicSpacing.large)
                    }
                    .padding(CosmicSpacing.large)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.body)
                                .fontWeight(.medium)
                            Text("Назад")
                                .font(CosmicTypography.body)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.neonCyan)
                        .frame(height: 36)
                    }
                }
            }
        }
    }

    private var termHeader: some View {
        HStack {
            Image(systemName: term.category.icon)
                .font(.largeTitle)
                .foregroundColor(term.category.color)
                .modifier(NeonGlow(color: term.category.color, intensity: 0.8))

            VStack(alignment: .leading) {
                Text(term.term)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.starWhite)

                HStack {
                    Text(term.category.rawValue)
                        .font(CosmicTypography.caption)
                        .foregroundColor(term.category.color)

                    Spacer()

                    Text(term.level.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(term.level.color.opacity(0.3))
                        )
                        .foregroundColor(term.level.color)
                }
            }
        }
    }

    private var definitionSection: some View {
        CosmicCard(glowColor: term.category.color) {
            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                Label("Определение", systemImage: "book")
                    .font(CosmicTypography.headline)
                    .foregroundColor(term.category.color)

                Text(term.definition)
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite)
                    .lineSpacing(2)
            }
        }
    }

    private var detailSection: some View {
        CosmicCard(glowColor: term.category.color.opacity(0.5)) {
            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                Label("Подробнее", systemImage: "info.circle")
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starWhite.opacity(0.9))

                Text(term.detailedExplanation)
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite.opacity(0.8))
                    .lineSpacing(2)
            }
        }
    }

    private var examplesSection: some View {
        CosmicCard(glowColor: .starYellow.opacity(0.5)) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                Label("Примеры", systemImage: "lightbulb")
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starYellow)

                ForEach(Array(term.examples.enumerated()), id: \.offset) { index, example in
                    HStack(alignment: .top, spacing: CosmicSpacing.small) {
                        Text("\(index + 1).")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starYellow.opacity(0.7))
                            .frame(minWidth: 20, alignment: .leading)

                        Text(example)
                            .font(CosmicTypography.body)
                            .foregroundColor(.starWhite.opacity(0.8))
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }

    private var synonymsSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
            Label("Синонимы", systemImage: "equal.square")
                .font(CosmicTypography.headline)
                .foregroundColor(.neonCyan)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: CosmicSpacing.small) {
                ForEach(term.synonyms, id: \.self) { synonym in
                    Text(synonym)
                        .font(CosmicTypography.body)
                        .padding(.horizontal, CosmicSpacing.medium)
                        .padding(.vertical, CosmicSpacing.small)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.neonCyan.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.neonCyan.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .foregroundColor(.neonCyan)
                }
            }
        }
    }

    private var keywordsSection: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.small) {
            Label("Ключевые слова", systemImage: "key")
                .font(CosmicTypography.headline)
                .foregroundColor(.cosmicViolet)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: CosmicSpacing.small) {
                ForEach(term.keywords, id: \.self) { keyword in
                    Text("#\(keyword)")
                        .font(CosmicTypography.caption)
                        .padding(.horizontal, CosmicSpacing.small)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.cosmicViolet.opacity(0.2))
                        )
                        .foregroundColor(.cosmicViolet)
                }
            }
        }
    }

    private var relatedTermsSection: some View {
        let relatedTerms = glossaryService.getRelatedTerms(for: term.id)

        return Group {
            if !relatedTerms.isEmpty {
                VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                    Label("Связанные термины", systemImage: "link")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.neonPink)

                    ForEach(relatedTerms.prefix(5)) { relatedTerm in
                        HStack {
                            Image(systemName: relatedTerm.category.icon)
                                .foregroundColor(relatedTerm.category.color)
                                .frame(width: 20)

                            Text(relatedTerm.term)
                                .font(CosmicTypography.body)
                                .foregroundColor(.starWhite)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.starWhite.opacity(0.5))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                        .onTapGesture {
                            // Переход к связанному термину
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Display Mode Extensions
extension DisplayMode {
    var shortName: String {
        switch self {
        case .human: return "Ч"
        case .beginner: return "Н"
        case .intermediate: return "С"
        }
    }
}


#Preview {
    GlossaryView()
}