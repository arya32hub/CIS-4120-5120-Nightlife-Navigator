import SwiftUI

struct HelloStylesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Style Guide Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                // COLORS
                VStack(alignment: .leading, spacing: 15) {
                    Text("Colors")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Primary background
                    HStack {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                        Text("Background: Black (#000000)")
                            .foregroundColor(.white)
                    }
                    
                    // Card background
                    HStack {
                        Rectangle()
                            .fill(Color(white: 0.15))
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                        Text("Card Background: Dark Gray")
                            .foregroundColor(.white)
                    }
                    
                    // Primary action color
                    HStack {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                        Text("Primary Action: Blue (#007AFF)")
                            .foregroundColor(.white)
                    }
                    
                    // Status colors
                    HStack {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                        Text("Status - Comfy: Green")
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                        Text("Status - Busy: Orange")
                            .foregroundColor(.white)
                    }
                }
                
                Divider()
                    .background(Color.gray)
                
                // TYPOGRAPHY
                VStack(alignment: .leading, spacing: 15) {
                    Text("Typography")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Large Title - Bold")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Title - Bold")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Title 2 - Semibold")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Title 3 - Semibold")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Headline - Semibold")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Subheadline - Regular")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Body - Regular")
                        .font(.body)
                        .foregroundColor(.white)
                }
                
                Divider()
                    .background(Color.gray)
                
                // ICONS (SF Symbols)
                VStack(alignment: .leading, spacing: 15) {
                    Text("Icons (SF Symbols)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "location.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            Text("Location")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "clock")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            Text("Time")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "music.note")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            Text("Music")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.orange)
                            Text("Sound")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "qrcode")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            Text("QR Code")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 30))
                                .foregroundColor(.gray)
                            Text("Search")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            Text("Filter")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "eye")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            Text("View")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Divider()
                    .background(Color.gray)
                
                // COMPONENTS
                VStack(alignment: .leading, spacing: 15) {
                    Text("Components")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    // Status badge
                    HStack {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Comfy")
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(16)
                    
                    // Primary button
                    Button(action: {}) {
                        Text("Primary Button")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    // Circular icon button
                    Button(action: {}) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("Search venues")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Color(white: 0.15))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    HelloStylesView()
}
