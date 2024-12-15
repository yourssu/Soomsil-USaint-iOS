//
//  SaintHomeView.swift
//  Soomsil
//
//  Created by 오동규 on 2023/09/06.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import SwiftUI
import YDS_SwiftUI

// swiftlint:disable identifier_name

struct SaintHomeView<VM: SaintHomeViewModel>: View {
    @StateObject var viewModel: VM
    @State private var isShowingLogoutAlert: Bool = false
    var body: some View {
        ScrollView {
            VStack(spacing: Dimension.MainSpacing.vertical) {
                PersonView<VM>(viewModel: viewModel)

                if viewModel.isLogedIn() {
                    Button {
                        isShowingLogoutAlert.toggle()
                    } label: {
                        Text("모든 정보를 지우고 로그아웃")
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.plain)
                            .foregroundStyle(YDSColor.textBright, YDSColor.textBright)
                            .zIndex(2)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(YDSColor.buttonWarned)
                            }
                            .padding(.horizontal)
                    }
                }

                if viewModel.hasFeature(.grade) {
                    GradeItemGroup()
                }

                if viewModel.hasFeature(.chapel(.location)) || viewModel.hasFeature(.chapel(.attendance)) {
                    ChapelItemGroup()
                }

                if viewModel.hasFeature(.graduation) {
                    GraduationItemGroup()
                }

                Spacer()
            }
        }
        .background(YDSColor.bgSelected)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("유세인트")
                    .font(YDSFont.title2)
                    .foregroundColor(YDSColor.textPrimary)
            }
        }
        .onAppear {
            if viewModel.hasCachedUserInformation() {
                viewModel.syncCachedUserInformation()
            }
        }
        .alert("정말 모든 정보를 지우고 로그아웃 할까요?", isPresented: $isShowingLogoutAlert) {
            Button("취소", role: .cancel) {}
            Button("로그아웃", role: .destructive) {
                SaintRepository.shared.deleteAllData()
                viewModel.person = nil
            }
        }
        .registerYDSToast()
        .animation(.easeInOut, value: viewModel.isLogedIn())
    }

    @ViewBuilder
    private func GradeItemGroup() -> some View {
        NavigationLink {
            ReportListView(reportListViewModel: DefaultReportListViewModel())
                .navigationTitle("내 성적")
        } label: {
            SaintItemGroupView(listType: .grade) {
                SaintItemView(.grade)
                if let latestReport = SaintRepository.shared
                    .getReportSummaryList()
                    .sortedDescending().first {
                    detailGradeListView(
                        average: latestReport.semesterGPA,
                        credit: latestReport.credit,
                        rank: latestReport.semesterRank
                    )
                }
            }
        }
        .padding(.horizontal, Dimension.MainPadding.horizontal)
        .buttonStyle(.plain)
        .disabled(!viewModel.isLogedIn())
    }

    @ViewBuilder
    private func ChapelItemGroup() -> some View {
        NavigationLink {
            ErrorViewControllerRepresent(type: .preparingService)
        } label: {
            SaintItemGroupView(listType: .chapel()) {
                SaintItemView(.chapel(.location))
                SaintItemView(.chapel(.attendance))
            }
        }
        .padding(.horizontal, Dimension.MainPadding.horizontal)
        .buttonStyle(.plain)
        .disabled(!viewModel.isLogedIn())
    }

    @ViewBuilder
    private func GraduationItemGroup() -> some View {
        NavigationLink {
            ErrorViewControllerRepresent(type: .preparingService)
        } label: {
            SaintItemGroupView(listType: .graduation) {
                SaintItemView(.graduation)
            }
        }
        .padding(.horizontal, Dimension.MainPadding.horizontal)
        .buttonStyle(.plain)
        .disabled(!viewModel.isLogedIn())
    }

    private func detailGradeListView(average: Double, credit: Double, rank: (String, String)) -> some View {
        VStack(spacing: Dimension.DetailSpacing.vertical) {
            HStack {
                Text("최근 학기 평균학점").font(YDSFont.body1)
                Spacer()
                Text(String(format: "%.2f", average)).font(YDSFont.body1)
            }
            .frame(height: 39)
            .padding(.vertical, Dimension.DetailPadding.vertical)
            .padding(.horizontal, Dimension.DetailPadding.horizontal)

            Divider()
                .padding(.horizontal, 13)

            HStack {
                Text("최근 학기 취득학점").font(YDSFont.body1)
                Spacer()
                Text(String(format: "%.1f", credit)).font(YDSFont.body1)
            }
            .frame(height: 39)
            .padding(.vertical, Dimension.DetailPadding.vertical)
            .padding(.horizontal, Dimension.DetailPadding.horizontal)

            Divider()
                .padding(.horizontal, 13)

            HStack {
                Text("최근 학기 석차").font(YDSFont.body1)
                Spacer()
                Text("\(rank.0) / \(rank.1)").font(YDSFont.body1)
            }
            .frame(height: 39)
            .padding(.vertical, Dimension.DetailPadding.vertical)
            .padding(.horizontal, Dimension.DetailPadding.horizontal)
        }
        .background(YDSColor.bgElevated)
    }
}

private enum Dimension {
    enum MainSpacing {
        static let horizontal: CGFloat = 16
        static let vertical: CGFloat = 12
    }

    enum DetailSpacing {
        static let vertical: CGFloat = 0
    }

    enum MainPadding {
        static let horizontal: CGFloat = 16
        static let vertical: CGFloat = 12
    }

    enum DetailPadding {
        static let horizontal: CGFloat = 28
        static let vertical: CGFloat = 8
    }
}

private struct NeedLoginView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 89)
                .foregroundColor(.clear)
            HStack {
                Image("ppussung")
                    .resizable()
                    .cornerRadius(16)
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 4.0) {
                    Text("로그인 후 사용해주세요.")
                        .font(YDSFont.title3)
                    Text("더 많은 정보를 확인할 수 있어요.")
                        .font(YDSFont.body1)
                }
                .padding(.leading, 12.0)
                Spacer()
                YDSIcon.arrowRightLine
                    .renderingMode(.template)
                    .foregroundColor(YDSColor.buttonNormal)
            }
            .padding([.horizontal], 16.0)
            .padding([.vertical], 20.0)
        }
        .cornerRadius(16.0)
        .padding([.vertical], 16)
    }
}

private struct PersonView<VM: SaintHomeViewModel>: View {
    @StateObject var viewModel: VM
    var body: some View {
        NavigationLink {
            SaintLoginView()
                .onDisappear {
                    viewModel.syncCachedUserInformation()
                }
        } label: {
            if viewModel.isLogedIn(),
               let person = viewModel.person {
                ZStack {
                    Rectangle()
                        .frame(height: 89)
                        .foregroundColor(.clear)
                    HStack {
                        Image("ppussung")
                            .resizable()
                            .cornerRadius(16)
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading) {
                            Text(person.name)
                                .font(YDSFont.subtitle1)
                                .padding(.bottom, 1.0)
                            Text("\(person.major) \(person.schoolYear)")
                                .font(YDSFont.body1)
                        }
                        .padding(.leading)
                        Spacer()
                        YDSIcon.arrowRightLine
                            .renderingMode(.template)
                            .foregroundColor(YDSColor.buttonNormal)
                    }
                    .padding(.horizontal, 16.0)
                    .padding(.vertical, 20.0)
                }
                .cornerRadius(16.0)
                .padding([.top, .leading, .trailing], 16)
            } else {
                NeedLoginView()
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SaintItemGroupView<Content>: View where Content: View {
    let content: () -> Content
    let listTitle: String

    init(listType: SaintItem, @ViewBuilder content: @escaping () -> Content) {
        self.listTitle = listType.listTitle
        self.content = content
    }

    var body: some View {
        VStack(spacing: Dimension.DetailSpacing.vertical) {
            HStack {
                Text(listTitle).font(YDSFont.title3)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(YDSColor.bgElevated)
            content()
        }
        .cornerRadius(8)
    }
}

private struct SaintItemView: View {
    let title: String
    let subTitle: String
    init(_ listType: SaintItem) {
        self.title = listType.title
        self.subTitle = listType.subTitle
    }
    var body: some View {
        HStack {
            Image("ppussung")
                .resizable()
                .clipShape(Circle())
                .frame(width: 48, height: 48)
            VStack(alignment: .leading) {
                Text(subTitle)
                    .font(YDSFont.subtitle3)
                    .padding(.bottom, 1.0)
                Text(title)
                    .font(YDSFont.subtitle1)
            }
            .padding(.leading)
            Spacer()
            YDSIcon.arrowRightLine
                .renderingMode(.template)
                .foregroundColor(YDSColor.buttonNormal)
        }
        .padding(.horizontal, Dimension.MainPadding.horizontal)
        .padding(.vertical, Dimension.MainPadding.vertical)
        .background(YDSColor.bgElevated)
        .frame(height: 72)
    }
}

struct SaintMainHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SaintHomeView(viewModel: TestSaintMainHomeViewModel())
        }
    }
}

// swiftlint:enable identifier_name
