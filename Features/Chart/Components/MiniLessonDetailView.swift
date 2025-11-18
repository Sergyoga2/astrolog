//
//  MiniLessonDetailView.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Features/Chart/Components/MiniLessonDetailView.swift
import SwiftUI

struct MiniLessonDetailView: View {
    let lesson: MiniLesson
    let lessonService: MiniLessonService

    @State private var currentSection: LessonSection = .introduction
    @State private var showingQuiz = false
    @State private var quizAnswers: [String: Int] = [:]
    @State private var quizCompleted = false
    @State private var scrollProgress: Double = 0

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Прогресс урока
                    lessonProgressBar

                    // Основное содержимое
                    lessonContentView
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть", action: { dismiss() })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if lesson.isCompleted {
                        completedIcon
                    }
                }
            }
        }
        .onDisappear {
            updateLessonProgress()
        }
    }

    // MARK: - Progress Bar
    private var lessonProgressBar: some View {
        VStack(spacing: CosmicSpacing.small) {
            // Заголовок урока
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(CosmicTypography.headline)
                        .foregroundColor(Color.starWhite)
                        .lineLimit(2)

                    HStack(spacing: CosmicSpacing.small) {
                        categoryBadge
                        difficultyBadge
                        durationBadge
                    }
                }

                Spacer()
            }
            .padding(.horizontal, CosmicSpacing.medium)

            // Прогресс бар
            ProgressView(value: scrollProgress)
                .progressViewStyle(CosmicProgressViewStyle(color: lesson.accentColor))
                .padding(.horizontal, CosmicSpacing.medium)
        }
        .padding(.vertical, CosmicSpacing.small)
        .background(.ultraThinMaterial)
    }

    // MARK: - Content View
    private var lessonContentView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: CosmicSpacing.large) {
                    // Введение
                    LessonSectionView(
                        id: "introduction",
                        title: "Введение",
                        icon: "info.circle.fill",
                        color: lesson.accentColor
                    ) {
                        Text(lesson.introduction)
                            .font(CosmicTypography.body)
                            .foregroundColor(Color.starWhite.opacity(0.9))
                            .lineSpacing(4)
                    }

                    // Ключевые моменты
                    if !lesson.keyPoints.isEmpty {
                        LessonSectionView(
                            id: "key-points",
                            title: "Ключевые моменты",
                            icon: "key.fill",
                            color: Color.starYellow
                        ) {
                            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                                ForEach(lesson.keyPoints) { keyPoint in
                                    KeyPointCard(keyPoint: keyPoint)
                                }
                            }
                        }
                    }

                    // Практические примеры
                    if !lesson.practicalExamples.isEmpty {
                        LessonSectionView(
                            id: "examples",
                            title: "Практические примеры",
                            icon: "lightbulb.fill",
                            color: Color.neonCyan
                        ) {
                            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                                ForEach(lesson.practicalExamples) { example in
                                    PracticalExampleCard(example: example)
                                }
                            }
                        }
                    }

                    // Квиз
                    if let quiz = lesson.quiz, !quiz.isCompleted {
                        LessonSectionView(
                            id: "quiz",
                            title: "Проверьте свои знания",
                            icon: "questionmark.circle.fill",
                            color: Color.neonPink
                        ) {
                            QuizSection(
                                quiz: quiz,
                                answers: $quizAnswers,
                                isCompleted: $quizCompleted
                            )
                        }
                    }

                    // Заключение
                    LessonSectionView(
                        id: "summary",
                        title: "Заключение",
                        icon: "checkmark.seal.fill",
                        color: Color.neonCyan
                    ) {
                        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                            Text(lesson.summary)
                                .font(CosmicTypography.body)
                                .foregroundColor(Color.starWhite.opacity(0.9))
                                .lineSpacing(4)

                            if !lesson.isCompleted {
                                completeButton
                            }
                        }
                    }

                    // Следующие уроки
                    if lesson.isCompleted {
                        nextLessonsSection
                    }

                    Spacer(minLength: CosmicSpacing.massive)
                }
                .padding(CosmicSpacing.medium)
                .onScrollTargetVisibilityChange(targetId: "introduction") { isVisible in
                    updateScrollProgress(0.1, isVisible: isVisible)
                }
                .onScrollTargetVisibilityChange(targetId: "key-points") { isVisible in
                    updateScrollProgress(0.3, isVisible: isVisible)
                }
                .onScrollTargetVisibilityChange(targetId: "examples") { isVisible in
                    updateScrollProgress(0.6, isVisible: isVisible)
                }
                .onScrollTargetVisibilityChange(targetId: "quiz") { isVisible in
                    updateScrollProgress(0.8, isVisible: isVisible)
                }
                .onScrollTargetVisibilityChange(targetId: "summary") { isVisible in
                    updateScrollProgress(1.0, isVisible: isVisible)
                }
            }
        }
    }

    // MARK: - Supporting Views
    private var categoryBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: lesson.category.icon)
                .font(.caption2)
            Text(lesson.category.rawValue)
                .font(.caption2)
        }
        .foregroundColor(lesson.category.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(lesson.category.color.opacity(0.2))
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
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
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
        .foregroundColor(Color.starWhite.opacity(0.7))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.starWhite.opacity(0.1))
        )
    }

    private var completedIcon: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(Color.starGreen)
            .font(.title3)
    }

    private var completeButton: some View {
        CosmicButton(
            title: "Завершить урок",
            icon: "checkmark.circle.fill",
            color: Color.starGreen
        ) {
            withAnimation {
                lessonService.completeLesson(lesson)
                dismiss()
            }
        }
    }

    private var nextLessonsSection: some View {
        LessonSectionView(
            id: "next-lessons",
            title: "Что изучать дальше",
            icon: "arrow.right.circle.fill",
            color: .cosmicViolet
        ) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                let recommendedLessons = lessonService.getRecommendedLessons()

                if recommendedLessons.isEmpty {
                    Text("Поздравляем! Вы изучили все доступные уроки.")
                        .font(CosmicTypography.body)
                        .foregroundColor(Color.starWhite.opacity(0.8))
                } else {
                    ForEach(recommendedLessons.prefix(3)) { nextLesson in
                        NextLessonCard(lesson: nextLesson)
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func updateScrollProgress(_ progress: Double, isVisible: Bool) {
        if isVisible {
            withAnimation(.easeInOut(duration: 0.3)) {
                scrollProgress = max(scrollProgress, progress)
            }
        }
    }

    private func updateLessonProgress() {
        lesson.updateProgress(scrollProgress)
    }
}

// MARK: - Section Views

struct LessonSectionView<Content: View>: View {
    let id: String
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        CosmicCard(glowColor: color.opacity(0.6)) {
            VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.title3)

                    Text(title)
                        .font(CosmicTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.starWhite)

                    Spacer()
                }

                content
            }
        }
        .id(id)
    }
}

struct KeyPointCard: View {
    let keyPoint: KeyPoint

    var body: some View {
        HStack(alignment: .top, spacing: CosmicSpacing.medium) {
            // Визуальный элемент
            if let visualExample = keyPoint.visualExample {
                Image(systemName: visualExample)
                    .font(.title2)
                    .foregroundColor(Color.starYellow)
                    .frame(width: 32, height: 32)
            }

            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                Text(keyPoint.title)
                    .font(CosmicTypography.headline)
                    .foregroundColor(Color.starWhite)

                Text(keyPoint.explanation)
                    .font(CosmicTypography.body)
                    .foregroundColor(Color.starWhite.opacity(0.8))
                    .lineSpacing(2)

                if !keyPoint.relatedTerms.isEmpty {
                    HStack {
                        Image(systemName: "link")
                            .font(.caption2)
                            .foregroundColor(Color.neonCyan)

                        Text("Связанные термины:")
                            .font(.caption)
                            .foregroundColor(Color.neonCyan)
                    }
                }
            }
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.starYellow.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.starYellow.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PracticalExampleCard: View {
    let example: PracticalExample

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(Color.neonCyan)
                    .font(.caption)

                Text("Пример")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.neonCyan)

                Spacer()
            }

            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                Text("Ситуация:")
                    .font(.caption)
                    .foregroundColor(Color.starWhite.opacity(0.7))
                    .fontWeight(.medium)

                Text(example.scenario)
                    .font(CosmicTypography.body)
                    .foregroundColor(Color.starWhite)

                Text("Интерпретация:")
                    .font(.caption)
                    .foregroundColor(Color.starWhite.opacity(0.7))
                    .fontWeight(.medium)
                    .padding(.top, CosmicSpacing.small)

                Text(example.interpretation)
                    .font(CosmicTypography.body)
                    .foregroundColor(Color.starWhite.opacity(0.9))
                    .italic()
            }
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.neonCyan.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neonCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct QuizSection: View {
    let quiz: Quiz
    @Binding var answers: [String: Int]
    @Binding var isCompleted: Bool
    @State private var showingResults = false

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.large) {
            ForEach(Array(quiz.questions.enumerated()), id: \.element.id) { index, question in
                QuizQuestionCard(
                    question: question,
                    questionNumber: index + 1,
                    selectedAnswer: answers[question.id],
                    showingResults: showingResults
                ) { answerIndex in
                    answers[question.id] = answerIndex
                }
            }

            if !isCompleted {
                quizSubmitButton
            }
        }
    }

    private var quizSubmitButton: some View {
        CosmicButton(
            title: "Проверить ответы",
            icon: "checkmark.circle.fill",
            color: Color.neonPink,
            action: {
                submitQuiz()
            }
        )
        .disabled(answers.count != quiz.questions.count)
    }

    private func submitQuiz() {
        let correctAnswers = quiz.questions.filter { question in
            answers[question.id] == question.correctAnswerIndex
        }

        let score = Double(correctAnswers.count) / Double(quiz.questions.count)

        withAnimation {
            showingResults = true
            isCompleted = true
            quiz.markAsCompleted(score: score)
        }
    }
}

struct QuizQuestionCard: View {
    let question: QuizQuestion
    let questionNumber: Int
    let selectedAnswer: Int?
    let showingResults: Bool
    let onAnswerSelected: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CosmicSpacing.medium) {
            // Заголовок вопроса
            HStack {
                Text("Вопрос \(questionNumber)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.neonPink)

                Spacer()

                if showingResults {
                    resultIcon
                }
            }

            Text(question.question)
                .font(CosmicTypography.body)
                .foregroundColor(Color.starWhite)
                .fontWeight(.medium)

            // Варианты ответов
            VStack(spacing: CosmicSpacing.small) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    QuizOptionButton(
                        option: option,
                        index: index,
                        isSelected: selectedAnswer == index,
                        isCorrect: index == question.correctAnswerIndex,
                        showingResults: showingResults
                    ) {
                        if !showingResults {
                            onAnswerSelected(index)
                        }
                    }
                }
            }

            // Объяснение (показывается после ответа)
            if showingResults {
                VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                    Text("Объяснение:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.starYellow)

                    Text(question.explanation)
                        .font(CosmicTypography.caption)
                        .foregroundColor(Color.starWhite.opacity(0.8))
                        .lineSpacing(2)
                }
                .padding(CosmicSpacing.small)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.starYellow.opacity(0.1))
                )
            }
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.neonPink.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.neonPink.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var resultIcon: some View {
        let isCorrect = selectedAnswer == question.correctAnswerIndex

        return Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
            .foregroundColor(isCorrect ? Color.starGreen : Color.neonPink)
            .font(.title3)
    }
}

struct QuizOptionButton: View {
    let option: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let showingResults: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: CosmicSpacing.medium) {
                // Буква варианта
                Text("\(Character(UnicodeScalar(65 + index)!))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(optionColor)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(optionColor.opacity(0.2))
                    )

                Text(option)
                    .font(CosmicTypography.body)
                    .foregroundColor(Color.starWhite)
                    .multilineTextAlignment(.leading)

                Spacer()

                if showingResults && isSelected {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? Color.starGreen : Color.neonPink)
                }
            }
            .padding(CosmicSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(showingResults)
    }

    private var optionColor: Color {
        if showingResults {
            if isCorrect {
                return Color.starGreen
            } else if isSelected {
                return Color.neonPink
            }
        }
        return isSelected ? Color.neonCyan : Color.starWhite.opacity(0.7)
    }

    private var backgroundColor: Color {
        if showingResults {
            if isCorrect {
                return Color.starGreen.opacity(0.1)
            } else if isSelected {
                return Color.neonPink.opacity(0.1)
            }
        }
        return isSelected ? Color.neonCyan.opacity(0.1) : Color.starWhite.opacity(0.05)
    }

    private var borderColor: Color {
        if showingResults {
            if isCorrect {
                return Color.starGreen
            } else if isSelected {
                return Color.neonPink
            }
        }
        return isSelected ? Color.neonCyan : Color.starWhite.opacity(0.2)
    }

    private var borderWidth: CGFloat {
        return (showingResults && (isCorrect || isSelected)) || (!showingResults && isSelected) ? 2 : 1
    }
}

struct NextLessonCard: View {
    let lesson: MiniLesson

    var body: some View {
        HStack(spacing: CosmicSpacing.medium) {
            Image(systemName: lesson.icon)
                .font(.title3)
                .foregroundColor(lesson.accentColor)
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(CosmicTypography.body)
                    .fontWeight(.medium)
                    .foregroundColor(Color.starWhite)
                    .lineLimit(1)

                HStack(spacing: CosmicSpacing.small) {
                    Text(lesson.difficulty.rawValue)
                        .font(.caption2)
                        .foregroundColor(lesson.difficulty.color)

                    Text("•")
                        .foregroundColor(Color.starWhite.opacity(0.5))

                    Text("\(lesson.estimatedReadingTime) мин")
                        .font(.caption2)
                        .foregroundColor(Color.starWhite.opacity(0.7))
                }
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(Color.starWhite.opacity(0.5))
        }
        .padding(CosmicSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lesson.accentColor.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

enum LessonSection: String, CaseIterable {
    case introduction = "Введение"
    case keyPoints = "Ключевые моменты"
    case examples = "Примеры"
    case quiz = "Квиз"
    case summary = "Заключение"
}

// MARK: - Extensions
extension View {
    func onScrollTargetVisibilityChange<ID: Hashable>(
        targetId: ID,
        action: @escaping (Bool) -> Void
    ) -> some View {
        // Заглушка для отслеживания видимости элементов при скроллинге
        // В реальной реализации здесь был бы более сложный механизм
        self.onAppear { action(true) }
    }
}

#Preview {
    let sampleLesson = MiniLesson(
        id: "sample",
        title: "Пример урока",
        category: .basics,
        duration: 180,
        level: .beginner,
        prerequisiteLessons: [],
        introduction: "Это пример урока для демонстрации.",
        keyPoints: [],
        practicalExamples: [],
        quiz: nil,
        summary: "Заключение урока.",
        tags: [],
        estimatedReadingTime: 3,
        difficulty: .easy,
        icon: "star.fill",
        accentColorName: "starYellow"
    )

    MiniLessonDetailView(lesson: sampleLesson, lessonService: MiniLessonService())
}