import SwiftUI
import CoreImage.CIFilterBuiltins

struct Venue: Identifiable {
    let id = UUID()
    let name: String
    let distance: String
    let waitTime: String
    let status: String
    let musicGenre: String
    let soundLevel: String
}

struct VenueListView: View {
    @State private var venues = [
        Venue(name: "The Velvet Room", distance: "0.3 mi", waitTime: "0-5 min", 
              status: "Comfy", musicGenre: "R&B DJ", soundLevel: "moderate"),
        Venue(name: "Neon Pulse", distance: "0.5 mi", waitTime: "10-15 min", 
              status: "Busy", musicGenre: "EDM", soundLevel: "loud"),
        Venue(name: "Socialista", distance: "0.6 mi", waitTime: "5-10 min", 
              status: "Moderate", musicGenre: "Latin", soundLevel: "loud"),
        Venue(name: "Paul's Baby Grand", distance: "0.8 mi", waitTime: "0-5 min", 
              status: "Comfy", musicGenre: "Live Jazz", soundLevel: "moderate"),
        Venue(name: "The Jazz Corner", distance: "0.9 mi", waitTime: "5-10 min", 
              status: "Moderate", musicGenre: "Live Jazz", soundLevel: "moderate"),
        Venue(name: "Rooftop Lounge", distance: "1.2 mi", waitTime: "15-20 min", 
              status: "Busy", musicGenre: "House", soundLevel: "loud"),
        Venue(name: "Warehouse on Watts", distance: "1.4 mi", waitTime: "20-25 min", 
              status: "Busy", musicGenre: "Techno", soundLevel: "loud"),
        Venue(name: "The Dive Bar", distance: "1.5 mi", waitTime: "0-5 min", 
              status: "Comfy", musicGenre: "Rock Cover Band", soundLevel: "moderate"),
        Venue(name: "Silk Nightclub", distance: "1.7 mi", waitTime: "25-30 min", 
              status: "Busy", musicGenre: "Top 40", soundLevel: "loud"),
        Venue(name: "The Library Lounge", distance: "1.9 mi", waitTime: "5-10 min", 
              status: "Moderate", musicGenre: "Acoustic", soundLevel: "moderate")
    ]
    
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
                
                // Venue List
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
                }
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
    
    func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "comfy":
            return .green
        case "moderate":
            return .orange
        case "busy":
            return .orange
        default:
            return .gray
        }
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
