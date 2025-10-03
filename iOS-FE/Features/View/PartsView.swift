//
//  PartsView.swift
//  iOS-FE
//
//  Created by wj on 9/29/25.
//

import SwiftUI

struct PartsView: View {
    @StateObject private var viewModel = PartsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("불러오는 중...")
                } else if let error = viewModel.errorMessage {
                    Text("오류: \(error)")
                        .foregroundColor(.red)
                } else if viewModel.parts.isEmpty {
                    Text("부품이 없습니다.")
                        .foregroundColor(.gray)
                } else {
                    List(viewModel.parts) { part in
                        VStack(alignment: .leading) {
                            Text(part.name)
                                .font(.headline)
                            Text("수량: \(part.quantity)")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("부품 목록")
            .onAppear {
                viewModel.loadParts()
            }
        }
    }
}

#Preview {
    PartsView()
}
