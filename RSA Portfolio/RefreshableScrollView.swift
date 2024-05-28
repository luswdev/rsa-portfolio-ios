//
//  RefreshableScrollView.swift
//  RSA Portfolio
//
//  Created by Skywalker on 2024/5/26.
//

import Foundation
import SwiftUI

struct RefreshableScrollView<Content: View>: View {
    var onRefresh: () -> Void
    var content: Content

    @State private var offsetY: CGFloat = 0
    @State private var isRefreshing = false

    init(onRefresh: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }

    var body: some View {
        CustomScrollView(content: content, onOffsetChange: { offset in
            self.offsetY = offset
            if !self.isRefreshing && offset < -100 {
                self.isRefreshing = true
                self.onRefresh()
            }
        })
        .overlay(
            isRefreshing ? ProgressView() : nil
        )
    }
}

struct CustomScrollView<Content: View>: UIViewRepresentable {
    var content: Content
    var onOffsetChange: (CGFloat) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = false

        let hostedView = UIHostingController(rootView: content)
        hostedView.view.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(hostedView.view)

        NSLayoutConstraint.activate([
            hostedView.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostedView.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostedView.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostedView.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostedView.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.parent = self
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: CustomScrollView

        init(_ parent: CustomScrollView) {
            self.parent = parent
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            parent.onOffsetChange(scrollView.contentOffset.y)
        }
    }
}
