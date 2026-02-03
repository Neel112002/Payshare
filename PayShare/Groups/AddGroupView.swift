import SwiftUI

struct AddGroupView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var groupName: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Group name")
                        .font(.headline)

                    TextField("e.g. Goa Trip", text: $groupName)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button {
                    Task {
                        await createGroup()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Group")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(groupName.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - API

    @MainActor
    private func createGroup() async {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await APIClient.shared.createGroup(name: groupName)
            dismiss()
        } catch {
            errorMessage = "Failed to create group"
            print("❌ Create group error:", error)
        }

        isLoading = false
    }
}
