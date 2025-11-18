import SwiftUI

/// Language picker component for app settings
struct LanguagePickerView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Language")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(AppLanguage.allCases) { language in
                LanguageRow(
                    language: language,
                    isSelected: localizationManager.currentLanguage == language
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        localizationManager.setLanguage(language)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.3))
        )
    }
}

// MARK: - Language Row

private struct LanguageRow: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(language.flag)
                    .font(.title2)

                Text(language.displayName)
                    .font(.body)
                    .foregroundColor(.white)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.neonPurple)
                        .font(.title3)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.neonPurple.opacity(0.2) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.neonPurple : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.cosmicBlue.ignoresSafeArea()

        LanguagePickerView()
            .padding()
    }
}
