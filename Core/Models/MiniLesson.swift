//
//  MiniLesson.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Core/Models/MiniLesson.swift
import Foundation
import SwiftUI
import Combine

struct MiniLesson: Codable, Identifiable {
    let id: String
    let title: String
    let category: LessonCategory
    let duration: TimeInterval // в секундах
    let level: DisplayMode
    let prerequisiteLessons: [String]

    // Содержимое урока
    let introduction: String
    let keyPoints: [KeyPoint]
    let practicalExamples: [PracticalExample]
    let quiz: Quiz?
    let summary: String

    // Метаданные
    let tags: [String]
    let estimatedReadingTime: Int // в минутах
    let difficulty: DifficultyLevel
    let icon: String
    let accentColorName: String // Храним имя цвета, а не сам Color

    // Computed property для получения Color
    var accentColor: Color {
        switch accentColorName {
        case "starYellow": return .starYellow
        case "neonPink": return .neonPink
        case "cosmicViolet": return .cosmicViolet
        case "neonCyan": return .neonCyan
        case "starGreen": return .neonGreen
        case "fireElement": return .fireElement
        default: return .starWhite
        }
    }

    // Прогресс
    var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: "lesson_completed_\(id)")
    }

    var progress: Double {
        UserDefaults.standard.double(forKey: "lesson_progress_\(id)")
    }

    // Методы для работы с прогрессом
    func markAsCompleted() {
        UserDefaults.standard.set(true, forKey: "lesson_completed_\(id)")
        UserDefaults.standard.set(1.0, forKey: "lesson_progress_\(id)")
    }

    func updateProgress(_ progress: Double) {
        UserDefaults.standard.set(progress, forKey: "lesson_progress_\(id)")
    }
}

struct KeyPoint: Codable, Identifiable {
    let id: String
    let title: String
    let explanation: String
    let visualExample: String? // URL изображения или SF Symbol
    let relatedTerms: [String] // ID терминов из глоссария
}

struct PracticalExample: Codable, Identifiable {
    let id: String
    let scenario: String
    let explanation: String
    let chartElementsUsed: [String] // планеты, знаки и т.д.
    let interpretation: String
}

struct Quiz: Codable {
    let questions: [QuizQuestion]
    let passingScore: Double // от 0.0 до 1.0

    var isCompleted: Bool {
        UserDefaults.standard.bool(forKey: "quiz_completed_\(id)")
    }

    private var id: String {
        questions.map { $0.id }.joined(separator: "_")
    }

    func markAsCompleted(score: Double) {
        UserDefaults.standard.set(true, forKey: "quiz_completed_\(id)")
        UserDefaults.standard.set(score, forKey: "quiz_score_\(id)")
    }

    var bestScore: Double {
        UserDefaults.standard.double(forKey: "quiz_score_\(id)")
    }
}

struct QuizQuestion: Codable, Identifiable {
    let id: String
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let difficulty: DifficultyLevel
}

enum LessonCategory: String, CaseIterable, Codable {
    case basics = "Основы"
    case planets = "Планеты"
    case signs = "Знаки зодиака"
    case houses = "Астрологические дома"
    case aspects = "Аспекты"
    case interpretation = "Интерпретация"
    case advanced = "Продвинутые темы"

    var icon: String {
        switch self {
        case .basics: return "star.fill"
        case .planets: return "globe"
        case .signs: return "sparkles"
        case .houses: return "house.fill"
        case .aspects: return "arrow.triangle.merge"
        case .interpretation: return "brain.head.profile"
        case .advanced: return "wand.and.stars"
        }
    }

    var color: Color {
        switch self {
        case .basics: return .starYellow
        case .planets: return .cosmicViolet
        case .signs: return .neonCyan
        case .houses: return .cosmicBlue
        case .aspects: return .airElement
        case .interpretation: return .neonPink
        case .advanced: return .cosmicPurple
        }
    }

    var description: String {
        switch self {
        case .basics: return "Фундаментальные концепции астрологии"
        case .planets: return "Значение и влияние планет"
        case .signs: return "Характеристики знаков зодиака"
        case .houses: return "Сферы жизни в астрологии"
        case .aspects: return "Взаимодействие планет"
        case .interpretation: return "Как читать и понимать карты"
        case .advanced: return "Сложные техники и концепции"
        }
    }
}

enum DifficultyLevel: String, CaseIterable, Codable {
    case easy = "Легко"
    case medium = "Средне"
    case hard = "Сложно"

    var color: Color {
        switch self {
        case .easy: return .neonGreen
        case .medium: return .starYellow
        case .hard: return .neonPink
        }
    }

    var icon: String {
        switch self {
        case .easy: return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .hard: return "3.circle.fill"
        }
    }
}

class MiniLessonService: ObservableObject {
    @Published var allLessons: [MiniLesson] = []
    @Published var availableLessons: [MiniLesson] = []
    @Published var completedLessons: Set<String> = []
    @Published var currentDisplayMode: DisplayMode = .beginner

    init() {
        loadLessons()
        updateCompletedLessons()
    }

    private func loadLessons() {
        allLessons = createMiniLessons()
        updateAvailableLessons()
    }

    func updateDisplayMode(_ displayMode: DisplayMode) {
        currentDisplayMode = displayMode
        updateAvailableLessons()
    }

    private func updateAvailableLessons() {
        // Фильтруем уроки по уровню пользователя
        let filteredByLevel = allLessons.filter { lesson in
            switch currentDisplayMode {
            case .human:
                return lesson.level == .beginner  // Human mode shows beginner lessons
            case .beginner:
                return lesson.level == .beginner
            case .intermediate:
                return true
            }
        }

        // Проверяем prerequisites
        availableLessons = filteredByLevel.filter { lesson in
            lesson.prerequisiteLessons.allSatisfy { prerequisiteId in
                completedLessons.contains(prerequisiteId)
            } || lesson.prerequisiteLessons.isEmpty
        }
    }

    private func updateCompletedLessons() {
        completedLessons = Set(allLessons.filter { $0.isCompleted }.map { $0.id })
    }

    func completeLesson(_ lesson: MiniLesson) {
        lesson.markAsCompleted()
        completedLessons.insert(lesson.id)
        updateAvailableLessons()
    }

    func getLessonsByCategory() -> [LessonCategory: [MiniLesson]] {
        Dictionary(grouping: availableLessons) { $0.category }
    }

    func getRecommendedLessons() -> [MiniLesson] {
        return availableLessons
            .filter { !$0.isCompleted }
            .sorted { lesson1, lesson2 in
                // Сортируем по сложности и популярности
                if lesson1.difficulty != lesson2.difficulty {
                    return lesson1.difficulty.rawValue < lesson2.difficulty.rawValue
                }
                return lesson1.estimatedReadingTime < lesson2.estimatedReadingTime
            }
            .prefix(5)
            .map { $0 }
    }

    func getCompletionRate() -> Double {
        guard !allLessons.isEmpty else { return 0.0 }
        let availableCount = availableLessons.count
        let completedCount = availableLessons.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(availableCount)
    }

    func getNextLesson(after currentLesson: MiniLesson) -> MiniLesson? {
        // Находим следующий урок в той же категории или переходим к следующей
        let sameCategoryLessons = availableLessons
            .filter { $0.category == currentLesson.category && !$0.isCompleted }
            .sorted { $0.estimatedReadingTime < $1.estimatedReadingTime }

        return sameCategoryLessons.first ?? getRecommendedLessons().first
    }

    func searchLessons(query: String) -> [MiniLesson] {
        guard !query.isEmpty else { return availableLessons }

        let lowercasedQuery = query.lowercased()
        return availableLessons.filter { lesson in
            lesson.title.lowercased().contains(lowercasedQuery) ||
            lesson.tags.contains { $0.lowercased().contains(lowercasedQuery) } ||
            lesson.introduction.lowercased().contains(lowercasedQuery)
        }
    }
}

extension MiniLessonService {
    private func createMiniLessons() -> [MiniLesson] {
        return [
            // ОСНОВЫ АСТРОЛОГИИ
            MiniLesson(
                id: "basics_what_is_astrology",
                title: "Что такое астрология?",
                category: .basics,
                duration: 180, // 3 минуты
                level: .beginner,
                prerequisiteLessons: [],
                introduction: "Астрология — это древняя система знаний о влиянии небесных тел на человека и события на Земле. В этом уроке мы разберем основы этой удивительной науки.",
                keyPoints: [
                    KeyPoint(
                        id: "kp1",
                        title: "Астрология как символическая система",
                        explanation: "Астрология использует положение планет как символы, помогающие понять характер и потенциал человека",
                        visualExample: "star.circle.fill",
                        relatedTerms: ["birth_chart", "planets", "zodiac"]
                    ),
                    KeyPoint(
                        id: "kp2",
                        title: "Натальная карта — ваш космический паспорт",
                        explanation: "Карта рождения показывает положение всех планет на момент вашего появления на свет",
                        visualExample: "map.fill",
                        relatedTerms: ["birth_chart", "birth_time", "birth_place"]
                    )
                ],
                practicalExamples: [
                    PracticalExample(
                        id: "pe1",
                        scenario: "Человек родился 15 марта в 14:30",
                        explanation: "На этот момент Солнце находилось в знаке Рыб, что влияет на основные черты характера",
                        chartElementsUsed: ["Солнце", "Рыбы", "время рождения"],
                        interpretation: "Солнце в Рыбах дает чувствительность, интуицию и творческие способности"
                    )
                ],
                quiz: Quiz(
                    questions: [
                        QuizQuestion(
                            id: "q1",
                            question: "Что показывает натальная карта?",
                            options: [
                                "Только знак зодиака",
                                "Положение всех планет на момент рождения",
                                "Предсказание будущего",
                                "Только Солнце и Луну"
                            ],
                            correctAnswerIndex: 1,
                            explanation: "Натальная карта — это снимок неба в момент рождения, показывающий положение всех планет",
                            difficulty: .easy
                        )
                    ],
                    passingScore: 0.8
                ),
                summary: "Астрология — это символическая система для понимания характера и потенциала через положение планет в момент рождения",
                tags: ["основы", "начинающие", "натальная карта"],
                estimatedReadingTime: 3,
                difficulty: .easy,
                icon: "star.circle.fill",
                accentColorName: "starYellow"
            ),

            MiniLesson(
                id: "basics_big_three",
                title: "Большая тройка: Солнце, Луна и Асцендент",
                category: .basics,
                duration: 240, // 4 минуты
                level: .beginner,
                prerequisiteLessons: ["basics_what_is_astrology"],
                introduction: "Три самых важных элемента в вашей натальной карте: знак Солнца (личность), знак Луны (эмоции) и Асцендент (внешность). Эта тройка формирует основу вашего астрологического профиля.",
                keyPoints: [
                    KeyPoint(
                        id: "kp1",
                        title: "Солнце — ваше истинное Я",
                        explanation: "Знак Солнца показывает основные черты характера, жизненные цели и способ самовыражения",
                        visualExample: "sun.max.fill",
                        relatedTerms: ["sun", "ego", "personality"]
                    ),
                    KeyPoint(
                        id: "kp2",
                        title: "Луна — ваш внутренний мир",
                        explanation: "Знак Луны раскрывает эмоциональную природу, потребности и инстинкты",
                        visualExample: "moon.fill",
                        relatedTerms: ["moon", "emotions", "subconscious"]
                    ),
                    KeyPoint(
                        id: "kp3",
                        title: "Асцендент — ваша маска",
                        explanation: "Восходящий знак показывает, как вы представляете себя миру и первое впечатление",
                        visualExample: "person.fill",
                        relatedTerms: ["ascendant", "rising", "appearance"]
                    )
                ],
                practicalExamples: [
                    PracticalExample(
                        id: "pe1",
                        scenario: "Солнце в Льве, Луна в Раке, Асцендент в Весах",
                        explanation: "Это сочетание дает интересную личность",
                        chartElementsUsed: ["Солнце", "Луна", "Асцендент", "Лев", "Рак", "Весы"],
                        interpretation: "Гордая и творческая личность (Лев) с чувствительными эмоциями (Рак) и обаятельной внешностью (Весы)"
                    )
                ],
                quiz: Quiz(
                    questions: [
                        QuizQuestion(
                            id: "q1",
                            question: "За что отвечает знак Луны?",
                            options: [
                                "Внешность",
                                "Карьеру",
                                "Эмоции и внутренний мир",
                                "Отношения"
                            ],
                            correctAnswerIndex: 2,
                            explanation: "Луна управляет эмоциональной сферой, подсознанием и внутренними потребностями",
                            difficulty: .easy
                        ),
                        QuizQuestion(
                            id: "q2",
                            question: "Что такое Асцендент?",
                            options: [
                                "Знак Солнца",
                                "Восходящий знак, влияющий на внешность",
                                "Самая высокая планета",
                                "Знак партнера"
                            ],
                            correctAnswerIndex: 1,
                            explanation: "Асцендент — это знак, который восходил на восточном горизонте в момент рождения",
                            difficulty: .easy
                        )
                    ],
                    passingScore: 0.7
                ),
                summary: "Большая тройка (Солнце, Луна, Асцендент) формирует основу личности: кто вы есть, что чувствуете и как выглядите для других",
                tags: ["солнце", "луна", "асцендент", "большая тройка"],
                estimatedReadingTime: 4,
                difficulty: .easy,
                icon: "sun.max.fill",
                accentColorName: "starYellow"
            ),

            // ПЛАНЕТЫ
            MiniLesson(
                id: "planets_personal_planets",
                title: "Личные планеты: ваш внутренний мир",
                category: .planets,
                duration: 300, // 5 минут
                level: .beginner,
                prerequisiteLessons: ["basics_big_three"],
                introduction: "Личные планеты (Солнце, Луна, Меркурий, Венера, Марс) наиболее сильно влияют на повседневную жизнь и формируют основные черты характера.",
                keyPoints: [
                    KeyPoint(
                        id: "kp1",
                        title: "Меркурий — планета мышления",
                        explanation: "Управляет интеллектом, коммуникацией и способом обработки информации",
                        visualExample: "message.fill",
                        relatedTerms: ["mercury", "communication", "thinking"]
                    ),
                    KeyPoint(
                        id: "kp2",
                        title: "Венера — планета любви",
                        explanation: "Отвечает за отношения, красоту, ценности и то, что нас привлекает",
                        visualExample: "heart.fill",
                        relatedTerms: ["venus", "love", "beauty", "values"]
                    ),
                    KeyPoint(
                        id: "kp3",
                        title: "Марс — планета действий",
                        explanation: "Показывает, как мы действуем, проявляем энергию и достигаем целей",
                        visualExample: "bolt.fill",
                        relatedTerms: ["mars", "action", "energy", "drive"]
                    )
                ],
                practicalExamples: [
                    PracticalExample(
                        id: "pe1",
                        scenario: "Меркурий в Близнецах",
                        explanation: "Быстрое и разнообразное мышление",
                        chartElementsUsed: ["Меркурий", "Близнецы"],
                        interpretation: "Человек любознателен, быстро схватывает информацию, любит общение и может заниматься несколькими делами одновременно"
                    )
                ],
                quiz: Quiz(
                    questions: [
                        QuizQuestion(
                            id: "q1",
                            question: "За что отвечает Венера?",
                            options: [
                                "Карьеру и амбиции",
                                "Любовь, красоту и ценности",
                                "Мышление и коммуникацию",
                                "Энергию и действия"
                            ],
                            correctAnswerIndex: 1,
                            explanation: "Венера управляет сферой любви, отношений, эстетики и личных ценностей",
                            difficulty: .easy
                        )
                    ],
                    passingScore: 0.8
                ),
                summary: "Личные планеты формируют ваш уникальный способ мышления (Меркурий), любви (Венера) и действий (Марс)",
                tags: ["планеты", "меркурий", "венера", "марс", "личные планеты"],
                estimatedReadingTime: 5,
                difficulty: .easy,
                icon: "globe",
                accentColorName: "cosmicViolet"
            ),

            // ЗНАКИ ЗОДИАКА
            MiniLesson(
                id: "signs_fire_element",
                title: "Огненные знаки: энергия и энтузиазм",
                category: .signs,
                duration: 270, // 4.5 минуты
                level: .beginner,
                prerequisiteLessons: ["basics_what_is_astrology"],
                introduction: "Огненные знаки (Овен, Лев, Стрелец) несут энергию инициативы, творчества и вдохновения. Они активны, оптимистичны и всегда готовы к новым приключениям.",
                keyPoints: [
                    KeyPoint(
                        id: "kp1",
                        title: "Овен — пионер зодиака",
                        explanation: "Первый знак, символизирующий начало, инициативу и лидерство",
                        visualExample: "flame.fill",
                        relatedTerms: ["aries", "leadership", "initiative"]
                    ),
                    KeyPoint(
                        id: "kp2",
                        title: "Лев — царь зодиака",
                        explanation: "Творческая сила, благородство и желание быть в центре внимания",
                        visualExample: "crown.fill",
                        relatedTerms: ["leo", "creativity", "leadership"]
                    ),
                    KeyPoint(
                        id: "kp3",
                        title: "Стрелец — философ и путешественник",
                        explanation: "Стремление к знаниям, свободе и расширению горизонтов",
                        visualExample: "arrow.up.right",
                        relatedTerms: ["sagittarius", "philosophy", "travel"]
                    )
                ],
                practicalExamples: [
                    PracticalExample(
                        id: "pe1",
                        scenario: "Много планет в огненных знаках",
                        explanation: "Такой человек будет очень энергичным и активным",
                        chartElementsUsed: ["Огненные знаки", "Овен", "Лев", "Стрелец"],
                        interpretation: "Энтузиазм, оптимизм, склонность к лидерству, но может не хватать терпения"
                    )
                ],
                quiz: Quiz(
                    questions: [
                        QuizQuestion(
                            id: "q1",
                            question: "Какие знаки относятся к огненной стихии?",
                            options: [
                                "Телец, Дева, Козерог",
                                "Овен, Лев, Стрелец",
                                "Рак, Скорпион, Рыбы",
                                "Близнецы, Весы, Водолей"
                            ],
                            correctAnswerIndex: 1,
                            explanation: "Огненные знаки: Овен, Лев и Стрелец",
                            difficulty: .easy
                        )
                    ],
                    passingScore: 0.8
                ),
                summary: "Огненные знаки дают энергию, энтузиазм и стремление к действию, каждый по-своему: Овен инициирует, Лев творит, Стрелец исследует",
                tags: ["стихии", "огонь", "овен", "лев", "стрелец"],
                estimatedReadingTime: 5,
                difficulty: .easy,
                icon: "flame.fill",
                accentColorName: "fireElement"
            ),

            // ИНТЕРПРЕТАЦИЯ
            MiniLesson(
                id: "interpretation_reading_basics",
                title: "Как читать натальную карту: первые шаги",
                category: .interpretation,
                duration: 420, // 7 минут
                level: .intermediate,
                prerequisiteLessons: ["basics_big_three", "planets_personal_planets"],
                introduction: "Научиться читать натальную карту — это искусство соединения отдельных элементов в целостную картину личности. Начнем с основ.",
                keyPoints: [
                    KeyPoint(
                        id: "kp1",
                        title: "Начинайте с большой тройки",
                        explanation: "Солнце, Луна и Асцендент дают 70% информации о человеке",
                        visualExample: "3.circle.fill",
                        relatedTerms: ["sun", "moon", "ascendant"]
                    ),
                    KeyPoint(
                        id: "kp2",
                        title: "Ищите паттерны и повторения",
                        explanation: "Если несколько элементов указывают на одно качество, оно очень выражено",
                        visualExample: "repeat.circle.fill",
                        relatedTerms: ["patterns", "emphasis"]
                    ),
                    KeyPoint(
                        id: "kp3",
                        title: "Учитывайте контекст",
                        explanation: "Один элемент может проявляться по-разному в зависимости от других факторов",
                        visualExample: "context.menu",
                        relatedTerms: ["aspects", "house", "context"]
                    )
                ],
                practicalExamples: [
                    PracticalExample(
                        id: "pe1",
                        scenario: "Солнце и Марс в Овне, Асцендент в Овне",
                        explanation: "Тройное подчеркивание овновских качеств",
                        chartElementsUsed: ["Солнце", "Марс", "Асцендент", "Овен"],
                        interpretation: "Исключительно энергичная, импульсивная и лидерская личность. Овновские качества проявлены максимально"
                    )
                ],
                quiz: Quiz(
                    questions: [
                        QuizQuestion(
                            id: "q1",
                            question: "С чего лучше начинать чтение карты?",
                            options: [
                                "С самой сильной планеты",
                                "С большой тройки (Солнце, Луна, Асцендент)",
                                "С домов",
                                "С аспектов"
                            ],
                            correctAnswerIndex: 1,
                            explanation: "Большая тройка дает основную информацию о личности и является отправной точкой",
                            difficulty: .medium
                        )
                    ],
                    passingScore: 0.8
                ),
                summary: "Начинайте чтение с большой тройки, ищите повторяющиеся темы и всегда учитывайте общий контекст карты",
                tags: ["интерпретация", "чтение карты", "методы", "анализ"],
                estimatedReadingTime: 7,
                difficulty: .medium,
                icon: "brain.head.profile",
                accentColorName: "neonPink"
            )
        ]
    }
}