//
//  ContentView.swift
//  LiveTextDemo
//
//  Created by Itsuki on 2025/10/08.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("""
            **A demo of Enabling Live Text interactions with images with 2 Approaches.**
            """)
            
            VStack(spacing: 16)  {
                Text("""
                **Built-in version**
                    - Uses `UIViews` and `VisionKit`, ie: `ImageAnalysisInteraction` and related classes
                    - Support Text and BarCode Detection
                    - Support Interactions such as text selection, Data detection, visual look up and etc.
                """)
                .frame(maxWidth: .infinity)

                NavigationLink(destination: {
                    BuiltInLiveTextDemo()
                }, label: {
                    Text("Built-in")
                        .padding(.horizontal, 8)
                })
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 16)  {
                
                Text("""
            **Custom Version**
                - Use SwiftUI, Vision, and `NSDataDetector`
                - Able to support any `VisionRequest`
                - Able to add interactions based on our needs. Copy, Open URL, and etc.
                - Able to customize UI.
                - Full control of the analysis process 
                - Easier to support both still images and live capture.
            """)
                
                
                NavigationLink(destination: {
                    CustomLiveTextDemo()
                }, label: {
                    Text("Custom")
                        .padding(.horizontal, 8)
                })
                
            }
            .frame(maxWidth: .infinity)


            
        }
        .font(.subheadline)
        .lineSpacing(8)
        .buttonStyle(.glassProminent)
        .padding()
        .navigationTitle("Live Text Demo")
        .buttonStyle(.glass)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.yellow.opacity(0.1))

    }
}
