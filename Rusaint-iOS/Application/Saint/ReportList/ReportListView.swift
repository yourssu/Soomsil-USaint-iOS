//
//  ReportListView.swift
//  Soomsil
//
//  Created by 정종인 on 2023/06/01.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import Charts
import SwiftUI
import YDS_SwiftUI
import SaintNexus
#if APPCLIP
import StoreKit
#endif
import Rusaint

struct ReportListView<VM: ReportListViewModel>: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State private var rowAnimation = false
    @StateObject var reportListViewModel: VM

    private let years = (2010...(Calendar.current.component(.year, from: Date())))
        .map { "\($0)"}
    @State private var yearSelection: String = "\(Calendar.current.component(.year, from: Date()))"
    private let semesters = ["1 학기", "여름학기", "2 학기", "겨울학기"]
    @State private var semesterSelection: String = "1 학기"
    @State private var isShowingCustomReport: Bool = true
#if APPCLIP
    @State private var presentingAppStoreOverlay = false
#endif

    @State private var session: USaintSession? = nil
    @State private var semesterGrades: [SemesterGrade?]? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    let list = reportListViewModel.reportList
                    let average = list.averageGPA
                    let sum = list.reduce(0.0) { partialResult, report in
                        partialResult + report.credit
                    }
                    EmphasizedView(title: "평점 평균", emphasized: String(format: "%.2f", average), sub: "4.50")
                    EmphasizedView(title: "취득 학점", emphasized: String(format: "%.1f", sum), sub: "133")
                }
                VStack(alignment: .trailing, spacing: 18) {
                    GPAGraph(
                        gpaList: reportListViewModel.reportList.sortedAscending()
                            .filter {
                                ($0.semester != "겨울학기" && $0.semester != "여름학기")
                                || reportListViewModel.isOnSeasonalSemester
                            }
                            .map {
                                GPAGraph.GPAInfo(semester: "\($0.year)년 \($0.semester)", gpa: $0.semesterGPA)
                            }
                    )
                    Button {
                        reportListViewModel.isOnSeasonalSemester.toggle()
                    } label: {
                        HStack(spacing: 4) {
                            YDSIcon.checkcircleLine
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 16, height: 16)
                            Text("계절학기 포함")
                                .font(YDSFont.button4)
                        }
                        .foregroundStyle(
                            reportListViewModel.isOnSeasonalSemester
                            ? YDSColor.buttonPoint
                            : YDSColor.buttonDisabled
                        )
                    }
                }
            }
            .padding()
            Rectangle()
                .frame(height: 8.0)
                .foregroundColor(YDSColor.borderThin)
            VStack(alignment: .leading) {
                if isShowingCustomReport {
                    HStack {
                        Picker("", selection: $yearSelection) {
                            ForEach(years, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        Picker("", selection: $semesterSelection) {
                            ForEach(semesters, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.wheel)
                        .labelsHidden()
                        NavigationLink {
                            if let reportSummary = SaintRepository.shared.getReportSummaryList()
                                .first(where: { reportModel in
                                    reportModel.year == yearSelection
                                    && reportModel.semester == semesterSelection
                                }) {
                                ReportDetailView(
                                    reportDetailViewModel: DefaultReportDetailViewModel(
                                        report: reportSummary
                                    )
                                )
                            } else {
                                ReportDetailView(reportDetailViewModel: DefaultReportDetailViewModel(
                                    report: .init(
                                        year: yearSelection,
                                        semester: semesterSelection
                                    )
                                ), isShowSummary: false)
                            }
                        } label: {
                            YDSIcon.arrowRightLine
                                .renderingMode(.template)
                                .foregroundColor(YDSColor.buttonNormal)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.plain)
                    .zIndex(2)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(YDSColor.buttonPoint)
                    }
                    .transition(.opacity.animation(.easeInOut))
                    .animation(.easeIn, value: isShowingCustomReport)
                }
                ForEach(
                    Array(reportListViewModel.reportList.sortedAscending().enumerated()),
                    id: \.offset
                ) { index, report in
                    NavigationLink {
                        ReportDetailView(reportDetailViewModel: DefaultReportDetailViewModel(report: report))
                    } label: {
                        ReportRow(reportListModel: report)
                            .offset(x: self.rowAnimation ? 0 : 100)
                            .opacity(self.rowAnimation ? 1 : 0)
                            .animation(
                                .easeIn
                                    .delay(Double(index) * 0.1)
                                    .speed(0.5),
                                value: self.rowAnimation
                            )
                            .onAppear {
                                withAnimation {
                                    self.rowAnimation = true
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
#if APPCLIP
                Text(verbatim: "App Store Overlay")
                    .hidden()
                    .appStoreOverlay(isPresented: $presentingAppStoreOverlay) {
                        SKOverlay.AppClipConfiguration(position: .bottom)
                    }
#endif
            }
            .animation(.easeInOut, value: isShowingCustomReport)
            .padding()
        }
        .background(YDSColor.bgElevated)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    isShowingCustomReport.toggle()
                } label: {
                    if isShowingCustomReport {
                        YDSIcon.eyeopenLine
                            .renderingMode(.template)
                            .foregroundColor(YDSColor.buttonNormal)
                    } else {
                        YDSIcon.eyeclosedLine
                            .renderingMode(.template)
                            .foregroundColor(YDSColor.buttonNormal)
                    }
                }
                Button {
                    Task {
                        switch await reportListViewModel.getReportListFromSN() {
                        case .success(let success):
                            reportListViewModel.reportList = success
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
                switch await reportListViewModel.getReportList() {
                case .success(let success):
                    reportListViewModel.reportList = success
                case .failure(let failure):
                    YDSToast("가져오기 실패 : \(failure)", haptic: .failed)
                }
            }
            setupSession()
            print("=== print \(String(describing: session))")
            print("=== 😄 print \(String(describing: semesterGrades))")
        }
#if APPCLIP
        .onAppear {
            presentingAppStoreOverlay = true
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("전체 성적")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton()
            }
        }
#endif
        .saintNexusOnSheet {
            LoadingCoverView()
        }
        .registerYDSToast()
    }

    func setupSession() {
        Task {
            do {
                self.session = try await USaintSessionBuilder().withPassword(id: "20201555", password: "woody12!@")
                getSemesterGrades()
                print("=== 1 Session initialized successfully: \(String(describing: session))")
            } catch {
                print("=== 2 Failed to initialize session: \(error)")
            }
        }
    }

    func getSemesterGrades() {
        Task {
            do {
                self.semesterGrades = try await CourseGradesApplicationBuilder().build(session: session!).semesters(courseType: CourseType.bachelor)
                print("=== 3 Session initialized successfully: \(String(describing: semesterGrades))")
            } catch {
                print("=== 4 Failed to initialize session: \(error)")
            }
        }
    }
}

struct EmphasizedView: View {
    let title: String
    let emphasized: String
    let sub: String
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(title)")
                .font(YDSFont.subtitle2)
            HStack(alignment: .firstTextBaseline) {
                Text("\(emphasized)")
                    .font(YDSFont.display1)
                    .foregroundColor(YDSColor.textPointed)
                Text("/ \(sub)")
                    .font(YDSFont.button0)
                    .foregroundColor(YDSColor.textTertiary)
                Spacer()
            }
        }
    }
}

struct GPAGraph: View {
    struct GPAInfo: Hashable {
        let semester: String
        let gpa: Double
        // shortedSemester : 차트의 label에 "2023년 1 학기" 문자열을 "23-1" 형태로 축약하여 출력
        var shortedSemester: String {
            var result = ""

            let pattern = #"(\d{2})(\d{2})년\s*(1|여름|2|겨울)\s*학기"#

            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(location: 0, length: semester.utf16.count)

                if let match = regex.firstMatch(in: semester, options: [], range: range) {
                    if let yearRange = Range(match.range(at: 2), in: semester),
                       let semesterRange = Range(match.range(at: 3), in: semester) {
                        let year = semester[yearRange]
                        let semester = semester[semesterRange]

                        result = "\(year)-\(semester)"
                    }
                }
            } catch {
                print("Error creating regex: \(error)")
            }

            return result
        }
    }
    let ySymbols: [Double] = [0, 1, 2]
    let gpaList: [GPAInfo]
    var trimmedGPAList: [GPAInfo] {
        gpaList.map {
            GPAInfo(
                semester: $0.semester,
                gpa: ($0.gpa - 2) < 0 ? 0 : ($0.gpa - 2)
            )
        }
    }
    var body: some View {
        Chart {
            ForEach(trimmedGPAList, id: \.self) { gpa in
                AreaMark(
                    x: .value("semester", gpa.semester),
                    y: .value("gpa", gpa.gpa)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(YDSColor.textPointed.opacity(0.5))
                LineMark(
                    x: .value("semester", gpa.semester),
                    y: .value("gpa", gpa.gpa)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(YDSColor.textPointed)
                .symbol {
                    Circle()
                        .fill(YDSColor.textPointed)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .chartYScale(domain: 0...2.5)
        .chartYAxis {
            AxisMarks(position: .leading, values: ySymbols) { axis in
                AxisGridLine()
                AxisValueLabel("\(String(format: "%.1F", ySymbols[axis.index] + 2))")
            }
        }
        .chartXAxis {
            AxisMarks(values: gpaList.map { $0.semester }) { axis in
                AxisValueLabel("\(gpaList[axis.index].shortedSemester)")
            }
        }
        .frame(height: 183)
        .padding(.horizontal, 8)
    }
}

struct ReportRow: View {
    let year: String
    let semester: String
    let credit: Double
    let semesterGPA: Double
    init(year: String, semester: String, credit: Double, semesterGPA: Double) {
        self.year = year
        self.semester = semester
        self.credit = credit
        self.semesterGPA = semesterGPA
    }
    init(reportListModel: ReportSummaryModel) {
        self.year = reportListModel.year
        self.semester = reportListModel.semester
        self.credit = reportListModel.credit
        self.semesterGPA = reportListModel.semesterGPA
    }
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1.0) {
                Text("\(year)년 \(semester)")
                    .font(YDSFont.subtitle2)
                Text("\(String(format: "%.1f", credit))학점")
                    .font(YDSFont.body1)
                    .foregroundColor(YDSColor.textTertiary)
            }
            Spacer()
            Text("\(String(format: "%.2f", semesterGPA))")
                .font(YDSFont.button0)
                .foregroundColor(YDSColor.buttonNormal)
            YDSIcon.arrowRightLine
                .renderingMode(.template)
                .foregroundColor(YDSColor.buttonNormal)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 8.0)
    }
}

struct ReportListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReportListView(reportListViewModel: TestReportListViewModel())
        }
    }
}
