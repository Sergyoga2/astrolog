//
//  EmotionalAstrologyDatabase.swift
//  Astrolog
//
//  Created by Claude on 26.10.2025.
//

// Core/Services/EmotionalAstrologyDatabase.swift
import Foundation
import SwiftUI

/// База данных эмоциональных соответствий для астрологических факторов
class EmotionalAstrologyDatabase {

    static let shared = EmotionalAstrologyDatabase()

    // MARK: - Planetary Emotions

    func getPlanetaryEmotion(_ planet: PlanetType) -> PlanetaryEmotion {
        switch planet {
        case .sun:
            return PlanetaryEmotion(
                archetype: "Герой",
                essence: "самоутверждение и витальность",
                core: CoreEmotion(
                    name: "Уверенность",
                    simpleDescription: "чувство силы и способности светить",
                    complexDescription: "архетипическая солнечная витальность как основа эго-сознания",
                    intensity: 0.8,
                    stability: 0.7
                ),
                baseIntensity: 0.8,
                keywords: ["сияние", "уверенность", "творчество", "лидерство"],
                needs: [
                    EmotionalNeed(
                        category: .recognition,
                        description: "Потребность быть увиденным и признанным",
                        humanAdvice: "позвольте себе сиять и получать признание",
                        technicalAdvice: "активируйте солярную функцию через творческое самовыражение",
                        practicalAction: "займитесь деятельностью, где вы можете проявить лидерство",
                        expectedBenefit: "усиление уверенности в себе",
                        priority: 5
                    )
                ],
                transformationCapacity: 0.9
            )

        case .moon:
            return PlanetaryEmotion(
                archetype: "Мать",
                essence: "забота и эмоциональная безопасность",
                core: CoreEmotion(
                    name: "Забота",
                    simpleDescription: "потребность в эмоциональной связи и безопасности",
                    complexDescription: "архетипическая лунная рецептивность как основа эмоциональной жизни",
                    intensity: 0.9,
                    stability: 0.4
                ),
                baseIntensity: 0.9,
                keywords: ["забота", "интуиция", "защита", "цикличность"],
                needs: [
                    EmotionalNeed(
                        category: .safety,
                        description: "Потребность в эмоциональной безопасности",
                        humanAdvice: "создайте для себя уютное пространство безопасности",
                        technicalAdvice: "стабилизируйте лунную функцию через регулярные ритуалы заботы",
                        practicalAction: "установите успокаивающие ритуалы",
                        expectedBenefit: "эмоциональная стабильность",
                        priority: 5
                    )
                ],
                transformationCapacity: 0.7
            )

        case .mercury:
            return PlanetaryEmotion(
                archetype: "Посланник",
                essence: "любознательность и обмен информацией",
                core: CoreEmotion(
                    name: "Любознательность",
                    simpleDescription: "потребность понимать и делиться мыслями",
                    complexDescription: "ментальная подвижность как основа коммуникативной функции",
                    intensity: 0.6,
                    stability: 0.3
                ),
                baseIntensity: 0.6,
                keywords: ["общение", "изучение", "адаптация", "связь"],
                needs: [
                    EmotionalNeed(
                        category: .understanding,
                        description: "Потребность в интеллектуальной стимуляции",
                        humanAdvice: "изучайте новое и делитесь знаниями",
                        technicalAdvice: "активируйте меркуриальную функцию через обучение",
                        practicalAction: "читайте, изучайте, общайтесь",
                        expectedBenefit: "ментальная ясность",
                        priority: 4
                    )
                ],
                transformationCapacity: 0.6
            )

        case .venus:
            return PlanetaryEmotion(
                archetype: "Возлюбленная",
                essence: "любовь и эстетическая гармония",
                core: CoreEmotion(
                    name: "Любовь",
                    simpleDescription: "потребность в красоте и гармоничных отношениях",
                    complexDescription: "венерианская эстетическая функция как основа ценностей",
                    intensity: 0.7,
                    stability: 0.6
                ),
                baseIntensity: 0.7,
                keywords: ["любовь", "красота", "гармония", "притяжение"],
                needs: [
                    EmotionalNeed(
                        category: .love,
                        description: "Потребность любить и быть любимым",
                        humanAdvice: "окружите себя красотой и любящими людьми",
                        technicalAdvice: "развивайте венерианскую функцию через эстетический опыт",
                        practicalAction: "занимайтесь искусством или украшайте пространство",
                        expectedBenefit: "эмоциональная удовлетворенность",
                        priority: 4
                    )
                ],
                transformationCapacity: 0.5
            )

        case .mars:
            return PlanetaryEmotion(
                archetype: "Воин",
                essence: "действие и утверждение воли",
                core: CoreEmotion(
                    name: "Страсть",
                    simpleDescription: "желание действовать и добиваться целей",
                    complexDescription: "марсианская волевая функция как драйв к действию",
                    intensity: 0.9,
                    stability: 0.5
                ),
                baseIntensity: 0.8,
                keywords: ["действие", "страсть", "конкуренция", "смелость"],
                needs: [
                    EmotionalNeed(
                        category: .action,
                        description: "Потребность в физической и эмоциональной разрядке",
                        humanAdvice: "найдите здоровые способы выражения своей энергии",
                        technicalAdvice: "направляйте марсианскую энергию конструктивно",
                        practicalAction: "занимайтесь спортом или активными проектами",
                        expectedBenefit: "снятие напряжения и достижение целей",
                        priority: 4
                    )
                ],
                transformationCapacity: 0.8
            )

        case .jupiter:
            return PlanetaryEmotion(
                archetype: "Мудрец",
                essence: "расширение и поиск смысла",
                core: CoreEmotion(
                    name: "Оптимизм",
                    simpleDescription: "вера в лучшее и стремление к росту",
                    complexDescription: "юпитерианская экспансивность как поиск высшего смысла",
                    intensity: 0.6,
                    stability: 0.8
                ),
                baseIntensity: 0.6,
                keywords: ["мудрость", "расширение", "оптимизм", "щедрость"],
                needs: [
                    EmotionalNeed(
                        category: .growth,
                        description: "Потребность в личностном и духовном росте",
                        humanAdvice: "стремитесь к новым горизонтам и опыту",
                        technicalAdvice: "развивайте юпитерианскую функцию через философское осмысление",
                        practicalAction: "путешествуйте, изучайте философию или религию",
                        expectedBenefit: "расширение сознания",
                        priority: 3
                    )
                ],
                transformationCapacity: 0.7
            )

        case .saturn:
            return PlanetaryEmotion(
                archetype: "Учитель",
                essence: "структура и ответственность",
                core: CoreEmotion(
                    name: "Ответственность",
                    simpleDescription: "потребность в порядке и достижениях",
                    complexDescription: "сатурнианская структурирующая функция как основа дисциплины",
                    intensity: 0.5,
                    stability: 0.9
                ),
                baseIntensity: 0.5,
                keywords: ["дисциплина", "структура", "достижение", "мудрость"],
                needs: [
                    EmotionalNeed(
                        category: .structure,
                        description: "Потребность в четких границах и достижениях",
                        humanAdvice: "создайте четкую структуру в своей жизни",
                        technicalAdvice: "укрепляйте сатурнианскую функцию через дисциплину",
                        practicalAction: "установите четкие цели и работайте над их достижением",
                        expectedBenefit: "чувство выполненного долга",
                        priority: 3
                    )
                ],
                transformationCapacity: 0.9
            )

        case .uranus:
            return PlanetaryEmotion(
                archetype: "Революционер",
                essence: "свобода и инновации",
                core: CoreEmotion(
                    name: "Свобода",
                    simpleDescription: "потребность в независимости и оригинальности",
                    complexDescription: "уранианская революционная функция как стремление к аутентичности",
                    intensity: 0.8,
                    stability: 0.2
                ),
                baseIntensity: 0.7,
                keywords: ["свобода", "инновации", "независимость", "оригинальность"],
                needs: [
                    EmotionalNeed(
                        category: .freedom,
                        description: "Потребность в индивидуальном самовыражении",
                        humanAdvice: "позвольте себе быть уникальным и непредсказуемым",
                        technicalAdvice: "интегрируйте уранианскую функцию через творческие эксперименты",
                        practicalAction: "экспериментируйте с новыми идеями и подходами",
                        expectedBenefit: "ощущение аутентичности",
                        priority: 3
                    )
                ],
                transformationCapacity: 0.9
            )

        case .neptune:
            return PlanetaryEmotion(
                archetype: "Мистик",
                essence: "растворение и духовное единство",
                core: CoreEmotion(
                    name: "Сострадание",
                    simpleDescription: "потребность в духовной связи и сочувствии",
                    complexDescription: "нептунианская растворяющая функция как путь к единству",
                    intensity: 0.6,
                    stability: 0.3
                ),
                baseIntensity: 0.6,
                keywords: ["сострадание", "интуиция", "мечты", "растворение"],
                needs: [
                    EmotionalNeed(
                        category: .transcendence,
                        description: "Потребность в духовном переживании и единстве",
                        humanAdvice: "найдите время для медитации и духовных практик",
                        technicalAdvice: "развивайте нептунианскую чувствительность осознанно",
                        practicalAction: "медитируйте, занимайтесь искусством или помогайте другим",
                        expectedBenefit: "духовное удовлетворение",
                        priority: 2
                    )
                ],
                transformationCapacity: 0.8
            )

        case .pluto:
            return PlanetaryEmotion(
                archetype: "Трансформатор",
                essence: "смерть и возрождение",
                core: CoreEmotion(
                    name: "Интенсивность",
                    simpleDescription: "потребность в глубоких изменениях и власти",
                    complexDescription: "плутонианская трансформирующая функция как алхимический процесс",
                    intensity: 1.0,
                    stability: 0.6
                ),
                baseIntensity: 0.9,
                keywords: ["трансформация", "власть", "глубина", "регенерация"],
                needs: [
                    EmotionalNeed(
                        category: .transformation,
                        description: "Потребность в глубинных изменениях и обновлении",
                        humanAdvice: "принимайте изменения как возможность обновления",
                        technicalAdvice: "работайте с плутонианскими энергиями через психотерапию",
                        practicalAction: "исследуйте свои глубинные мотивы и страхи",
                        expectedBenefit: "личностная трансформация",
                        priority: 2
                    )
                ],
                transformationCapacity: 1.0
            )
        case .ascendant:
            return PlanetaryEmotion(
                archetype: "Маска",
                essence: "внешний образ и самопрезентация",
                core: CoreEmotion(
                    name: "Адаптация",
                    simpleDescription: "способность приспосабливаться к миру",
                    complexDescription: "восходящий знак как внешняя личность",
                    intensity: 0.6,
                    stability: 0.7
                ),
                baseIntensity: 0.6,
                keywords: ["образ", "внешность", "адаптация"],
                needs: [],
                transformationCapacity: 0.5
            )
        case .midheaven:
            return PlanetaryEmotion(
                archetype: "Цель",
                essence: "жизненные амбиции и призвание",
                core: CoreEmotion(
                    name: "Амбиция",
                    simpleDescription: "стремление к достижениям",
                    complexDescription: "кульминационная точка как социальный статус",
                    intensity: 0.7,
                    stability: 0.8
                ),
                baseIntensity: 0.7,
                keywords: ["карьера", "цель", "призвание"],
                needs: [],
                transformationCapacity: 0.6
            )
        case .northNode:
            return PlanetaryEmotion(
                archetype: "Эволюция",
                essence: "духовное предназначение и рост",
                core: CoreEmotion(
                    name: "Предназначение",
                    simpleDescription: "ощущение жизненного пути",
                    complexDescription: "кармический путь развития души",
                    intensity: 0.8,
                    stability: 0.6
                ),
                baseIntensity: 0.8,
                keywords: ["предназначение", "эволюция", "карма"],
                needs: [],
                transformationCapacity: 0.9
            )
        }
    }

    // MARK: - Sign Emotional Expressions

    func getSignEmotionalExpression(_ sign: ZodiacSign) -> SignEmotionalExpression {
        switch sign {
        case .aries:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Огненный пионер",
                    spontaneity: 0.9,
                    intensity: 0.8,
                    duration: 0.3,
                    psychologicalMechanism: "импульсивная экспрессия"
                ),
                core: CoreEmotion(
                    name: "Энтузиазм",
                    simpleDescription: "вспыхивающее воодушевление",
                    complexDescription: "кардинальная огненная инициатива",
                    intensity: 0.9,
                    stability: 0.3
                ),
                needs: [
                    EmotionalNeed(
                        category: .action,
                        description: "Немедленное выражение импульсов",
                        humanAdvice: "действуйте по первому побуждению, но научитесь паузе",
                        technicalAdvice: "интегрируйте арианскую импульсивность через осознанность",
                        practicalAction: "начинайте новые проекты",
                        expectedBenefit: "чувство движения вперед",
                        priority: 5
                    )
                ]
            )

        case .taurus:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Земная стабильность",
                    spontaneity: 0.2,
                    intensity: 0.6,
                    duration: 0.9,
                    psychologicalMechanism: "медленная глубокая интеграция"
                ),
                core: CoreEmotion(
                    name: "Устойчивость",
                    simpleDescription: "глубокие, долгие чувства",
                    complexDescription: "фиксированная земная устойчивость",
                    intensity: 0.6,
                    stability: 0.9
                ),
                needs: [
                    EmotionalNeed(
                        category: .comfort,
                        description: "Физический и эмоциональный комфорт",
                        humanAdvice: "создавайте красивую, уютную обстановку",
                        technicalAdvice: "стабилизируйте тельцовскую потребность в красоте",
                        practicalAction: "наслаждайтесь чувственными удовольствиями",
                        expectedBenefit: "глубокое удовлетворение",
                        priority: 4
                    )
                ]
            )

        case .gemini:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Воздушная подвижность",
                    spontaneity: 0.8,
                    intensity: 0.5,
                    duration: 0.2,
                    psychologicalMechanism: "интеллектуальная обработка эмоций"
                ),
                core: CoreEmotion(
                    name: "Любопытство",
                    simpleDescription: "быстро меняющиеся интересы",
                    complexDescription: "мутабельная воздушная коммуникативность",
                    intensity: 0.5,
                    stability: 0.2
                ),
                needs: [
                    EmotionalNeed(
                        category: .variety,
                        description: "Интеллектуальная стимуляция и разнообразие",
                        humanAdvice: "общайтесь, изучайте новое, меняйте обстановку",
                        technicalAdvice: "удовлетворяйте близнецовскую потребность в информации",
                        practicalAction: "читайте, говорите, путешествуйте",
                        expectedBenefit: "ментальная свежесть",
                        priority: 4
                    )
                ]
            )

        case .cancer:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Водная забота",
                    spontaneity: 0.4,
                    intensity: 0.8,
                    duration: 0.7,
                    psychologicalMechanism: "эмоциональная защитность"
                ),
                core: CoreEmotion(
                    name: "Нежность",
                    simpleDescription: "заботливые, защитные чувства",
                    complexDescription: "кардинальная водная материнская забота",
                    intensity: 0.8,
                    stability: 0.6
                ),
                needs: [
                    EmotionalNeed(
                        category: .nurturing,
                        description: "Забота о близких и получение заботы",
                        humanAdvice: "создайте эмоционально безопасное пространство",
                        technicalAdvice: "развивайте раковую эмпатию осознанно",
                        practicalAction: "заботьтесь о семье и доме",
                        expectedBenefit: "эмоциональная наполненность",
                        priority: 5
                    )
                ]
            )

        case .leo:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Огненная драматичность",
                    spontaneity: 0.7,
                    intensity: 0.9,
                    duration: 0.6,
                    psychologicalMechanism: "театральное самовыражение"
                ),
                core: CoreEmotion(
                    name: "Гордость",
                    simpleDescription: "яркие, драматичные переживания",
                    complexDescription: "фиксированная огненная креативность",
                    intensity: 0.9,
                    stability: 0.6
                ),
                needs: [
                    EmotionalNeed(
                        category: .appreciation,
                        description: "Признание и восхищение",
                        humanAdvice: "позвольте себе сиять и принимайте комплименты",
                        technicalAdvice: "реализуйте львиную потребность в самовыражении",
                        practicalAction: "творите, выступайте, вдохновляйте других",
                        expectedBenefit: "ощущение собственной значимости",
                        priority: 4
                    )
                ]
            )

        case .virgo:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Земная аналитичность",
                    spontaneity: 0.3,
                    intensity: 0.4,
                    duration: 0.8,
                    psychologicalMechanism: "критический анализ чувств"
                ),
                core: CoreEmotion(
                    name: "Служение",
                    simpleDescription: "сдержанные, аналитичные чувства",
                    complexDescription: "мутабельная земная перфекционистская служба",
                    intensity: 0.4,
                    stability: 0.8
                ),
                needs: [
                    EmotionalNeed(
                        category: .usefulness,
                        description: "Быть полезным и совершенствоваться",
                        humanAdvice: "находите способы помогать и улучшать",
                        technicalAdvice: "реализуйте девственную потребность в совершенстве",
                        practicalAction: "организуйте, анализируйте, помогайте",
                        expectedBenefit: "чувство собственной полезности",
                        priority: 3
                    )
                ]
            )

        case .libra:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Воздушная гармония",
                    spontaneity: 0.5,
                    intensity: 0.5,
                    duration: 0.6,
                    psychologicalMechanism: "поиск эмоционального баланса"
                ),
                core: CoreEmotion(
                    name: "Гармония",
                    simpleDescription: "сбалансированные, эстетичные чувства",
                    complexDescription: "кардинальная воздушная дипломатическая справедливость",
                    intensity: 0.5,
                    stability: 0.6
                ),
                needs: [
                    EmotionalNeed(
                        category: .harmony,
                        description: "Красота, справедливость и партнерство",
                        humanAdvice: "стремитесь к справедливости и красоте в отношениях",
                        technicalAdvice: "балансируйте весовскую потребность в гармонии",
                        practicalAction: "создавайте красоту, медиируйте конфликты",
                        expectedBenefit: "эмоциональное равновесие",
                        priority: 4
                    )
                ]
            )

        case .scorpio:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Водная интенсивность",
                    spontaneity: 0.3,
                    intensity: 1.0,
                    duration: 0.9,
                    psychologicalMechanism: "глубинная трансформация"
                ),
                core: CoreEmotion(
                    name: "Страсть",
                    simpleDescription: "глубокие, трансформирующие чувства",
                    complexDescription: "фиксированная водная плутонианская интенсивность",
                    intensity: 1.0,
                    stability: 0.8
                ),
                needs: [
                    EmotionalNeed(
                        category: .depth,
                        description: "Глубокие, подлинные переживания",
                        humanAdvice: "не бойтесь глубины своих чувств",
                        technicalAdvice: "интегрируйте скорпионовскую интенсивность безопасно",
                        practicalAction: "исследуйте психологию, занимайтесь трансформационной работой",
                        expectedBenefit: "глубинное обновление",
                        priority: 5
                    )
                ]
            )

        case .sagittarius:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Огненное расширение",
                    spontaneity: 0.8,
                    intensity: 0.7,
                    duration: 0.4,
                    psychologicalMechanism: "философская интеграция опыта"
                ),
                core: CoreEmotion(
                    name: "Вдохновение",
                    simpleDescription: "оптимистичные, расширяющие чувства",
                    complexDescription: "мутабельная огненная юпитерианская экспансия",
                    intensity: 0.7,
                    stability: 0.4
                ),
                needs: [
                    EmotionalNeed(
                        category: .adventure,
                        description: "Свобода, приключения и смысл",
                        humanAdvice: "исследуйте мир и ищите смысл в опыте",
                        technicalAdvice: "удовлетворяйте стрельцовскую потребность в расширении",
                        practicalAction: "путешествуйте, изучайте философию, преподавайте",
                        expectedBenefit: "расширение горизонтов",
                        priority: 3
                    )
                ]
            )

        case .capricorn:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Земная целеустремленность",
                    spontaneity: 0.2,
                    intensity: 0.5,
                    duration: 0.9,
                    psychologicalMechanism: "структурирование эмоций под цели"
                ),
                core: CoreEmotion(
                    name: "Достижение",
                    simpleDescription: "сдержанные, целеустремленные чувства",
                    complexDescription: "кардинальная земная сатурнианская структура",
                    intensity: 0.5,
                    stability: 0.9
                ),
                needs: [
                    EmotionalNeed(
                        category: .accomplishment,
                        description: "Достижения и признание авторитета",
                        humanAdvice: "ставьте реальные цели и работайте над их достижением",
                        technicalAdvice: "структурируйте козероговскую амбициозность",
                        practicalAction: "стройте карьеру, развивайте мастерство",
                        expectedBenefit: "чувство достижения",
                        priority: 4
                    )
                ]
            )

        case .aquarius:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Воздушная оригинальность",
                    spontaneity: 0.6,
                    intensity: 0.6,
                    duration: 0.5,
                    psychologicalMechanism: "интеллектуальное отстранение"
                ),
                core: CoreEmotion(
                    name: "Независимость",
                    simpleDescription: "отстраненные, гуманистичные чувства",
                    complexDescription: "фиксированная воздушная уранианская инновация",
                    intensity: 0.6,
                    stability: 0.5
                ),
                needs: [
                    EmotionalNeed(
                        category: .uniqueness,
                        description: "Индивидуальность и социальные идеалы",
                        humanAdvice: "будьте верны своей уникальности",
                        technicalAdvice: "интегрируйте водолейскую эксцентричность социально",
                        practicalAction: "участвуйте в групповых проектах, изобретайте",
                        expectedBenefit: "чувство аутентичности",
                        priority: 3
                    )
                ]
            )

        case .pisces:
            return SignEmotionalExpression(
                style: EmotionalExpressionStyle(
                    name: "Водная растворимость",
                    spontaneity: 0.7,
                    intensity: 0.8,
                    duration: 0.6,
                    psychologicalMechanism: "интуитивное слияние"
                ),
                core: CoreEmotion(
                    name: "Сострадание",
                    simpleDescription: "текучие, сочувствующие чувства",
                    complexDescription: "мутабельная водная нептунианская жертвенность",
                    intensity: 0.8,
                    stability: 0.3
                ),
                needs: [
                    EmotionalNeed(
                        category: .connection,
                        description: "Духовная связь и помощь другим",
                        humanAdvice: "доверяйте своей интуиции и помогайте нуждающимся",
                        technicalAdvice: "структурируйте рыбью чувствительность",
                        practicalAction: "медитируйте, занимайтесь искусством, помогайте",
                        expectedBenefit: "духовное удовлетворение",
                        priority: 4
                    )
                ]
            )
        }
    }

    // MARK: - Additional Methods

    func getPlanetTriggers(_ planet: PlanetType) -> [EmotionalTrigger] {
        // Возвращает эмоциональные триггеры для планеты
        return []
    }

    func getSignTriggers(_ sign: ZodiacSign) -> [EmotionalTrigger] {
        // Возвращает эмоциональные триггеры для знака
        return []
    }

    func getPlanetHealing(_ planet: PlanetType) -> HealingApproach {
        // Возвращает подходы к исцелению для планеты
        return HealingApproach.default
    }

    func getSignHealing(_ sign: ZodiacSign) -> HealingApproach {
        // Возвращает подходы к исцелению для знака
        return HealingApproach(
            primaryApproach: sign.element.healingMethod,
            simpleDescription: "Исцеление через \(sign.element.healingMethod.lowercased())",
            technicalDescription: "Интеграция \(sign.displayName) энергий",
            practicalSteps: sign.element.practicalHealingSteps,
            expectedTimeframe: "2-4 недели",
            supportiveActivities: sign.modality.supportiveActivities
        )
    }

    func getPlanetResonance(_ planet: PlanetType) -> EmotionalResonanceData {
        switch planet {
        case .sun:
            return EmotionalResonanceData(intensity: 0.8, stability: 0.7, accessibility: 0.9, complexity: 0.3)
        case .moon:
            return EmotionalResonanceData(intensity: 0.9, stability: 0.4, accessibility: 1.0, complexity: 0.5)
        case .mercury:
            return EmotionalResonanceData(intensity: 0.6, stability: 0.5, accessibility: 0.8, complexity: 0.6)
        case .venus:
            return EmotionalResonanceData(intensity: 0.7, stability: 0.6, accessibility: 0.9, complexity: 0.3)
        case .mars:
            return EmotionalResonanceData(intensity: 0.9, stability: 0.5, accessibility: 0.7, complexity: 0.4)
        case .jupiter:
            return EmotionalResonanceData(intensity: 0.6, stability: 0.8, accessibility: 0.7, complexity: 0.5)
        case .saturn:
            return EmotionalResonanceData(intensity: 0.5, stability: 0.9, accessibility: 0.4, complexity: 0.8)
        case .uranus:
            return EmotionalResonanceData(intensity: 0.8, stability: 0.2, accessibility: 0.5, complexity: 0.9)
        case .neptune:
            return EmotionalResonanceData(intensity: 0.6, stability: 0.3, accessibility: 0.6, complexity: 0.9)
        case .pluto:
            return EmotionalResonanceData(intensity: 1.0, stability: 0.6, accessibility: 0.3, complexity: 1.0)
        case .ascendant:
            return EmotionalResonanceData(intensity: 0.6, stability: 0.7, accessibility: 0.9, complexity: 0.2)
        case .midheaven:
            return EmotionalResonanceData(intensity: 0.7, stability: 0.8, accessibility: 0.7, complexity: 0.4)
        case .northNode:
            return EmotionalResonanceData(intensity: 0.8, stability: 0.6, accessibility: 0.5, complexity: 0.7)
        }
    }

    func getSignResonance(_ sign: ZodiacSign) -> EmotionalResonanceData {
        let elementResonance = sign.element.resonanceData
        let modalityResonance = sign.modality.resonanceData

        return EmotionalResonanceData(
            intensity: (elementResonance.intensity + modalityResonance.intensity) / 2,
            stability: (elementResonance.stability + modalityResonance.stability) / 2,
            accessibility: (elementResonance.accessibility + modalityResonance.accessibility) / 2,
            complexity: (elementResonance.complexity + modalityResonance.complexity) / 2
        )
    }
}

// MARK: - Supporting Extensions

extension ZodiacSign.Element {
    var healingMethod: String {
        switch self {
        case .fire: return "Творческое выражение"
        case .earth: return "Работа с телом"
        case .air: return "Интеллектуальное понимание"
        case .water: return "Эмоциональное принятие"
        }
    }

    var practicalHealingSteps: [String] {
        switch self {
        case .fire:
            return ["Физическая активность", "Творческие проекты", "Лидерство"]
        case .earth:
            return ["Работа в саду", "Массаж", "Здоровое питание"]
        case .air:
            return ["Журналинг", "Обучение", "Социальное общение"]
        case .water:
            return ["Медитация", "Водные процедуры", "Эмоциональная терапия"]
        }
    }

    var resonanceData: EmotionalResonanceData {
        switch self {
        case .fire:
            return EmotionalResonanceData(intensity: 0.9, stability: 0.4, accessibility: 0.8, complexity: 0.3)
        case .earth:
            return EmotionalResonanceData(intensity: 0.5, stability: 0.9, accessibility: 0.7, complexity: 0.4)
        case .air:
            return EmotionalResonanceData(intensity: 0.6, stability: 0.5, accessibility: 0.9, complexity: 0.6)
        case .water:
            return EmotionalResonanceData(intensity: 0.8, stability: 0.3, accessibility: 0.8, complexity: 0.7)
        }
    }
}

extension ZodiacSign.Modality {
    var supportiveActivities: [String] {
        switch self {
        case .cardinal:
            return ["Планирование", "Инициирование проектов", "Лидерство"]
        case .fixed:
            return ["Медитация", "Ремесла", "Садоводство"]
        case .mutable:
            return ["Изучение языков", "Путешествия", "Адаптационные практики"]
        }
    }

    var resonanceData: EmotionalResonanceData {
        switch self {
        case .cardinal:
            return EmotionalResonanceData(intensity: 0.8, stability: 0.4, accessibility: 0.7, complexity: 0.5)
        case .fixed:
            return EmotionalResonanceData(intensity: 0.6, stability: 0.9, accessibility: 0.6, complexity: 0.6)
        case .mutable:
            return EmotionalResonanceData(intensity: 0.5, stability: 0.3, accessibility: 0.9, complexity: 0.7)
        }
    }
}