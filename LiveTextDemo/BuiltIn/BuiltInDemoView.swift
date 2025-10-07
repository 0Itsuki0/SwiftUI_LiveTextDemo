//
//  BuiltInLiveTextDemo.swift
//  LiveTextDemo
//
//  Created by Itsuki on 2025/10/05.
//

import SwiftUI
import VisionKit


struct BuiltInLiveTextDemo: View {
    @State private var image: UIImage?
    @State private var error: Error?

    var body: some View {
        VStack {
            // Check whether the device supports Live Text
            if !ImageAnalyzer.isSupported {
                ContentUnavailableView("Not Supported", systemImage: "rectangle.on.rectangle.slash.fill")
            }
                        
            LiveTextImageView(image: $image, error: $error)
                .fixedSize(horizontal: false, vertical: true)

        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.yellow.opacity(0.1))
        .navigationTitle("BuiltIn Live Text")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            guard let url = Bundle.main.url(forResource: "sample", withExtension: "jpg"),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data) else {
                return
            }
            self.image = image
        }
    }
}


struct LiveTextImageView: UIViewRepresentable {
    
    @Binding var image: UIImage?
    @Binding var error: Error?
    
    private let imageView = UIImageView()
    private let analyzer = ImageAnalyzer()
    private let interaction = ImageAnalysisInteraction()
    
    private var configuration: ImageAnalyzer.Configuration {
        // Find items and start the interaction with an image
        // For iOS apps, the analyzer recognizes both text and machine-readable QR codes in an image; for macOS apps, the analyzer recognizes text in an image.
        // visualLookUp and machineReadableCode will not work on simulators
        var configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode, .visualLookUp])
        // By default the image analyzer attempts to recognize the user’s preferred languages. If you want the analyzer to consider other languages, set the locales property of the ImageAnalyzer.Configuration object.
        configuration.locales = ImageAnalyzer.supportedTextRecognitionLanguages
        return configuration
    }
  
    
    func makeUIView(context: Context) -> UIImageView {
        self.interaction.delegate = context.coordinator
        
        self.imageView.image = self.image
        self.imageView.addInteraction(self.interaction)
        self.imageView.contentMode = .scaleAspectFit

        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        guard let image = self.image else {
            return
        }
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        uiView.image = image
        
        self.interaction.preferredInteractionTypes = []
        // invalidate previous analysis
        self.interaction.analysis = nil

        context.coordinator.analyzerTask?.cancel()
        context.coordinator.analyzerTask = Task {
            do {
                let analysis = try await analyzer.analyze(image, configuration: configuration)
                self.interaction.analysis = analysis
                
                // Configure ImageAnalysisInteraction
                //
                // IMPORTANT: preferredInteractionTypes Has to be set after setting the analysis.
                // Otherwise, we won't able to perform any interactions.
                //
                // automatic: To recognize all types of content, specify the automatic option,
                // or choose a combination of types by assigning an array: ex: [.textSelection, .imageSubject, .visualLookUp]
                self.interaction.preferredInteractionTypes = [.automatic]
                self.interaction.allowLongPressForDataDetectorsInTextMode = true
                
            } catch {
                self.error = error
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
        
    
    // ImageAnalysisInteractionDelegate: handles image-analysis and user-interaction callbacks for an interaction object
    // https://developer.apple.com/documentation/visionkit/imageanalysisinteractiondelegate
    class Coordinator: NSObject, ImageAnalysisInteractionDelegate {
        var analyzerTask: Task<Void, Error>?

        // MARK: Providing interface details
        // Not needed if using an UIImageView.
        // If not using a UIImageView object, inform the interaction object when the content area of the image changes while the interaction bounds don’t change. Implement the ImageAnalysisInteractionDelegate contentsRect(for:) protocol method to return the content area of the image. This keeps the Live Text highlights within the bounds of the image. Then use the setContentsRectNeedsUpdate() method to notify the interaction if the content area changes.
        
        // func contentView(for: ImageAnalysisInteraction) -> UIView?
        // Provides the view that contains the image.

        // func contentsRect(for: ImageAnalysisInteraction) -> CGRect
        // Returns the rectangle, in unit coordinates, that contains the image within the view.

        // func presentingViewController(for: ImageAnalysisInteraction) -> UIViewController?
        // Provides the view controller that presents the interface objects.

        
        // MARK: Starting the interaction
        // Provides a Boolean value that indicates whether the interaction can begin at the given point
        func interaction(_ interaction: ImageAnalysisInteraction, shouldBeginAt point: CGPoint, for interactionType: ImageAnalysisInteraction.InteractionTypes) -> Bool {
            return true
        }
        

        // MARK: Tracking interface changes
        // Notifies your app when the Live Text button’s visibility changes.
        func interaction(_ interaction: ImageAnalysisInteraction, liveTextButtonDidChangeToVisible visible: Bool) {
            print(#function)
        }
        
        // Notifies your app when recognized items in the image appear highlighted as a result of a person tapping the Live Text button.
        func interaction(_ interaction: ImageAnalysisInteraction, highlightSelectedItemsDidChange highlightSelectedItems: Bool) {
            print(#function)
        }
        
        // Notifies your app when the interaction's text selection changes
        func textSelectionDidChange(_ interaction: ImageAnalysisInteraction) {
            print(#function)
            print("selected Text: \(interaction.selectedText)")
            // to control text selection programmatically
            // - selectedRanges: Sets selected text ranges
            // - resetTextSelection(): Removes a person’s text selection from the interface.
        }

    }
}


#Preview {
    BuiltInLiveTextDemo()
}
