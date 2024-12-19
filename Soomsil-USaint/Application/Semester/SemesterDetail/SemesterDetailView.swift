//
//  SemesterDetailView.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/17/24.
//

//struct SemesterDetailView<VM: SemesterDetailViewModel>: View {
//    @StateObject private var semesterDetailViewModel: VM
//    @State private var isShowSummary: Bool = true
//    init(semesterDetailViewModel: VM, isShowSummary: Bool = true) {
//        self._semesterDetailViewModel = StateObject(wrappedValue: semesterDetailViewModel)
//        self.isShowSummary = isShowSummary
//    }
//    
//    var body: some View {
//        ScrollView {
//            ZStack(alignment: .bottomTrailing) {
//                
//            }
//        }
//    }
//}

import SwiftUI
import YDS_SwiftUI

private enum Dimension {
    enum Spacing {
        static let mainVStack = 16.0
    }

    enum Size {
        static let stampImage = 130.0
        static let entireView = UIScreen.main.bounds.size
    }

    enum Padding {
        static let `default` = 16.0
    }

    enum Origin {
        static let entireView = UIScreen.main.bounds.origin
    }
}

private typealias Spacing = Dimension.Spacing
private typealias Size = Dimension.Size
private typealias Padding = Dimension.Padding
private typealias Origin = Dimension.Origin

struct SemesterDetailView<VM: SemesterDetailViewModel>: View {
    @Binding var path: [StackView]
    @Environment(\.dismiss) var dismiss
    @StateObject var semesterDetailViewModel: VM
    @State private var viewOrigin: CGPoint = Origin.entireView
    @State private var viewSize: CGSize = Size.entireView
    var isShowSummary: Bool = true
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: Spacing.mainVStack) {
                    Text("\(semesterDetailViewModel.report.year)년 \(semesterDetailViewModel.report.semester)")
                        .font(YDSFont.subtitle2)
                    if isShowSummary, semesterDetailViewModel.report.gpa != 0 {
                        HStack(alignment: .lastTextBaseline) {
                            Text(String(format: "%.2f", semesterDetailViewModel.report.gpa))
                                .font(YDSFont.display1)
                            Text("/ 4.50")
                                .foregroundColor(YDSColor.textTertiary)
                        }
                        GradeOverview(
                            title: "취득 학점",
                            accentText: "\(Int(semesterDetailViewModel.report.earnedCredit.rounded()))"
                        )
                        GradeOverview(
                            title: "학기별 석차",
                            accentText: "\(semesterDetailViewModel.report.semesterRank)",
                            subText: "\(semesterDetailViewModel.report.semesterStudentCount)"
                        )
                        GradeOverview(
                            title: "전체 석차",
                            accentText: "\(semesterDetailViewModel.report.overallRank)",
                            subText: "\(semesterDetailViewModel.report.overallStudentCount)"
                        )
                    }
                    Divider()
                    if let reportDetail = semesterDetailViewModel.reportDetail {
                        ForEach(Array(reportDetail.lectures.enumerated()), id: \.offset) { index, lecture in
                            if semesterDetailViewModel.masking {
                                MaskedGradeRow(grade: lecture.grade)
                            } else {
                                GradeRow(
                                    lectureName: lecture.title,
                                    professor: lecture.professorName,
                                    credit: lecture.credit,
                                    grade: lecture.grade
                                )
                                .offset(x: semesterDetailViewModel.rowAnimation ? 0 : 100)
                                .opacity(semesterDetailViewModel.rowAnimation ? 1 : 0)
                                .animation(
                                    .easeIn
                                        .delay(Double(index) * 0.1)
                                        .speed(0.5),
                                    value: semesterDetailViewModel.rowAnimation
                                )
                                .onAppear {
                                    withAnimation {
                                        semesterDetailViewModel.rowAnimation = true
                                    }
                                }
                            }
                        }
                    } else {
                        HStack {
                            Spacer()
                            Text("세부 성적을 불러오려면 새로고침을 터치해주세요.")
                            Spacer()
                        }
                    }
                }
                .padding(Padding.default)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                adjustScreenshotSize(proxy)
                            }
                    }
                        .padding(.horizontal, -Padding.default) // size 측정 시 버그(약간 축소되어 측정 됨) 때문에 임시방편으로 설정.
                )

                Image("ppussungStamp")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(maxWidth: Size.stampImage, maxHeight: Size.stampImage)
                    .padding(.trailing, Padding.default)
                    .opacity(semesterDetailViewModel.isCapturing ? 1 : 0)
            }
        }
        .background(YDSColor.bgElevated)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if #available(iOS 15.0, *) {
                    Button(action: semesterDetailViewModel.takeScreenshot) {
                        YDSIcon.cameraLine
                            .renderingMode(.template)
                            .foregroundColor(YDSColor.buttonNormal)
                    }
                    .confirmationDialog(
                        "강의 정보를 가리고 저장할까요?",
                        isPresented: $semesterDetailViewModel.showConfirmDialog,
                        actions: {
                            Button("강의 정보 가리고 저장") {
                                semesterDetailViewModel.takeScreenshotWithMasking {
                                    self.screenshot()
                                }
                            }
                            Button("원본으로 저장") {
                                semesterDetailViewModel.takeScreenshotWithoutMasking {
                                    self.screenshot()
                                }
                            }
                        }
                    )
                    .alert("저장 완료", isPresented: $semesterDetailViewModel.showSuccessAlert, actions: {})
                    .alert("저장 실패", isPresented: $semesterDetailViewModel.showFailureAlert, actions: {})
                }
                Button {
                    Task {
                        switch await semesterDetailViewModel.getSingleReportFromSN() {
                        case .success(let success):
                            semesterDetailViewModel.reportDetail = success
                            YDSToast("가져오기 성공!", haptic: .success)
                        case .failure(let failure):
                            YDSToast("가져오기 실패 : \(failure)", haptic: .failed)
                        }
                    }
                } label: {
                    YDSIcon.refreshLine
                        .renderingMode(.template)
                        .foregroundColor(YDSColor.buttonNormal)
                }
            }
        }
        .onAppear {
            Task {
                switch await semesterDetailViewModel.getSingleReport() {
                case .success(let success):
                    semesterDetailViewModel.reportDetail = success
                    YDSToast("가져오기 성공!", haptic: .success)
                case .failure(let failure):
                    YDSToast("가져오기 실패 : \(failure)", haptic: .failed)
                }
            }
        }
        .registerYDSToast()
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image("ic_arrow_left_line")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
    private func screenshot() {
        self.screenShot(origin: viewOrigin, size: viewSize) {
            semesterDetailViewModel.takeScreenshotSuccess()
        } failure: {
            semesterDetailViewModel.takeScreenshotFailure()
        }
    }

    private func adjustScreenshotSize(_ proxy: GeometryProxy) {
        DispatchQueue.main.async {
            if proxy.size != .zero {
                self.viewOrigin = proxy.frame(in: SwiftUI.CoordinateSpace.local).origin
                self.viewSize = proxy.size
            }
        }
    }
}
//
//struct ReportDetailView_Previews: PreviewProvider {
////    @State private var report = GradeSummaryModel([:])!
//    static var previews: some View {
//        SemesterDetailView<TestSemesterDetailViewModel>(semesterDetailViewModel: TestSemesterDetailViewModel())
//    }
//}
