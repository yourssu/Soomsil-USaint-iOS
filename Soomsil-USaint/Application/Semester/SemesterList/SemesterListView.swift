//
//  SemesterListView.swift
//  Soomsil-USaint-iOS
//
//  Created by 최지우 on 12/16/24.
//

import Charts
import SwiftUI
import YDS_SwiftUI
import Rusaint

struct SemesterListView<VM: SemesterListViewModel>: View {
    @Binding var path: [StackView]
    @Environment(\.dismiss) var dismiss
    @StateObject var semesterListViewModel: VM
    @State private var rowAnimation = false

    var body: some View {
        ZStack {
            ScrollView {
                // MARK: - top
                VStack(alignment: .leading) {
                    HStack {
                        let creditCard = SemesterRepository.shared.getTotalReportCard()

                        let average = creditCard.gpa
                        let sum = creditCard.earnedCredit
                        let graduateCredit = creditCard.graduateCredit
                        EmphasizedView(title: "평점 평균", emphasized: String(format: "%.2f", average), sub: "4.50")
                        EmphasizedView(title: "취득 학점", emphasized: String(format: "%.1f", sum), sub: String(graduateCredit))
                    }
                    VStack(alignment: .trailing, spacing: 18) {
                        GPAGraph(
                            gpaList: semesterListViewModel.reportList.sortedAscending()
                                .filter {
                                    ($0.semester != "겨울학기" && $0.semester != "여름학기")
                                    || semesterListViewModel.isOnSeasonalSemester
                                }
                                .filter {
                                    $0.gpa != 0
                                }
                                .map {
                                    GPAGraph.GPAInfo(semester: "\($0.year)년 \($0.semester)", gpa: $0.gpa)
                                }
                        )
                        Button {
                            semesterListViewModel.isOnSeasonalSemester.toggle()
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
                                semesterListViewModel.isOnSeasonalSemester
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
                    ForEach(
                        Array(semesterListViewModel.reportList.sortedDescending().enumerated()),
                        id: \.offset
                    ) { index, report in
                        // FIXME: path로 수정
                        NavigationLink {
                            SemesterDetailView(path: $path,
                                               semesterDetailViewModel: DefaultSemesterDetailViewModel(gradeSummary: report))
    //                        path.append(StackView(type: .SemesterDetail(gradeSummary: report)))
                        } label: {
                            let isLatestSemesterNotYetConfirmed = semesterListViewModel.isLatestSemesterNotYetConfirmed && index == 0
                            SemesterRow(gradeSummaryModel: report, isLatestSemesterNotYetConfirmed)
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
                }
                .padding()
            }
            .background(YDSColor.bgElevated)
            .onAppear {
                Task {
                    await semesterListViewModel.onAppear()
                }
            }
            .refreshable {
                Task {
                    await semesterListViewModel.onRefresh()
                }
            }
            .onChange(of: semesterListViewModel.fetchErrorMessage) { message in
                    YDSToast(message, haptic: .failed)
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
            if semesterListViewModel.isLoading {
                CircleLoadingView()
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
        let gpa: Float
        /// shortedSemester : 차트의 label에 "2023년 1 학기" 문자열을 "23-1" 형태로 축약하여 출력
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

// MARK: 학기별 정보
struct SemesterRow: View {
    let year: String
    let semester: String
    let earnedCredit: Float
    let semesterGPA: Float
    let isLatestSemesterNotYetConfirmed: Bool
    init(gradeSummaryModel: GradeSummaryModel, _ isLatestSemesterNotYetConfirmed: Bool = false) {
        self.year = String(gradeSummaryModel.year)
        self.semester = gradeSummaryModel.semester
        self.earnedCredit = gradeSummaryModel.earnedCredit
        self.semesterGPA = gradeSummaryModel.gpa
        self.isLatestSemesterNotYetConfirmed = isLatestSemesterNotYetConfirmed
    }
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1.0) {
                HStack {
                    Text("\(year)년 \(semester)")
                        .font(YDSFont.subtitle2)
                    if isLatestSemesterNotYetConfirmed {
                        YDSChip(text: "성적 처리 기간", isSelected: true)
                    }
                }
                Text("\(String(format: "%.1f", earnedCredit))학점")
                    .font(YDSFont.body1)
                    .foregroundColor(YDSColor.textTertiary)
            }
            Spacer()
            if isLatestSemesterNotYetConfirmed {
                Text("(예정) \(String(format: "%.2f", semesterGPA))")
                    .font(YDSFont.button0)
                    .foregroundColor(YDSColor.buttonDisabled)
            } else {
                Text("\(String(format: "%.2f", semesterGPA))")
                    .font(YDSFont.button0)
                    .foregroundColor(YDSColor.buttonNormal)
            }
            YDSIcon.arrowRightLine
                .renderingMode(.template)
                .foregroundColor(YDSColor.buttonNormal)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 8.0)
    }
}


#Preview {
    NavigationStack {
        SemesterListView(path: .constant([]), semesterListViewModel: MockSemesterListViewModel())
    }
}
