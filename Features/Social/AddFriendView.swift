import SwiftUI

/// View for searching and adding friends
struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var friendService = FriendService.shared

    @State private var searchEmail = ""
    @State private var searchResult: UserSearchResult?
    @State private var isSearching = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var friendMessage = ""
    @State private var showingSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                StarfieldBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: CosmicSpacing.large) {
                        CosmicSectionHeader(
                            "Добавить друга",
                            subtitle: "Найдите друзей по email адресу",
                            icon: "person.badge.plus"
                        )

                        // Search Section
                        CosmicCard(glowColor: .neonPurple) {
                            VStack(spacing: CosmicSpacing.medium) {
                                // Email Input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Email друга")
                                        .font(CosmicTypography.caption)
                                        .foregroundColor(.starWhite.opacity(0.8))

                                    TextField("example@email.com", text: $searchEmail)
                                        .textFieldStyle(CosmicTextFieldStyle())
                                        .textInputAutocapitalization(.never)
                                        .keyboardType(.emailAddress)
                                        .autocorrectionDisabled()
                                }

                                // Search Button
                                Button(action: searchUser) {
                                    HStack {
                                        if isSearching {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .cosmicBlue))
                                        } else {
                                            Image(systemName: "magnifyingglass")
                                            Text("Найти")
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.neonPurple)
                                    .foregroundColor(.cosmicBlue)
                                    .cornerRadius(12)
                                }
                                .disabled(searchEmail.isEmpty || isSearching)
                            }
                            .padding()
                        }

                        // Search Result
                        if let result = searchResult {
                            UserSearchResultView(
                                user: result,
                                message: $friendMessage,
                                onSendRequest: {
                                    sendFriendRequest(to: result)
                                }
                            )
                        }

                        // Instructions
                        CosmicCard(glowColor: .cosmicBlue.opacity(0.3)) {
                            VStack(alignment: .leading, spacing: CosmicSpacing.small) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.cosmicTeal)

                                    Text("Как это работает")
                                        .font(CosmicTypography.headline)
                                        .foregroundColor(.starWhite)

                                    Spacer()
                                }

                                Text("1. Введите email друга")
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.starWhite.opacity(0.8))

                                Text("2. Отправьте запрос в друзья")
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.starWhite.opacity(0.8))

                                Text("3. После принятия вы сможете увидеть совместимость")
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(.starWhite.opacity(0.8))
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal, CosmicSpacing.medium)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.starWhite)
                }
            }
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .alert("Запрос отправлен", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Запрос в друзья успешно отправлен")
            }
        }
    }

    private func searchUser() {
        guard !searchEmail.isEmpty else { return }

        isSearching = true

        Task {
            do {
                searchResult = try await friendService.searchUserByEmail(searchEmail)

                if searchResult == nil {
                    errorMessage = "Пользователь с таким email не найден"
                    showingError = true
                }
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }

            isSearching = false
        }
    }

    private func sendFriendRequest(to user: UserSearchResult) {
        Task {
            do {
                try await friendService.sendFriendRequest(
                    toUserId: user.id,
                    toUserName: user.name,
                    toUserEmail: user.email,
                    message: friendMessage.isEmpty ? nil : friendMessage
                )

                showingSuccess = true
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

// MARK: - User Search Result View

struct UserSearchResultView: View {
    let user: UserSearchResult
    @Binding var message: String
    let onSendRequest: () -> Void

    @State private var showingMessageField = false

    var body: some View {
        CosmicCard(glowColor: .cosmicTeal) {
            VStack(spacing: CosmicSpacing.medium) {
                // User Info
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.cosmicBlue.opacity(0.3))
                            .frame(width: 60, height: 60)

                        Text(user.name.prefix(1).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.starWhite)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(CosmicTypography.headline)
                            .foregroundColor(.starWhite)

                        Text(user.email)
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.7))

                        HStack(spacing: 4) {
                            Image(systemName: user.hasBirthChart ? "checkmark.circle.fill" : "exclamationmark.circle")
                                .font(.caption)
                                .foregroundColor(user.hasBirthChart ? .cosmicTeal : .starWhite.opacity(0.5))

                            Text(user.hasBirthChart ? "Карта доступна" : "Карта не создана")
                                .font(CosmicTypography.caption)
                                .foregroundColor(.starWhite.opacity(0.7))
                        }
                    }

                    Spacer()
                }

                // Optional Message
                if showingMessageField {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Сообщение (необязательно)")
                            .font(CosmicTypography.caption)
                            .foregroundColor(.starWhite.opacity(0.8))

                        TextField("Привет! Давай дружить!", text: $message)
                            .textFieldStyle(CosmicTextFieldStyle())
                    }
                }

                // Actions
                VStack(spacing: CosmicSpacing.small) {
                    if !showingMessageField {
                        Button(action: { showingMessageField = true }) {
                            HStack {
                                Image(systemName: "text.bubble")
                                Text("Добавить сообщение")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.cosmicBlue.opacity(0.3))
                            .foregroundColor(.starWhite)
                            .cornerRadius(12)
                        }
                    }

                    Button(action: onSendRequest) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Отправить запрос")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cosmicTeal)
                        .foregroundColor(.cosmicBlue)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Cosmic Text Field Style

struct CosmicTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.cosmicBlue.opacity(0.2))
            .cornerRadius(12)
            .foregroundColor(.starWhite)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.starWhite.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Preview

#Preview {
    AddFriendView()
}
