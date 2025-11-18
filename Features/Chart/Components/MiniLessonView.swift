//
//  MiniLessonView.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Components/MiniLessonView.swift
import SwiftUI

struct MiniLessonListView: View {
    @StateObject private var lessonService = MiniLessonService()
    @State private var selectedCategory: LessonCategory?
    @State private var selectedLesson: MiniLesson?
    @State private var showingLessonDetail = false
    let displayMode: DisplayMode

    var body: some View {
        NavigationView {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Прогресс изучения
                    progressSection

                    // Категории уроков
                    categoryFilters

                    // Список уроков
                    lessonsListSection
                }
            }
            .navigationTitle("Мини-уроки")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                lessonService.updateDisplayMode(displayMode)
            }
        }
        .sheet(item: $selectedLesson) { lesson in
            // TODO: Fix MiniLessonDetailView import issue
            Text("Lesson Detail View")
        }
    }

    // MARK: - Progress Section
    private var progressSection: some View {
        CosmicCard(glowColor: .neonPink) {
            VStack(spacing: CosmicSpacing.medium) {
                HStack {
                    Image(systemName: "graduationcap.fill")
                        .foregroundColor(.neonPink)
                        .font(.title2)

                    Text("Ваш прогресс")
                        .font(CosmicTypography.headline)
                        .foregroundColor(.starWhite)

                    Spacer()

                    Text("\(Int(lessonService.getCompletionRate() * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.neonPink)
                }

                // Прогресс бар
                ProgressView(value: lessonService.getCompletionRate())
                    .progressViewStyle(CosmicProgressViewStyle(color: .neonPink))

                HStack {
                    Text("Завершено: \(lessonService.availableLessons.filter { $0.isCompleted }.count)")
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.8))

                    Spacer()

                    Text("Доступно: \(lessonService.availableLessons.count)")
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.8))
                }
            }
        }
        .padding(.horizontal, CosmicSpacing.medium)
        .padding(.bottom, CosmicSpacing.medium)
    }

    // MARK: - Category Filters
    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CosmicSpacing.small) {
                // Кнопка "Все уроки"
                CategoryButton(
                    title: "Все",
                    icon: "book.fill",
                    color: .starWhite,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                // Рекомендуемые
                CategoryButton(
                    title: "Рекомендуемые",
                    icon: "star.fill",
                    color: .starYellow,
                    isSelected: false
                ) {
                    // Показать рекомендуемые уроки
                }

                ForEach(LessonCategory.allCases, id: \.self) { category in
                    let categoryLessons = lessonService.availableLessons.filter { $0.category == category }

                    if !categoryLessons.isEmpty {
                        CategoryButton(
                            title: category.rawValue,
                            icon: category.icon,
                            color: category.color,
                            isSelected: selectedCategory == category,
                            count: categoryLessons.count
                        ) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
            }
            .padding(.horizontal, CosmicSpacing.medium)
        }
        .padding(.bottom, CosmicSpacing.medium)
    }

    // MARK: - Lessons List
    private var lessonsListSection: some View {
        List {
            let filteredLessons = selectedCategory == nil
                ? lessonService.availableLessons
                : lessonService.availableLessons.filter { $0.category == selectedCategory }

            if filteredLessons.isEmpty {
                emptyStateView
            } else {
                // Рекомендуемые уроки (если не выбрана категория)
                if selectedCategory == nil && !lessonService.getRecommendedLessons().isEmpty {
                    Section("Рекомендуем изучить") {
                        ForEach(lessonService.getRecommendedLessons()) { lesson in
                            MiniLessonCard(lesson: lesson) {
                                selectedLesson = lesson
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                }

                // Основные уроки
                Section(selectedCategory?.rawValue ?? "Все уроки") {
                    ForEach(filteredLessons.sorted { lesson1, lesson2 in
                        if lesson1.isCompleted != lesson2.isCompleted {
                            return !lesson1.isCompleted && lesson2.isCompleted
                        }
                        return lesson1.difficulty.rawValue < lesson2.difficulty.rawValue
                    }) { lesson in
                        MiniLessonCard(lesson: lesson) {
                            selectedLesson = lesson
                        }
                        .listRowBackground(Color.clear)
                    }
                }
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
                Text("Уроки не найдены")
                    .font(CosmicTypography.headline)
                    .foregroundColor(.starWhite)

                Text("Попробуйте выбрать другую категорию или повысьте свой уровень")
                    .font(CosmicTypography.body)
                    .foregroundColor(.starWhite.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(CosmicSpacing.large)
        .listRowBackground(Color.clear)
    }
}

// MARK: - Supporting Views

struct CategoryButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let count: Int?
    let action: () -> Void

    init(title: String, icon: String, color: Color, isSelected: Bool, count: Int? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.isSelected = isSelected
        self.count = count
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: CosmicSpacing.small) {
                Image(systemName: icon)
                    .font(.caption)

                Text(title)
                    .font(CosmicTypography.caption)

                if let count = count {
                    Text("(\(count))")
                        .font(.caption2)
                        .opacity(0.8)
                }
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

struct MiniLessonCard: View {
    let lesson: MiniLesson
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Иконка с прогрессом
                lessonIcon

                // Основная информация
                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    // Заголовок и бейджи
                    HStack {
                        Text(lesson.title)
                            .font(CosmicTypography.headline)
                            .foregroundColor(.starWhite)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if lesson.isCompleted {
                            completedBadge
                        }
                    }

                    // Метаданные
                    HStack(spacing: CosmicSpacing.small) {
                        difficultyBadge
                        durationBadge
                        Spacer()
                    }

                    // Описание
                    Text(lesson.introduction)
                        .font(.caption)
                        .foregroundColor(.starWhite.opacity(0.7))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Прогресс (если урок начат, но не завершен)
                    if lesson.progress > 0 && !lesson.isCompleted {
                        progressBar
                    }
                }

                // Стрелка
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.starWhite.opacity(0.3))
            }
            .padding(CosmicSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(lesson.accentColor.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var lessonIcon: some View {
        ZStack {
            Circle()
                .fill(lesson.accentColor.opacity(0.3))
                .frame(width: 50, height: 50)

            if lesson.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.neonGreen)
            } else {
                Image(systemName: lesson.icon)
                    .font(.title3)
                    .foregroundColor(lesson.accentColor)
            }

            // Прогресс кольцо для незавершенных уроков
            if !lesson.isCompleted && lesson.progress > 0 {
                Circle()
                    .trim(from: 0, to: lesson.progress)
                    .stroke(lesson.accentColor, lineWidth: 3)
                    .frame(width: 54, height: 54)
                    .rotationEffect(.degrees(-90))
            }
        }
    }

    private var completedBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
            Text("Завершено")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(.neonGreen)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.neonGreen.opacity(0.2))
        )
    }

    private var difficultyBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: lesson.difficulty.icon)
                .font(.caption2)
            Text(lesson.difficulty.rawValue)
                .font(.caption2)
        }
        .foregroundColor(lesson.difficulty.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(lesson.difficulty.color.opacity(0.2))
        )
    }

    private var durationBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock.fill")
                .font(.caption2)
            Text("\(lesson.estimatedReadingTime) мин")
                .font(.caption2)
        }
        .foregroundColor(.starWhite.opacity(0.6))
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(Color.starWhite.opacity(0.1))
        )
    }

    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Прогресс: \(Int(lesson.progress * 100))%")
                .font(.caption2)
                .foregroundColor(lesson.accentColor)

            ProgressView(value: lesson.progress)
                .progressViewStyle(CosmicProgressViewStyle(color: lesson.accentColor, height: 4))
        }
    }
}

struct CosmicProgressViewStyle: ProgressViewStyle {
    let color: Color
    let height: CGFloat

    init(color: Color, height: CGFloat = 8) {
        self.color = color
        self.height = height
    }

    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.starWhite.opacity(0.2))
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(
                        width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0),
                        height: height
                    )
                    .animation(.easeInOut(duration: 0.3), value: configuration.fractionCompleted)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    MiniLessonListView(displayMode: .beginner)
}