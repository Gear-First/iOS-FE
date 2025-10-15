import SwiftUI

struct StepProgressView<Step: Hashable & Identifiable>: View {
    let steps: [Step]
    let currentStep: Step
    var colorProvider: (Step) -> Color
    var labelProvider: (Step) -> String
    var dates: [OrderStatus: String] = [:]
    var specialStatus: OrderStatus? = nil

    @State private var animatedIndex: Int = 0
    private var inactiveColor: Color = AppColor.lightGray

    // public init으로 외부에서 호출 가능하게
    public init(
        steps: [Step],
        currentStep: Step,
        colorProvider: @escaping (Step) -> Color,
        labelProvider: @escaping (Step) -> String,
        dates: [OrderStatus: String] = [:],
        specialStatus: OrderStatus? = nil
    ) {
        self.steps = steps
        self.currentStep = currentStep
        self.colorProvider = colorProvider
        self.labelProvider = labelProvider
        self.dates = dates
        self.specialStatus = specialStatus
    }

    private var currentIndex: Int {
        steps.firstIndex(of: currentStep) ?? 0
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .center) {
                // 진행선
                HStack(spacing: 0) {
                    ForEach(steps.indices.dropLast(), id: \.self) { index in
                        Rectangle()
                            .fill(
                                specialStatus != nil
                                    ? inactiveColor
                                    : (index < animatedIndex ? colorProvider(steps[index + 1]) : inactiveColor)
                            )
                            .frame(height: 3)
                            .frame(maxWidth: 80)
                            .offset(y: -19.5)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 13)

                // 원 + 라벨 + 날짜
                HStack {
                    ForEach(steps.indices, id: \.self) { index in
                        VStack(spacing: 6) {
                            Circle()
                                .fill(
                                    specialStatus != nil
                                        ? inactiveColor
                                        : (index <= animatedIndex ? colorProvider(steps[index]) : inactiveColor)
                                )
                                .frame(width: 20, height: 20)

                            VStack(spacing: 2) {
                                Text(labelProvider(steps[index]))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColor.mainBlack)
                                
                                if let stepStatus = steps[index] as? OrderStatus {
                                    Text(dates[stepStatus] ?? "")
                                        .font(.caption)
                                        .foregroundColor(AppColor.mainTextGray)
                                }
                            }
                        }
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
