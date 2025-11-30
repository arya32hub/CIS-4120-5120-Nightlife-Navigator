import SwiftUI

struct NightOutGroup: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var members: [GroupMember]
}

struct GroupFitView: View {
    @State private var groups: [NightOutGroup] = [
        NightOutGroup(
            name: "Roommates",
            members: [
                GroupMember(name: "You", maxCover: 20, maxWaitMinutes: 30, vibe: 55),
                GroupMember(name: "Alex", maxCover: 15, maxWaitMinutes: 20, vibe: 35),
                GroupMember(name: "Sam", maxCover: 25, maxWaitMinutes: 45, vibe: 80)
            ]
        ),
        NightOutGroup(
            name: "After-Work Crew",
            members: [
                GroupMember(name: "Jess", vibe: 40),
                GroupMember(name: "Diego", vibe: 70),
                GroupMember(name: "Priya", vibe: 60)
            ]
        ),
        NightOutGroup(
            name: "Birthday Squad",
            members: [
                GroupMember(name: "Taylor", vibe: 85),
                GroupMember(name: "Jordan", vibe: 65),
                GroupMember(name: "Chris", vibe: 50)
            ]
        )
    ]
    @State private var showingAddGroup = false
    @State private var newGroupName = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header

                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach($groups) { $group in
                            NavigationLink {
                                GroupDetailView(group: $group)
                            } label: {
                                GroupCard(group: group)
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            showingAddGroup = true
                        } label: {
                            Label("Add New Group", systemImage: "plus.circle.fill")
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(white: 0.15))
                                .cornerRadius(14)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddGroup) {
            NavigationStack {
                Form {
                    TextField("Group name", text: $newGroupName)
                        .textInputAutocapitalization(.words)
                }
                .navigationTitle("Add Group")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAddGroup = false
                            newGroupName = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let trimmed = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                groups.append(NightOutGroup(name: trimmed, members: [GroupMember(name: "You")]))
                            }
                            showingAddGroup = false
                            newGroupName = ""
                        }
                        .disabled(newGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Group Fit")
                .font(.largeTitle).fontWeight(.bold)
                .foregroundColor(.white)
            Text("Pick the crew you are heading out with tonight.")
                .foregroundColor(.gray)
        }
        .padding([.top, .horizontal])
    }
}

// MARK: - Group Detail
private struct GroupDetailView: View {
    @Binding var group: NightOutGroup
    @State private var showingAddMember = false
    @State private var newMemberName = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    GroupIntroCard(group: group)

                    VStack(spacing: 12) {
                        ForEach($group.members) { $member in
                            FriendVibeRow(member: $member)
                        }

                        Button {
                            showingAddMember = true
                        } label: {
                            Label("Add Member", systemImage: "person.badge.plus")
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(white: 0.15))
                                .cornerRadius(14)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color(white: 0.1))
                    .cornerRadius(18)
                    .padding(.bottom, 80) // make room for bottom CTA
                }
                .padding()
            }
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            NavigationLink {
                VenueListView(venues: scoredVenues())
            } label: {
                Text("Generate List")
                    .font(.headline).fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(14)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color.black.opacity(0.95).ignoresSafeArea(edges: .bottom))
        }
        .sheet(isPresented: $showingAddMember) {
            NavigationStack {
                Form {
                    TextField("Member name", text: $newMemberName)
                        .textInputAutocapitalization(.words)
                }
                .navigationTitle("Add Member")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingAddMember = false
                            newMemberName = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            let trimmed = newMemberName.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty {
                                group.members.append(GroupMember(name: trimmed))
                            }
                            showingAddMember = false
                            newMemberName = ""
                        }
                        .disabled(newMemberName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
    }

    private func scoredVenues() -> [Venue] {
        let base = VenueListView.defaultVenues
        let summary = groupSummary
        return base.map { venue in
            let fit = score(
                venue: venue,
                groupAvgWait: summary.avgWait,
                groupAvgVibe: summary.avgVibe
            )
            return Venue(
                name: venue.name,
                distance: venue.distance,
                waitTime: venue.waitTime,
                status: venue.status,
                musicGenre: venue.musicGenre,
                soundLevel: venue.soundLevel,
                groupFit: fit,
                coordinate: venue.coordinate
            )
        }
    }

    private var groupSummary: (avgWait: Double, avgVibe: Double) {
        guard !group.members.isEmpty else { return (0, 0) }
        let wait = group.members.map(\.maxWaitMinutes).reduce(0,+) / Double(group.members.count)
        let vibe = group.members.map(\.vibe).reduce(0,+) / Double(group.members.count)
        return (wait, vibe)
    }

    private func score(venue: Venue, groupAvgWait: Double, groupAvgVibe: Double) -> Int {
        var value: Double = 100
        if let venueWait = parseWait(venue.waitTime), groupAvgWait > 0 {
            let over = max(0, venueWait - groupAvgWait) / max(groupAvgWait, 1)
            value -= min(40.0 * over, 40)
        }

        let venueVibe = vibeFor(status: venue.status, genre: venue.musicGenre)
        let vibeDelta = abs(venueVibe - groupAvgVibe) / 100.0
        value -= min(vibeDelta * 20.0, 20)

        return max(0, min(100, Int(round(value))))
    }

    private func parseWait(_ value: String) -> Double? {
        let trimmed = value.replacingOccurrences(of: " min", with: "")
        let parts = trimmed.split(separator: "-").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        if parts.count == 2 { return (parts[0] + parts[1]) / 2.0 }
        return parts.first
    }

    private func vibeFor(status: String, genre: String) -> Double {
        let g = genre.lowercased()
        let genreBase: Double = {
            if g.contains("edm") || g.contains("house") || g.contains("techno") { return 80 }
            if g.contains("top 40") { return 65 }
            if g.contains("latin") { return 70 }
            if g.contains("r&b") { return 55 }
            if g.contains("rock")  { return 60 }
            if g.contains("acoustic") || g.contains("jazz") { return 35 }
            return 50
        }()

        let s = status.lowercased()
        let crowd: Double = (s.contains("busy") ? 10 : (s.contains("moderate") ? 5 : 0))
        return max(0, min(100, genreBase + crowd))
    }
}

// MARK: - Shared Models & UI
struct GroupMember: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var maxCover: Double
    var maxWaitMinutes: Double
    var vibe: Double

    init(name: String, maxCover: Double = 20, maxWaitMinutes: Double = 30, vibe: Double = 50) {
        self.name = name
        self.maxCover = maxCover
        self.maxWaitMinutes = maxWaitMinutes
        self.vibe = vibe
    }
}

private struct GroupCard: View {
    let group: NightOutGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(group.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(group.members.count) friends")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 12) {
                Label("\(Int(groupAverageVibe)) vibe", systemImage: "music.note")
                    .font(.subheadline)
                Label("Avg wait \(Int(groupAverageWait)) min", systemImage: "clock")
                    .font(.subheadline)
            }
            .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.15))
        .cornerRadius(18)
    }

    private var groupAverageVibe: Double {
        guard !group.members.isEmpty else { return 0 }
        return group.members.map(\.vibe).reduce(0,+) / Double(group.members.count)
    }

    private var groupAverageWait: Double {
        guard !group.members.isEmpty else { return 0 }
        return group.members.map(\.maxWaitMinutes).reduce(0,+) / Double(group.members.count)
    }
}

private struct GroupIntroCard: View {
    let group: NightOutGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Tonight's Crew")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)

            Text(group.name)
                .font(.title).fontWeight(.bold)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                summaryStat(title: "Friends", value: "\(group.members.count)")
                summaryStat(title: "Vibe Target", value: vibeRange)
            }

            Text("Fine-tune each friend's vibe, wait time, and cover tolerance so the venue list matches your group's energy.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(white: 0.12))
        )
    }

    private func summaryStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(.gray)
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
    }

    private var vibeRange: String {
        guard !group.members.isEmpty else { return "Balanced" }
        let avg = group.members.map(\.vibe).reduce(0,+) / Double(group.members.count)
        switch avg {
        case 0..<25: return "Chill"
        case 25..<60: return "Balanced"
        default: return "Hype"
        }
    }
}

private struct FriendVibeRow: View {
    @Binding var member: GroupMember

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(member.name)
                    .font(.headline)
                    .foregroundColor(.white)
            }

            PreferenceSlider(
                title: "Vibe",
                value: $member.vibe,
                range: 0...100,
                step: 1,
                tint: .blue,
                valueLabel: vibeLabel(member.vibe)
            )

            PreferenceSlider(
                title: "Wait Time",
                value: $member.maxWaitMinutes,
                range: 0...120,
                step: 5,
                tint: .green,
                valueLabel: "\(Int(member.maxWaitMinutes)) min"
            )

            PreferenceSlider(
                title: "Max Cover",
                value: $member.maxCover,
                range: 0...100,
                step: 1,
                tint: .purple,
                valueLabel: "$\(Int(member.maxCover))"
            )
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(white: 0.13))
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 8)
        )
    }

    private func vibeLabel(_ value: Double) -> String {
        switch value {
        case 0..<25: return "Chill"
        case 25..<60: return "Balanced"
        default: return "Hype"
        }
    }
}

private struct PreferenceSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let tint: Color
    let valueLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title.uppercased())
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text(valueLabel)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
            }

            Slider(value: $value, in: range, step: step)
                .tint(tint)
        }
    }
}
