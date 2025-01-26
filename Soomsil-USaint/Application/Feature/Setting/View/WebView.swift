//
//  WebView.swift
//  Soomsil-USaint
//
//  Created by 최지우 on 1/27/25.
//

import SwiftUI
import WebKit

import ComposableArchitecture

struct WebView: View {

    @Perception.Bindable var store: StoreOf<WebReducer>
    
    var body: some View {
        WithPerceptionTracking {
            RepresentableWebView(url: store.url)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    store.send(.dismiss)
                } label: {
                    Image("ic_arrow_left_line")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

struct RepresentableWebView: UIViewRepresentable {
    
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}

#Preview {
    NavigationStack {
        WebView(store: Store(initialState: WebReducer.State(url: URL(string: "https://www.google.com")!), reducer: {
            WebReducer()
        }))

    }
}
