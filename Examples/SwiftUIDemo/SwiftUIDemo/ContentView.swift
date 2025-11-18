//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by Nexios Technologies on 18/11/25.
//

import SwiftUI
import ASKRatingKit

struct ContentView: View {
    var body: some View {
        Button("Ask for Rating") {
            ASKRatingKit.shared.requestRatingIfNeeded()
        }
    }
}

#Preview {
    ContentView()
}
