import SwiftUI

struct StepProgressView<Step: Hashable & Identifiable>: View {
    let steps: [Step]                      // 단계 배열
    let currentStep: Step                   // 현재 단계
    var colorProvider: (Step) -> Color     // 각 단계 색상
    var labelProvider: (Step) -> String    // 각 단계 라벨
    var requestDate: Date
    
    @State private var animatedIndex: Int = 0
    private var inactiveColor: Color = AppColor.lightGray
    
    // 외부에서 접근할 수 있는 이니셜라이저 추가
    init(
        steps: [Step],
        currentStep: Step,
        colorProvider: @escaping (Step) -> Color,
        labelProvider: @escaping (Step) -> String
    ) {
        self.steps = steps
        self.currentStep = currentStep
        self.colorProvider = colorProvider
        self.labelProvider = labelProvider
        self.requestDate = Date()
    }
    
    private var currentIndex: Int {
        steps.firstIndex(of: currentStep) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
                  ZStack(alignment: .center) {
                      // 진행선 (뒤쪽)
                      HStack(spacing: 0) {
                          ForEach(steps.indices.dropLast(), id: \.self) { index in
                              Rectangle()
                                  .fill(index < animatedIndex ? colorProvider(steps[index + 1]) : inactiveColor)
                                  .frame(height: 3)
                                  .frame(maxWidth: 80)
                                  .offset(y: -19.5)
                          }
                      }
                      .frame(height: 4)
                      .padding(.horizontal, 13) // 원 크기의 절반 정도 여백
                      
                      // 원 + 라벨 (앞쪽)
                      HStack {
                          ForEach(steps.indices, id: \.self) { index in
                              VStack(spacing: 6) {
                                  Circle()
                                      .fill(index <= animatedIndex ? colorProvider(steps[index]) : inactiveColor)
                                      .frame(width: 20, height: 20)
                                  
                                  VStack(spacing: 2) {
                                      Text(labelProvider(steps[index]))
                                          .font(.subheadline)
                                          .fontWeight(.semibold)
                                          .foregroundColor(AppColor.mainBlack)
                                      Text("25-01-01")
                                          .font(.caption)
                                          .foregroundColor(AppColor.mainTextGray)
                                  }
                              }
                              // 원 사이 간격 균등하게
                              .frame(maxWidth: .infinity)
                          }
                      }
                  }
                  .frame(maxWidth: .infinity)
              }
              .padding(.horizontal, 16)
              .onAppear {
                  withAnimation(.easeInOut(duration: 0.8)) {
                      animatedIndex = currentIndex
                  }
              }
              .onChange(of: currentStep) { newValue in
                  withAnimation(.easeInOut(duration: 0.8)) {
                      animatedIndex = steps.firstIndex(of: newValue) ?? 0
                  }
              }
          }
      }

      // MARK: - 프리뷰
      struct StepProgressView_Previews: PreviewProvider {
          static var previews: some View {
              StepProgressView(
                  steps: OrderStatus.allCases.filter { $0.progressValue > 0 },
                  currentStep: .출고중,
                  colorProvider: { _ in AppColor.mainBlue },
                  labelProvider: { $0.rawValue }
              )
              .frame(height: 120)
              .padding()
          }
      }
