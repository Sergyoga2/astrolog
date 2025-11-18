//
//  AstrologyGlossary.swift
//  Astrolog
//
//  Created by Claude on 21.10.2025.
//

// Core/Models/AstrologyGlossary.swift
import Foundation
import SwiftUI
import Combine

struct GlossaryTerm: Codable, Identifiable, Hashable {
    let id: String
    let term: String
    let category: GlossaryCategory
    let definition: String
    let detailedExplanation: String
    let synonyms: [String]
    let relatedTerms: [String]
    let examples: [String]
    let level: DisplayMode
    let keywords: [String]
    let icon: String
}

enum GlossaryCategory: String, CaseIterable, Codable {
    case planets = "Планеты"
    case signs = "Знаки"
    case houses = "Дома"
    case aspects = "Аспекты"
    case elements = "Стихии"
    case modalities = "Качества"
    case points = "Точки"
    case techniques = "Техники"
    case general = "Общие"

    var icon: String {
        switch self {
        case .planets: return "globe"
        case .signs: return "star.circle"
        case .houses: return "house"
        case .aspects: return "arrow.triangle.merge"
        case .elements: return "flame"
        case .modalities: return "arrow.clockwise"
        case .points: return "location"
        case .techniques: return "wand.and.stars"
        case .general: return "book"
        }
    }

    var color: Color {
        switch self {
        case .planets: return .fireElement
        case .signs: return .neonCyan
        case .houses: return .earthElement
        case .aspects: return .airElement
        case .elements: return .waterElement
        case .modalities: return .cosmicViolet
        case .points: return .starYellow
        case .techniques: return .neonPink
        case .general: return .starWhite
        }
    }
}

class AstrologyGlossaryService: ObservableObject {
    @Published var allTerms: [GlossaryTerm] = []
    @Published var filteredTerms: [GlossaryTerm] = []
    @Published var searchQuery: String = "" {
        didSet {
            updateFilteredTerms()
        }
    }
    @Published var favoriteTerms: [GlossaryTerm] = []
    @Published var selectedCategory: GlossaryCategory? = nil {
        didSet {
            updateFilteredTerms()
        }
    }
    @Published var selectedLevel: DisplayMode = .beginner {
        didSet {
            updateFilteredTerms()
        }
    }

    init() {
        loadGlossaryData()
    }

    private func loadGlossaryData() {
        allTerms = createGlossaryTerms()
        updateFilteredTerms()
    }

    private func updateFilteredTerms() {
        var filtered = allTerms

        // Filter by search query
        if !searchQuery.isEmpty {
            filtered = filtered.filter { term in
                term.term.localizedCaseInsensitiveContains(searchQuery) ||
                term.definition.localizedCaseInsensitiveContains(searchQuery) ||
                term.keywords.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
            }
        }

        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        filtered = filtered.filter { term in
            switch selectedLevel {
            case .human:
                return term.level == .beginner // Human mode shows beginner terms
            case .beginner:
                return term.level == .beginner
            case .intermediate:
                return true
            }
        }

        filteredTerms = filtered.sorted { $0.term < $1.term }
    }

    func getFavoriteTerms() -> [GlossaryTerm] {
        return favoriteTerms
    }

    func termsByCategory() -> [GlossaryCategory: [GlossaryTerm]] {
        Dictionary(grouping: filteredTerms) { $0.category }
    }

    func getRelatedTerms(for termId: String) -> [GlossaryTerm] {
        guard let term = allTerms.first(where: { $0.id == termId }) else { return [] }

        return allTerms.filter { otherTerm in
            term.relatedTerms.contains(otherTerm.id) ||
            otherTerm.relatedTerms.contains(termId)
        }
    }

}

extension AstrologyGlossaryService {
    private func createGlossaryTerms() -> [GlossaryTerm] {
        return [
            // ПЛАНЕТЫ
            GlossaryTerm(
                id: "sun",
                term: "Солнце",
                category: .planets,
                definition: "Центральная звезда солнечной системы, в астрологии символизирует эго, индивидуальность и жизненную силу.",
                detailedExplanation: "Солнце представляет ваше истинное \"Я\", основные черты личности, способ самовыражения и жизненные цели. Это ядро вашей личности, то, кем вы являетесь в глубине души. Знак Солнца показывает основные качества характера и то, как вы проявляете себя в мире.",
                synonyms: ["Sol", "Дневное светило"],
                relatedTerms: ["moon", "ascendant", "ego"],
                examples: [
                    "Солнце в Овне придает энергичность и лидерские качества",
                    "Солнце в 10 доме указывает на карьерные амбиции"
                ],
                level: .beginner,
                keywords: ["эго", "личность", "индивидуальность", "самовыражение", "жизненная сила"],
                icon: "sun.max"
            ),

            GlossaryTerm(
                id: "moon",
                term: "Луна",
                category: .planets,
                definition: "Естественный спутник Земли, в астрологии символизирует эмоции, подсознание и внутренний мир.",
                detailedExplanation: "Луна отражает вашу эмоциональную природу, инстинкты, привычки и реакции на стресс. Она показывает, что вам нужно для эмоционального комфорта, как вы заботитесь о себе и других. Знак Луны раскрывает ваши глубинные потребности и способы получения эмоциональной безопасности.",
                synonyms: ["Luna", "Ночное светило"],
                relatedTerms: ["sun", "emotions", "subconscious"],
                examples: [
                    "Луна в Раке усиливает потребность в безопасности и семье",
                    "Луна в 4 доме подчеркивает важность дома и корней"
                ],
                level: .beginner,
                keywords: ["эмоции", "подсознание", "интуиция", "материнство", "привычки"],
                icon: "moon"
            ),

            GlossaryTerm(
                id: "mercury",
                term: "Меркурий",
                category: .planets,
                definition: "Планета мышления, коммуникации и обмена информацией.",
                detailedExplanation: "Меркурий управляет интеллектом, способностью к обучению, речью, письмом и всеми формами коммуникации. Он показывает, как вы думаете, обрабатываете информацию и выражаете свои мысли. Также отвечает за торговлю, путешествия и адаптацию.",
                synonyms: ["Гермес"],
                relatedTerms: ["communication", "intelligence", "learning"],
                examples: [
                    "Меркурий в Близнецах дает быстрое мышление и любознательность",
                    "Ретроградный Меркурий может создавать проблемы в коммуникации"
                ],
                level: .beginner,
                keywords: ["мышление", "речь", "коммуникация", "обучение", "интеллект"],
                icon: "message"
            ),

            // ЗНАКИ ЗОДИАКА
            GlossaryTerm(
                id: "aries",
                term: "Овен",
                category: .signs,
                definition: "Первый знак зодиака, кардинальный огненный знак, управляемый Марсом.",
                detailedExplanation: "Овен символизирует начало, инициативу и пионерский дух. Люди с планетами в Овне обычно энергичны, импульсивны, независимы и готовы к действию. Этот знак дает лидерские качества, смелость и желание быть первым во всем.",
                synonyms: ["Aries"],
                relatedTerms: ["mars", "fire_element", "cardinal"],
                examples: [
                    "Солнце в Овне - прирожденный лидер",
                    "Луна в Овне - эмоциональные всплески и быстрые реакции"
                ],
                level: .beginner,
                keywords: ["энергия", "инициатива", "лидерство", "импульсивность", "начало"],
                icon: "flame"
            ),

            // ДОМА
            GlossaryTerm(
                id: "first_house",
                term: "Первый дом",
                category: .houses,
                definition: "Дом личности, самовыражения и внешности. Начинается с Асцендента.",
                detailedExplanation: "Первый дом показывает, как вы представляете себя миру, ваш внешний вид, манеру поведения и первое впечатление, которое вы производите. Планеты в этом доме сильно влияют на личность и способ самовыражения.",
                synonyms: ["Дом Асцендента", "Дом личности"],
                relatedTerms: ["ascendant", "personality", "appearance"],
                examples: [
                    "Марс в 1 доме дает энергичный и напористый вид",
                    "Венера в 1 доме придает привлекательность и обаяние"
                ],
                level: .beginner,
                keywords: ["личность", "внешность", "самовыражение", "первое впечатление"],
                icon: "person"
            ),

            // АСПЕКТЫ
            GlossaryTerm(
                id: "conjunction",
                term: "Соединение",
                category: .aspects,
                definition: "Аспект 0°, самый сильный аспект, когда планеты находятся очень близко друг к другу.",
                detailedExplanation: "Соединение объединяет энергии планет, создавая мощное влияние. Планеты в соединении работают как одна сила, усиливая друг друга. Это может быть как гармонично, так и напряженно, в зависимости от природы планет.",
                synonyms: ["Конъюнкция"],
                relatedTerms: ["orb", "aspects", "planets"],
                examples: [
                    "Солнце соединение Меркурий дает ментальную энергию",
                    "Марс соединение Сатурн может создавать фрустрацию или дисциплину"
                ],
                level: .beginner,
                keywords: ["соединение", "усиление", "единство", "сила"],
                icon: "circle.circle"
            ),

            // СТИХИИ
            GlossaryTerm(
                id: "fire_element",
                term: "Огонь",
                category: .elements,
                definition: "Одна из четырех стихий, включающая Овна, Льва и Стрельца.",
                detailedExplanation: "Огненная стихия дает энтузиазм, энергию, спонтанность и творческую силу. Огненные знаки активны, оптимистичны, любят действовать и вдохновлять других. Они интуитивны и ориентированы на будущее.",
                synonyms: ["Огненная стихия"],
                relatedTerms: ["aries", "leo", "sagittarius", "elements"],
                examples: [
                    "Много планет в огненных знаках дает энергичную натуру",
                    "Недостаток огня может указывать на пассивность"
                ],
                level: .beginner,
                keywords: ["энергия", "энтузиазм", "действие", "творчество", "спонтанность"],
                icon: "flame.fill"
            ),

            // ТОЧКИ
            GlossaryTerm(
                id: "ascendant",
                term: "Асцендент",
                category: .points,
                definition: "Восходящий знак, куспид первого дома, один из важнейших элементов карты.",
                detailedExplanation: "Асцендент показывает, как вы представляете себя миру, ваша маска или внешняя личность. Это то, как вас воспринимают при первой встрече, ваш стиль поведения и подход к жизни. Асцендент также влияет на физическую внешность.",
                synonyms: ["ASC", "Восходящий знак", "Rising"],
                relatedTerms: ["first_house", "personality", "appearance"],
                examples: [
                    "Асцендент в Льве придает царственную осанку",
                    "Асцендент в Рыбах дает мягкие черты и мечтательный взгляд"
                ],
                level: .beginner,
                keywords: ["внешность", "первое впечатление", "маска", "подход к жизни"],
                icon: "arrow.up.circle"
            ),

            // ТЕХНИКИ (более продвинутые термины)
            GlossaryTerm(
                id: "retrograde",
                term: "Ретроградность",
                category: .techniques,
                definition: "Кажущееся обратное движение планеты с точки зрения Земли.",
                detailedExplanation: "Ретроградная планета в карте рождения указывает на необходимость переосмысления и внутренней работы с энергией этой планеты. Такие планеты работают более интроспективно, их влияние направлено внутрь. Это не негативный фактор, а особый способ проявления планетарной энергии.",
                synonyms: ["Попятное движение", "R"],
                relatedTerms: ["planets", "motion", "introspection"],
                examples: [
                    "Ретроградный Меркурий может указывать на особый стиль мышления",
                    "Ретроградная Венера - переосмысление ценностей и отношений"
                ],
                level: .intermediate,
                keywords: ["обратное движение", "интроспекция", "переосмысление"],
                icon: "arrow.counterclockwise"
            ),

            // Добавляем больше терминов для каждой категории...
            GlossaryTerm(
                id: "midheaven",
                term: "Середина неба",
                category: .points,
                definition: "MC (Medium Coeli) - точка зенита, куспид 10-го дома, показывающая карьеру и призвание.",
                detailedExplanation: "Середина неба представляет ваши карьерные амбиции, общественное положение, репутацию и жизненное призвание. Это то, к чему вы стремитесь в профессиональной сфере и как хотите, чтобы вас помнили.",
                synonyms: ["MC", "Medium Coeli", "Зенит"],
                relatedTerms: ["tenth_house", "career", "reputation"],
                examples: [
                    "MC во Льве указывает на потребность в признании и творческой карьере",
                    "MC в Козероге - стремление к авторитету и структурированной карьере"
                ],
                level: .intermediate,
                keywords: ["карьера", "призвание", "репутация", "статус"],
                icon: "crown"
            )
        ]
    }
}