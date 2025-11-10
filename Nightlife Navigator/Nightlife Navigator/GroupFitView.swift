import SwiftUI

// Single-file "Group Fit" screen with hardcoded data and a placeholder results screen.
struct GroupFitView: View {
    // Hardcoded sample members
    @State private var members: [Member] = [
        Member(name: "You",   maxCover: 20, maxWaitMinutes: 30, vibe: 55),
        Member(name: "Alex",  maxCover: 15, maxWaitMinutes: 20, vibe: 35),
        Member(name: "Sam",   maxCover: 25, maxWaitMinutes: 45, vibe: 80)
    ]
    @State private var showingAdd = false
    @State private var newName = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // app dark background

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Group Fit")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(members.count) members")
                        .foregroundColor(.gray)
                }
                .padding()

                // Members list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach($members) { $member in
                            MemberRowCard(member: $member)
                        }

                        Button {
                            showingAdd = true
                        } label: {
                            Label("Add Member", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(white: 0.15))
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }

            // Bottom CTA
            VStack {
                Spacer()
                NavigationLink {
                    ResultsPlaceholderView(summary: groupSummary, members: members)
                } label: {
                    Text("Generate List")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                Form {
                    TextField("Member name", text: $newName)
                        .textInputAutocapitalization(.words)
                }
                .navigationTitle("Add Member")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAdd = false; newName = "" }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                members.append(Member(name: trimmed))
                            }
                            showingAdd = false
                            newName = ""
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }

    // MARK: - Aggregates (used by results screen)
    private var groupSummary: (avgCover: Double, avgWait: Double, avgVibe: Double) {
        guard !members.isEmpty else { return (0, 0, 0) }
        let c = members.map(\.maxCover).reduce(0,+) / Double(members.count)
        let w = members.map(\.maxWaitMinutes).reduce(0,+) / Double(members.count)
        let v = members.map(\.vibe).reduce(0,+) / Double(members.count)
        return (c, w, v)
    }
}

// MARK: - Inline model
struct Member: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var maxCover: Double      // USD (0–50)
    var maxWaitMinutes: Double// minutes (0–120)
    var vibe: Double          // 0 = chill, 100 = hype

    init(name: String, maxCover: Double = 20, maxWaitMinutes: Double = 30, vibe: Double = 50) {
        self.name = name
        self.maxCover = maxCover
        self.maxWaitMinutes = maxWaitMinutes
        self.vibe = vibe
    }
}

// MARK: - Row UI (dark card w/ sliders)
private struct MemberRowCard: View {
    @Binding var member: Member

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Name", text: $member.name)
                .textInputAutocapitalization(.words)
                .font(.headline)
                .foregroundColor(.white)

            // Max Cover
            labeled("Max Cover", right: "$\(Int(member.maxCover))", icon: "dollarsign.circle") {
                Slider(value: $member.maxCover, in: 0...50, step: 1)
                    .accessibilityLabel("Maximum cover for \(member.name)")
            }

            // Max Wait
            labeled("Max Wait", right: "\(Int(member.maxWaitMinutes)) min", icon: "clock") {
                Slider(value: $member.maxWaitMinutes, in: 0...120, step: 5)
                    .accessibilityLabel("Maximum wait for \(member.name)")
            }

            // Vibe
            labeled("Vibe", right: vibeLabel(member.vibe), icon: "music.quarternote.3") {
                Slider(value: $member.vibe, in: 0...100, step: 1)
                    .accessibilityLabel("Preferred vibe for \(member.name)")
            }
        }
        .padding()
        .background(Color(white: 0.15))
        .cornerRadius(16)
    }

    private func labeled(_ left: String, right: String, icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(left, systemImage: icon)
                    .foregroundColor(.white)
                Spacer()
                Text(right)
                    .foregroundColor(.gray)
                    .monospacedDigit()
            }
            content()
        }
    }

    private func vibeLabel(_ v: Double) -> String {
        switch v {
        case 0..<25: return "Chill"
        case 25..<60: return "Balanced"
        default: return "Hype"
        }
    }
}

// MARK: - Placeholder results
private struct ResultsPlaceholderView: View {
    let summary: (avgCover: Double, avgWait: Double, avgVibe: Double)
    let members: [Member]

    var body: some View {
        List {
            Section("Group Summary") {
                LabeledContent("Avg Max Cover", value: "$\(Int(summary.avgCover))")
                LabeledContent("Avg Max Wait", value: "\(Int(summary.avgWait)) min")
                LabeledContent("Avg Vibe", value: "\(Int(summary.avgVibe)) / 100")
            }
            Section("Members") {
                ForEach(members) { m in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(m.name).font(.headline)
                        Text("Cover $\(Int(m.maxCover)) · Wait \(Int(m.maxWaitMinutes))m · Vibe \(Int(m.vibe))/100")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
            Section {
                Text("Later: filter/rank venues by these constraints (e.g., cover ≤ avg/max, wait ≤ avg/max, vibe similarity, distance).")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.black)
        .navigationTitle("Generated List")
    }
}
