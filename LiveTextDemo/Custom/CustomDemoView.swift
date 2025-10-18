//
//  ContentView.swift
//  LiveTextDemo
//
//  Created by Itsuki on 2025/10/05.
//

import SwiftUI
import Vision
import DataDetection

struct CustomLiveTextDemo: View {
    @Environment(\.openURL) private var openURL
    
    @State private var manager = LiveTextManager()
    
    @State private var imageSize: CGSize = .zero
    
    @State private var isProcessing: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 36) {
                if let url = Bundle.main.url(forResource: "sample", withExtension: "jpg"), let data = try? Data(contentsOf: url), let image = Image(data: data) {
                    
                    HStack {
                        HStack {
                            Text("Detection Config")
                                .fontWeight(.semibold)
                            Picker(selection: $manager.detectionConfiguration, content: {
                                Text("All")
                                    .tag(DetectionConfiguration.all)
                                Text("Barcode")
                                    .tag(DetectionConfiguration.barcode)
                                Text("Text")
                                    .tag(DetectionConfiguration.text)
                            }, label: { })
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                self.isProcessing = true
                                do {
                                    try await manager.analyze(data)
                                } catch(let error) {
                                    manager.error = error
                                }
                                self.isProcessing = false
                            }
                        }, label: {
                            Text("Detect")
                        })
                        .disabled(self.isProcessing)
                        .buttonStyle(.borderedProminent)

                    }
                    .padding(.horizontal, 8)
                    .font(.subheadline)
                    
                    
                    image
                        .resizable()
                        .scaledToFit()
                        .border(.red)
                        .onGeometryChange(for: CGSize.self, of: {
                            $0.size
                        }, action: { old, new in
                            self.imageSize = new
                        })
                        .overlay(content: {
                            if isProcessing {
                                ProgressView()
                                    .tint(.pink)
                                    .controlSize(.extraLarge)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 4).fill(.gray.opacity(0.8)))
                            }
                        })
                        .overlay(alignment: .center, content: {
                            ForEach(0..<manager.observationResults.count, id: \.self) { index in
                                let result: ObservationResult = manager.observationResults[index]
                                let points = result.boundingQuad

                                let path = Path { path in
                                    
                                    path.move(to: points.topLeft.toImageCoordinates(self.imageSize, origin: .upperLeft))
                                    path.addLine(to: points.topRight.toImageCoordinates(self.imageSize, origin: .upperLeft))
                                    path.addLine(to: points.bottomRight.toImageCoordinates(self.imageSize, origin: .upperLeft))

                                    path.addLine(to: points.bottomLeft.toImageCoordinates(self.imageSize, origin: .upperLeft))
                                    path.closeSubpath()
                                }
                                    
                                let contentShape: ShapeFromPath = ShapeFromPath(path: path)

                                Menu(content: {
                                    let string = result.string
                                    
                                    Text(string)
                                    
                                    Button(action: {
                                        UIPasteboard.general.string = string
                                    }, label: {
                                        Image(systemName: "document.on.document")
                                        Text("Copy")
                                    })

                                    let urls = extractLinkFromData(result.extractedData)
                                    
                                    Section("Open URLs") {
                                        ForEach(urls, id: \.self) { url in
                                            Button(action: {
                                                openURL(url)
                                            }, label: {
                                                Text(url.absoluteString)
                                            })
                                        }
                                    }
                                }, label: {
                                    path
                                        .fill(.clear)
                                        .stroke(.blue, style: .init(lineWidth: 4))
                                })
                                .buttonStyle(.plain)
                                .contentShape(contentShape)
                            

                            }

                        })
                    
                    if let error = manager.error {
                        Text(String("\(error)"))
                            .foregroundStyle(.red)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                    self.manager.error = nil
                                })
                            }
                    }
                    
                    let extractedData = manager.observationResults.flatMap(\.extractedData)
                    if !extractedData.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Extracted Data")
                                .font(.headline)
                            
                            self.extractedDataView(extractedData)
                                .padding(.horizontal, 8)

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                        
                    
                }
                    
            }
            .padding()
            .scrollTargetLayout()

        }
        .background(.yellow.opacity(0.1))
        .navigationTitle("Custom Live Text")
        .navigationBarTitleDisplayMode(.large)

    }
    
    private func extractLinkFromData(_ extractedData: [DataDetector.Match]) -> [URL] {
            
        var urls: [URL] = []
        for data in extractedData {
            if case .link(let link) = data.details {
                urls.append(link.url)
            }
        }
        return Array(Set(urls))
    }

    
    private func extractedDataView(_ extractedData: [DataDetector.Match]) -> some View {
        ForEach(0..<extractedData.count, id: \.self) { index in
            
            let result: DataDetector.Match = extractedData[index]
            switch result.details {
            case .calendarEvent(let calendar):
                titleText("Calendar Event")
                Text(String("All day event: \(calendar.allDay)"))
                HStack {
                    if let start = calendar.startDate {
                        Text(String("Start: \(start)"))
                    }
                    if let end = calendar.endDate {
                        Text(String("End: \(end)"))
                    }
                }
            case .link(let link):
                titleText("URL")
                Text(link.url.absoluteString)

            case .emailAddress(let email):
                titleText("Email")
                Text(email.emailAddress)
                
            case .phoneNumber(let phone):
                titleText("Phone Number")
                Text(phone.phoneNumber)
                
            case .postalAddress(let postal):
                titleText("Postal")
                Text(postal.fullAddress)
                
            case .moneyAmount(let money):
                titleText("Money")
                Text(String("\(money.amount) (\(money.currency.identifier))"))
                
            case .flightNumber(let flight):
                titleText("Flight Number")
                Text("\(flight.airlineCode) \(flight.flightNumber)")
                
            case .shipmentTrackingNumber(let tracking):
                titleText("Shipment Tracking")
                Text("\(tracking.carrier) \(tracking.trackingNumber)")
                if let url = tracking.trackingURL {
                    Button(action: {
                        openURL(url)
                    }, label: {
                        Text("Track Shipment")
                    })
                }
                
            case .measurement(let measurement):
                titleText("Measurement")
                Text("\(measurement.value)")

            case .paymentIdentifier(let payment):
                titleText("Payment Identifier")
                Text("\(payment.identifier)")

            @unknown default:
                EmptyView()
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    
    private func titleText(_ text: any StringProtocol) -> some View {
        Text(text)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)

    }
}


private struct ShapeFromPath: Shape {
    var path: Path
    
    func path(in rect: CGRect) -> Path {
        return path
    }
}



private extension Image {
    init?(data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        self = Image(uiImage: uiImage)
    }
}

