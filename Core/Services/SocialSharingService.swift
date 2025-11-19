import UIKit
import SwiftUI

/// Service for sharing content to social media and other apps
class SocialSharingService {
    static let shared = SocialSharingService()

    private init() {}

    // MARK: - Share Birth Chart

    /// Share birth chart as image and text
    func shareBirthChart(chart: BirthChart, image: UIImage?) {
        let text = generateBirthChartShareText(chart: chart)
        var items: [Any] = [text]

        if let chartImage = image {
            items.append(chartImage)
        }

        presentShareSheet(items: items)
    }

    // MARK: - Share Compatibility

    /// Share compatibility result with friend
    func shareCompatibility(
        friend: Friend,
        score: Int,
        description: String?
    ) {
        let text = generateCompatibilityShareText(
            friend: friend,
            score: score,
            description: description
        )

        presentShareSheet(items: [text])
    }

    /// Share compatibility with image
    func shareCompatibilityWithImage(
        friend: Friend,
        score: Int,
        description: String?,
        image: UIImage
    ) {
        let text = generateCompatibilityShareText(
            friend: friend,
            score: score,
            description: description
        )

        presentShareSheet(items: [text, image])
    }

    // MARK: - Share Daily Horoscope

    /// Share daily horoscope
    func shareDailyHoroscope(sign: String, prediction: String, date: Date) {
        let text = generateHoroscopeShareText(
            sign: sign,
            prediction: prediction,
            date: date
        )

        presentShareSheet(items: [text])
    }

    // MARK: - Generate Share Texts

    private func generateBirthChartShareText(chart: BirthChart) -> String {
        var text = "Моя натальная карта 🌟\n\n"
        text += "Дата рождения: \(chart.birthDate.formatted(date: .long, time: .omitted))\n"
        text += "Место: \(chart.location)\n\n"

        // Add major placements
        if let sun = chart.planets.first(where: { $0.name == "Sun" }) {
            text += "Солнце ☉ в \(sun.sign)\n"
        }

        if let moon = chart.planets.first(where: { $0.name == "Moon" }) {
            text += "Луна ☽ в \(moon.sign)\n"
        }

        if let asc = chart.houses.first {
            text += "Асцендент в \(asc.sign)\n"
        }

        text += "\n#Astrology #NatalChart #Astrolog"

        return text
    }

    private func generateCompatibilityShareText(
        friend: Friend,
        score: Int,
        description: String?
    ) -> String {
        var text = "Совместимость 💫\n\n"
        text += "С: \(friend.friendName)\n"
        text += "Совместимость: \(score)%\n\n"

        if let desc = description {
            text += "\(desc)\n\n"
        }

        text += "#Astrology #Compatibility #Synastry #Astrolog"

        return text
    }

    private func generateHoroscopeShareText(
        sign: String,
        prediction: String,
        date: Date
    ) -> String {
        var text = "Гороскоп на \(date.formatted(date: .abbreviated, time: .omitted)) 🌙\n\n"
        text += "Знак: \(sign)\n\n"
        text += "\(prediction)\n\n"
        text += "#Horoscope #\(sign) #Astrology #Astrolog"

        return text
    }

    // MARK: - Present Share Sheet

    private func presentShareSheet(items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        // Exclude certain activity types if needed
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .print
        ]

        // For iPad support
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = rootViewController.view
            popoverController.sourceRect = CGRect(
                x: rootViewController.view.bounds.midX,
                y: rootViewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        rootViewController.present(activityViewController, animated: true)
    }

    // MARK: - Generate Share Image

    /// Generate a shareable image from a SwiftUI view
    @MainActor
    func generateImage<Content: View>(from view: Content, size: CGSize = CGSize(width: 1080, height: 1080)) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: - SwiftUI Extension

extension View {
    /// Share button modifier
    func shareButton<Content: View>(
        items: [Any],
        @ViewBuilder label: () -> Content
    ) -> some View {
        Button(action: {
            SocialSharingService.shared.presentShareSheet(items: items)
        }) {
            label()
        }
    }
}
