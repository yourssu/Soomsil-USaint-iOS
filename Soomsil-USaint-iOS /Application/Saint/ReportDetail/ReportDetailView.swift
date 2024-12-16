//
//  ReportDetailView.swift
//  Soomsil
//
//  Created by 정종인 on 2023/06/02.
//  Copyright © 2023 Yourssu. All rights reserved.
//

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

struct ReportDetailView<VM: ReportDetailViewModel>: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var reportDetailViewModel: VM
    @State private var viewOrigin: CGPoint = Origin.entireView
    @State private var viewSize: CGSize = Size.entireView
    @State private var isShowSummary: Bool = true
    init(reportDetailViewModel: VM, isShowSummary: Bool = true) {
        self._reportDetailViewModel = StateObject(wrappedValue: reportDetailViewModel)
        self.isShowSummary = isShowSummary
    }
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: Spacing.mainVStack) {
                    Text("\(reportDetailViewModel.report.year)년 \(reportDetailViewModel.report.semester)")
                        .font(YDSFont.subtitle2)
                    if isShowSummary, reportDetailViewModel.report.semesterGPA != 0 {
                        HStack(alignment: .lastTextBaseline) {
                            Text(String(format: "%.2f", reportDetailViewModel.report.semesterGPA))
                                .font(YDSFont.display1)
                            Text("/ 4.50")
                                .foregroundColor(YDSColor.textTertiary)
                        }
                        GradeOverview(
                            title: "취득 학점",
                            accentText: "\(Int(reportDetailViewModel.report.credit.rounded()))"
                        )
                        GradeOverview(
                            title: "학기별 석차",
                            accentText: reportDetailViewModel.report.semesterRank.0,
                            subText: reportDetailViewModel.report.semesterRank.1
                        )
                        GradeOverview(
                            title: "전체 석차",
                            accentText: reportDetailViewModel.report.totalRank.0,
                            subText: reportDetailViewModel.report.semesterRank.1
                        )
                    }
                    Divider()
                    if let reportDetail = reportDetailViewModel.reportDetail {
                        ForEach(Array(reportDetail.lectures.enumerated()), id: \.offset) { index, lecture in
                            if reportDetailViewModel.masking {
                                MaskedGradeRow(grade: lecture.grade)
                            } else {
                                GradeRow(
                                    lectureName: lecture.title,
                                    professor: lecture.professorName,
                                    credit: lecture.credit,
                                    grade: lecture.grade
                                )
                                .offset(x: reportDetailViewModel.rowAnimation ? 0 : 100)
                                .opacity(reportDetailViewModel.rowAnimation ? 1 : 0)
                                .animation(
                                    .easeIn
                                        .delay(Double(index) * 0.1)
                                        .speed(0.5),
                                    value: reportDetailViewModel.rowAnimation
                                )
                                .onAppear {
                                    withAnimation {
                                        reportDetailViewModel.rowAnimation = true
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
                    .opacity(reportDetailViewModel.isCapturing ? 1 : 0)
            }
        }
        .background(YDSColor.bgElevated)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if #available(iOS 15.0, *) {
                    Button(action: reportDetailViewModel.takeScreenshot) {
                        YDSIcon.cameraLine
                            .renderingMode(.template)
                            .foregroundColor(YDSColor.buttonNormal)
                    }
                    .confirmationDialog(
                        "강의 정보를 가리고 저장할까요?",
                        isPresented: $reportDetailViewModel.showConfirmDialog,
                        actions: {
                            Button("강의 정보 가리고 저장") {
                                reportDetailViewModel.takeScreenshotWithMasking {
                                    self.screenshot()
                                }
                            }
                            Button("원본으로 저장") {
                                reportDetailViewModel.takeScreenshotWithoutMasking {
                                    self.screenshot()
                                }
                            }
                        }
                    )
                    .alert("저장 완료", isPresented: $reportDetailViewModel.showSuccessAlert, actions: {})
                    .alert("저장 실패", isPresented: $reportDetailViewModel.showFailureAlert, actions: {})
                }
                Button {
                    Task {
                        switch await reportDetailViewModel.getSingleReportFromSN() {
                        case .success(let success):
                            reportDetailViewModel.reportDetail = success
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
                switch await reportDetailViewModel.getSingleReport() {
                case .success(let success):
                    reportDetailViewModel.reportDetail = success
                    YDSToast("가져오기 성공!", haptic: .success)
                case .failure(let failure):
                    YDSToast("가져오기 실패 : \(failure)", haptic: .failed)
                }
            }
        }
        .registerYDSToast()
        #if APPCLIP
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
        #endif
    }
    private func screenshot() {
//        self.screenShot(origin: viewOrigin, size: viewSize) {
//            reportDetailViewModel.takeScreenshotSuccess()
//        } failure: {
//            reportDetailViewModel.takeScreenshotFailure()
//        }
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

struct ReportDetailView_Previews: PreviewProvider {
    @State private var report = ReportSummaryModel([:])!
    static var previews: some View {
        ReportDetailView<TestReportDetailViewModel>(reportDetailViewModel: TestReportDetailViewModel())
    }
}
