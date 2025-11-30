import SwiftUI
import MapKit
import CoreImage.CIFilterBuiltins

// 1) Add this new property to Venue
struct Venue: Identifiable {
    let id = UUID()
    let name: String
    let distance: String
    let waitTime: String
    let status: String
    let musicGenre: String
    let soundLevel: String
    let groupFit: Int?    // NEW
    let coordinate: CLLocationCoordinate2D
}

private enum VenueViewMode: String, CaseIterable {
    case list = "List"
    case map = "Map"
}

// 2) Replace your @State sample array with:
struct VenueListView: View {
    private let baseVenues: [Venue]
    @State private var venues: [Venue]
    @State private var viewMode: VenueViewMode = .list
    @State private var mapCameraPosition: MapCameraPosition
    @State private var lastRequestedRegion: MKCoordinateRegion?
    @State private var currentRegion: MKCoordinateRegion
    @State private var mapSelectedVenue: Venue?

    init(venues: [Venue]? = nil) {
        let initialVenues = venues ?? VenueListView.defaultVenues
        self.baseVenues = initialVenues
        self._venues = State(initialValue: initialVenues)
        let region = VenueListView.philadelphiaRegion
        self._mapCameraPosition = State(initialValue: .region(region))
        self._lastRequestedRegion = State(initialValue: region)
        self._currentRegion = State(initialValue: region)
        self._mapSelectedVenue = State(initialValue: nil)
    }

    // Your original sample data, now as a static so Group Fit can reuse it
    static let defaultVenues: [Venue] = [
        Venue(name: "The Velvet Room", distance: "0.3 mi", waitTime: "0-5 min",
              status: "Comfy", musicGenre: "R&B DJ", soundLevel: "moderate", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9529, longitude: -75.1653)),
        Venue(name: "Neon Pulse", distance: "0.5 mi", waitTime: "10-15 min",
              status: "Busy", musicGenre: "EDM", soundLevel: "loud", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9501, longitude: -75.1696)),
        Venue(name: "Socialista", distance: "0.6 mi", waitTime: "5-10 min",
              status: "Moderate", musicGenre: "Latin", soundLevel: "loud", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9552, longitude: -75.1589)),
        Venue(name: "Paul's Baby Grand", distance: "0.8 mi", waitTime: "0-5 min",
              status: "Comfy", musicGenre: "Live Jazz", soundLevel: "moderate", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9491, longitude: -75.1632)),
        Venue(name: "The Jazz Corner", distance: "0.9 mi", waitTime: "5-10 min",
              status: "Moderate", musicGenre: "Live Jazz", soundLevel: "moderate", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9578, longitude: -75.1704)),
        Venue(name: "Rooftop Lounge", distance: "1.2 mi", waitTime: "15-20 min",
              status: "Busy", musicGenre: "House", soundLevel: "loud", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9458, longitude: -75.1577)),
        Venue(name: "Warehouse on Watts", distance: "1.4 mi", waitTime: "20-25 min",
              status: "Busy", musicGenre: "Techno", soundLevel: "loud", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9643, longitude: -75.1771)),
        Venue(name: "The Dive Bar", distance: "1.5 mi", waitTime: "0-5 min",
              status: "Comfy", musicGenre: "Rock Cover Band", soundLevel: "moderate", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9484, longitude: -75.175)),
        Venue(name: "Silk Nightclub", distance: "1.7 mi", waitTime: "25-30 min",
              status: "Busy", musicGenre: "Top 40", soundLevel: "loud", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9412, longitude: -75.1662)),
        Venue(name: "The Library Lounge", distance: "1.9 mi", waitTime: "5-10 min",
              status: "Moderate", musicGenre: "Acoustic", soundLevel: "moderate", groupFit: nil,
              coordinate: CLLocationCoordinate2D(latitude: 39.9589, longitude: -75.1508))
    ]

    static let philadelphiaRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.952583, longitude: -75.165222),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )
    
    @State private var selectedVenue: Venue?
    @State private var showQRCode = false
    @State private var showCheckIn = false
    @State private var qrCodeImage: UIImage?
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Nearby Venues")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(venues.count) spots")
                        .foregroundColor(.gray)
                }
                .padding()
                
                VenueViewToggle(selection: $viewMode)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .onChange(of: viewMode) { newValue in
                        if newValue == .list {
                            mapSelectedVenue = nil
                        } else {
                            mapSelectedVenue = nil
                            mapCameraPosition = .region(VenueListView.philadelphiaRegion)
                            currentRegion = VenueListView.philadelphiaRegion
                        }
                    }
                
                Group {
                    if viewMode == .list {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(venues) { venue in
                                    VenueCard(
                                        venue: venue,
                                        onImHere: {
                                            checkIn(to: venue)
                                        },
                                        onQRButton: {
                                            generateQRCode(for: venue)
                                        }
                                    )
                                }
                            }
                            .padding()
                            .padding(.bottom, 140)
                        }
                    } else {
                        ZStack {
                            VenueMapView(
                                venues: venues,
                                cameraPosition: $mapCameraPosition,
                                onRegionChange: handleMapRegionChange,
                                onPinTap: { venue in
                                    withAnimation(.spring()) {
                                        mapSelectedVenue = venue
                                    }
                                },
                                onZoomIn: { zoom(by: 0.6) },
                                onZoomOut: { zoom(by: 1.4) }
                            )
                            .padding(.horizontal)
                            .padding(.bottom, 140)
                            
                            if mapSelectedVenue != nil {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(Color.black.opacity(0.001))
                                    .padding(.horizontal)
                                    .padding(.bottom, 24)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            mapSelectedVenue = nil
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            if viewMode == .map, let selected = mapSelectedVenue {
                VStack {
                    Spacer()
                    VenueCardWithHandle(
                        venue: selected,
                        onDismiss: {
                            withAnimation(.spring()) {
                                mapSelectedVenue = nil
                            }
                        },
                        onImHere: { checkIn(to: selected) },
                        onQRButton: { generateQRCode(for: selected) }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
            
            // QR Code Overlay
            if showQRCode, let qrImage = qrCodeImage, let venue = selectedVenue {
                QRCodeOverlay(
                    venueName: venue.name,
                    qrImage: qrImage,
                    onDismiss: {
                        showQRCode = false
                        selectedVenue = nil
                    }
                )
            }
            
            // Check-in Confirmation Overlay
            if showCheckIn, let venue = selectedVenue {
                CheckInConfirmationOverlay(
                    venueName: venue.name,
                    onDismiss: {
                        showCheckIn = false
                        selectedVenue = nil
                    }
                )
            }
        }
    }
    
    // Check in to venue
    func checkIn(to venue: Venue) {
        selectedVenue = venue
        showCheckIn = true
    }
    
    // Generate QR Code
    func generateQRCode(for venue: Venue) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data("venue:\(venue.name)_checkin:\(Date().timeIntervalSince1970)".utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            // Scale up the QR code
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                qrCodeImage = UIImage(cgImage: cgImage)
                selectedVenue = venue
                showQRCode = true
            }
        }
    }

    private func handleMapRegionChange(_ region: MKCoordinateRegion) {
        currentRegion = region
        guard shouldRequestNewVenues(for: region) else { return }
        loadVenues(for: region)
    }

    private func shouldRequestNewVenues(for region: MKCoordinateRegion) -> Bool {
        guard let last = lastRequestedRegion else { return true }
        let latDiff = abs(region.center.latitude - last.center.latitude)
        let lonDiff = abs(region.center.longitude - last.center.longitude)
        // Roughly ~0.6 miles before reloading
        return latDiff > 0.01 || lonDiff > 0.01
    }

    private func loadVenues(for region: MKCoordinateRegion) {
        lastRequestedRegion = region
        venues = relocatedVenues(for: region)
        mapSelectedVenue = nil
    }

    private func zoom(by scale: Double) {
        var newSpan = MKCoordinateSpan(
            latitudeDelta: max(0.005, currentRegion.span.latitudeDelta * scale),
            longitudeDelta: max(0.005, currentRegion.span.longitudeDelta * scale)
        )
        newSpan.latitudeDelta = min(newSpan.latitudeDelta, 0.5)
        newSpan.longitudeDelta = min(newSpan.longitudeDelta, 0.5)
        let newRegion = MKCoordinateRegion(center: currentRegion.center, span: newSpan)
        currentRegion = newRegion
        mapCameraPosition = .region(newRegion)
    }

    private func relocatedVenues(for region: MKCoordinateRegion) -> [Venue] {
        // Future hook: request new venues based on region and update base data.
        // For now keep venues stationary so pins align with their real-world coordinates.
        return baseVenues
    }
}

struct VenueCard: View {
    let venue: Venue
    let onImHere: () -> Void
    let onQRButton: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main card
            VStack(alignment: .leading, spacing: 12) {
                // Venue name and sound indicator
                HStack {
                    Text(venue.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    if let fit = venue.groupFit {
                            Text("Group Fit \(fit)%")
                                .font(.caption).fontWeight(.semibold)
                                .foregroundColor(groupFitColor(fit))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(white: 0.12))
                                .cornerRadius(10)
                        }
                    
                    Spacer()
                    
                    // Sound level indicator
                    Image(systemName: venue.soundLevel == "loud" ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .foregroundColor(venue.soundLevel == "loud" ? .orange : .green)
                }
                
                // Distance
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                    Text(venue.distance)
                        .foregroundColor(.gray)
                }
                .font(.subheadline)
                
                // Status and wait time
                HStack(spacing: 12) {
                    // Status badge
                    HStack {
                        Circle()
                            .fill(statusColor(for: venue.status))
                            .frame(width: 8, height: 8)
                        Text(venue.status)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(for: venue.status).opacity(0.2))
                    .foregroundColor(statusColor(for: venue.status))
                    .cornerRadius(16)
                    
                    // Wait time
                    HStack {
                        Image(systemName: "clock")
                        Text(venue.waitTime)
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                
                // Music genre
                HStack {
                    Image(systemName: "music.note")
                    Text(venue.musicGenre)
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                
                // "I'm Here!" Button
                Button(action: onImHere) {
                    Text("I'm Here!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(white: 0.15))
            .cornerRadius(16)
            
            // QR Code button in top-right corner
            Button(action: onQRButton) {
                Image(systemName: "qrcode")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .offset(x: -12, y: 12)
        }
    }
    
    private func groupFitColor(_ v: Int) -> Color {
        switch v {
        case 0..<40:  return .red
        case 40..<70: return .yellow
        default:      return .green
        }
    }

}

struct VenueMapView: View {
    let venues: [Venue]
    @Binding var cameraPosition: MapCameraPosition
    var onRegionChange: (MKCoordinateRegion) -> Void
    var onPinTap: (Venue) -> Void
    var onZoomIn: () -> Void
    var onZoomOut: () -> Void
    
    var body: some View {
        Map(position: $cameraPosition, interactionModes: [.all]) {
            ForEach(venues) { venue in
                Annotation(venue.name, coordinate: venue.coordinate) {
                    Button {
                        onPinTap(venue)
                    } label: {
                        VenuePinView(venue: venue)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(alignment: .topLeading) {
            Text("Drag the map to load venues")
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black.opacity(0.4), in: Capsule())
                .padding(12)
        }
        .mapControls {
            MapCompass()
            MapPitchToggle()
        }
        .overlay(alignment: .bottomTrailing) {
            VStack(spacing: 10) {
                zoomButton(icon: "plus", action: onZoomIn)
                zoomButton(icon: "minus", action: onZoomOut)
            }
            .padding()
        }
        .onMapCameraChange { context in
            onRegionChange(context.region)
        }
    }
    
    private func zoomButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
        }
    }
}

private struct VenuePinView: View {
    let venue: Venue
    
    var body: some View {
        VStack(spacing: 4) {
            Text(venue.name)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(statusColor(for: venue.status))
                        .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 3)
                )
            
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundColor(statusColor(for: venue.status))
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 3)
        }
    }
}

private func statusColor(for status: String) -> Color {
    switch status.lowercased() {
    case "comfy":
        return .green
    case "moderate":
        return .yellow
    case "busy":
        return .red
    default:
        return .gray
    }
}

private struct VenueViewToggle: View {
    @Binding var selection: VenueViewMode
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(VenueViewMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selection = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(selection == mode ? .black : .white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(selection == mode ? Color.white : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.15))
        )
    }
}

private struct VenueCardWithHandle: View {
    let venue: Venue
    let onDismiss: () -> Void
    let onImHere: () -> Void
    let onQRButton: () -> Void
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        VenueCard(
            venue: venue,
            onImHere: onImHere,
            onQRButton: onQRButton
        )
        .overlay(alignment: .top) {
            Capsule()
                .fill(Color.white.opacity(0.9))
                .frame(width: 45, height: 4)
                .padding(.top, 12)
        }
        .offset(y: dragOffset)
        .gesture(
            DragGesture(minimumDistance: 10)
                .updating($dragOffset) { value, state, _ in
                    state = max(0, value.translation.height)
                }
                .onEnded { value in
                    if value.translation.height > 40 {
                        withAnimation(.spring()) {
                            onDismiss()
                        }
                    }
                }
        )
    }
}


struct QRCodeOverlay: View {
    let venueName: String
    let qrImage: UIImage
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // QR Code card
            VStack(spacing: 20) {
                Text("Check-in QR Code")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(venueName)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding()
                
                Text("Show this code at the venue")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
            .padding(30)
            .background(Color(white: 0.15))
            .cornerRadius(20)
            .padding(40)
        }
    }
}

struct CheckInConfirmationOverlay: View {
    let venueName: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Confirmation card
            VStack(spacing: 25) {
                // Success checkmark
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 10)
                
                Text("Checked In!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(venueName)
                    .font(.title3)
                    .foregroundColor(.gray)
                
                Text("You're all set! Enjoy your night.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Info text
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.blue)
                        Text("Your friends can see you're here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                        Text("Check-in time: \(formattedTime())")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)
                
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 5)
            }
            .padding(30)
            .background(Color(white: 0.15))
            .cornerRadius(20)
            .padding(40)
        }
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
}

#Preview {
    VenueListView()
}
