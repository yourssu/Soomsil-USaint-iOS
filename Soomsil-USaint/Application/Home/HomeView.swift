//
//  HomeView.swift
//  Soomsil-USaint-iOS
//
//  Created by 이조은 on 12/16/24.
//

import SwiftUI
import YDS_SwiftUI
import Rusaint

// swiftlint:disable identifier_name

struct HomeView<VM: HomeViewModel>: View {
    @State var path: [StackView] = []
    @StateObject var viewModel: VM

    @Binding var isLoggedIn: Bool
    @State var isFirst: Bool = LocalNotificationManager.shared.getIsFirst()
    @State private var session: USaintSession?
    @State private var totalReportCard: TotalReportCardModel = HomeRepository.shared.getTotalReportCard()

    var body: some View {
        if !isLoggedIn {
            NavigationStack {
                LoginView(isLoggedIn: $isLoggedIn)
            }
        } else {
            NavigationStack(path: $path) {
                ScrollView {
                    HStack {
                        Text("유세인트")
                            .font(YDSFont.title2)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .frame(height: 31)
                    .padding(.vertical, 6)
                    .padding(.leading, 16)

                    VStack(spacing: Dimension.MainSpacing.vertical) {
                        userInformationView()
                        GradeItemGroup(reportCard: totalReportCard)
                        Spacer()
                    }
                    .frame(height: 900)
                    .background(Color(red: 0.95, green: 0.96, blue: 0.97))
                }
                .background(.white)
                .onAppear {
                    if !isFirst {
                        LocalNotificationManager().requestAuthorization(completion: { _ in
                        })
                    }

                }
                .task {
                        if viewModel.person == nil {
                            await loadUserInfo()
                        }
                    }
                .registerYDSToast()
                .animation(.easeInOut, value: viewModel.isLogedIn())
                .navigationDestination(for: StackView.self) { stackView in
                    switch stackView.type {
                    case .Setting:
                        SettingView(path: $path, isLoggedIn: $isLoggedIn)
                    case .SemesterList:
                        SemesterListView(path: $path, semesterListViewModel: DefaultSemesterListViewModel())
                    case .SemesterDetail:
                        SemesterDetailView(path: $path, semesterDetailViewModel: TestSemesterDetailViewModel())
                    case .WebViewTerm:
                        WebViewContainer(path: $path, urlToLoad: "https://auth.yourssu.com/terms/service.html")
                    case .WebViewPrivacy:
                        WebViewContainer(path: $path, urlToLoad: "https://auth.yourssu.com/terms/information.html")
                    }
                }
            }
        }
    }

    private func loadUserInfo() async {
        if viewModel.hasCachedUserInformation() {
            isLoggedIn = viewModel.hasCachedUserInformation()
            viewModel.syncCachedUserInformation()
        }

        let userInfo = HomeRepository.shared.getUserLoginInformation()
        do {
            self.session = try await USaintSessionBuilder().withPassword(id: userInfo[0], password: userInfo[1])
            if self.session != nil {
                await saveReportCard(session: session!)
                DispatchQueue.main.async {
                    self.totalReportCard = HomeRepository.shared.getTotalReportCard()
                }
            }
        } catch {
            print("Failed to load user info: \(error)")
        }
    }

    @ViewBuilder
    private func userInformationView() -> some View {

        let person = viewModel.person


        ZStack {
            Rectangle()
                .frame(height: 89)
                .foregroundColor(.clear)
            HStack {
                Image("DefaultProfileImage")
                    .resizable()
                    .cornerRadius(16)
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading) {
                    Text(person?.name ?? "")
                        .font(YDSFont.subtitle1)
                        .padding(.bottom, 1.0)
                    Text("\(person?.major ?? "") \(person?.schoolYear ?? "")")
                        .font(YDSFont.body1)
                }
                .padding(.leading)
                Spacer()
                Button(action: {
                    path.append(StackView(type: .Setting))
                }, label: {
                    Image("ic_setting_fill")
                })
                .padding(.trailing, 8)
            }
            .padding(.horizontal, 16.0)
            .padding(.vertical, 20.0)
        }
        .cornerRadius(16.0)
        .padding([.top, .leading, .trailing], 16)

    }

    @ViewBuilder
    private func GradeItemGroup(reportCard: TotalReportCardModel) -> some View {
        Button(action: {
            path.append(StackView(type: .SemesterList))
        }, label: {
            SaintItemGroupView(listType: .grade) {
                SaintItemView(.grade)
                detailGradeListView(
                    average: reportCard.gpa,
                    credit: reportCard.earnedCredit,
                    graduateCredit: reportCard.graduateCredit
                )
            }
            .foregroundColor(Color(red: 0.06, green: 0.07, blue: 0.07))
            .padding(.horizontal, Dimension.MainSpacing.horizontal)
        })
    }

    private func detailGradeListView(average: Float, credit: Float, graduateCredit: Float) -> some View {
        VStack(spacing: Dimension.DetailSpacing.vertical) {
            HStack {
                Text("평균학점").font(YDSFont.body1)
                Spacer()
                Text(String(format: "%.2f", average)).font(YDSFont.subtitle2)
                    .foregroundColor(Color(red: 0.51, green: 0.43, blue: 0.93))
                Text("/ \(String(format: "%.2f", 4.50))").font(YDSFont.subtitle3)
                    .foregroundColor(Color(red: 0.56, green: 0.58, blue: 0.6))
                    .padding(.leading, -4)
            }
            .frame(height: 23)
            .padding(.vertical, Dimension.DetailPadding.vertical)
            .padding(.horizontal, Dimension.DetailPadding.horizontal)

            Divider()
                .padding(.horizontal, 13)

            HStack {
                Text("취득학점").font(YDSFont.body1)
                Spacer()
                Text(String(format: "%.1f", credit)).font(YDSFont.subtitle2)
                    .foregroundColor(Color(red: 0.51, green: 0.43, blue: 0.93))
                Text("/ \(String(Int(graduateCredit)))").font(YDSFont.subtitle3)
                    .foregroundColor(Color(red: 0.56, green: 0.58, blue: 0.6))
                    .padding(.leading, -4)
            }
            .frame(height: 23)
            .padding(.vertical, Dimension.DetailPadding.vertical)
            .padding(.horizontal, Dimension.DetailPadding.horizontal)

            Button(action: {
                path.append(StackView(type: .SemesterList))
            }, label: {
                Text("전체성적 보기")
                    .font(Font.custom("Apple SD Gothic Neo", size: 15))
                    .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.16))
                    .frame(height: 39, alignment: .center)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.95, green: 0.96, blue: 0.97))
                    .cornerRadius(4)
            })
            .padding(.horizontal, Dimension.MainPadding.horizontal)
            .padding(.vertical, Dimension.DetailPadding.vertical)
            .padding(.bottom, 4)
        }
        .background(YDSColor.bgElevated)
    }

    private func saveReportCard(session: USaintSession) async {
        do {
            let courseGrades = try await CourseGradesApplicationBuilder().build(session: self.session!).certificatedSummary(courseType: .bachelor)
            let graduationRequirement = try await GraduationRequirementsApplicationBuilder().build(session: self.session!).requirements()
            let requirements = graduationRequirement.requirements.filter { $0.value.name.hasPrefix("학부-졸업학점") }
                .compactMap { $0.value.requirement ?? 0}

            if let graduateCredit = requirements.first {
                HomeRepository.shared.updateTotalReportCard(gpa: courseGrades.gradePointsAvarage, earnedCredit: courseGrades.earnedCredits, graduateCredit: Float(graduateCredit))
            }

//            DispatchQueue.main.async {
//                self.totalReportCard = HomeRepository.shared.getTotalReportCard()
//            }
            self.totalReportCard = HomeRepository.shared.getTotalReportCard()


        } catch {
            print("Failed to save reportCard: \(error)")
        }
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

private struct SaintItemGroupView<Content>: View where Content: View {
    let content: () -> Content
    let listTitle: String

    init(listType: HomeItem, @ViewBuilder content: @escaping () -> Content) {
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
    init(_ listType: HomeItem) {
        self.title = listType.title
        self.subTitle = listType.subTitle
    }
    var body: some View {
        HStack {
            Image("ppussung")
                .resizable()
                .clipShape(Circle())
                .frame(width: 48, height: 48)
                .padding(.leading, 2)
            VStack(alignment: .leading) {
                Text(subTitle)
                    .font(YDSFont.subtitle3)
                    .padding(.bottom, -2.0)
                Text(title)
                    .font(YDSFont.subtitle1)
            }
            .padding(.leading)
            Spacer()
            YDSIcon.arrowRightLine
                .renderingMode(.template)
                .foregroundColor(YDSColor.buttonNormal)
                .padding(.trailing, 8)
        }
        .padding(.horizontal, Dimension.MainPadding.horizontal)
        .padding(.vertical, Dimension.MainPadding.vertical)
        .background(YDSColor.bgElevated)
        .frame(height: 72)
    }
}

//struct SaintMainHomeView_Previews: PreviewProvider {
//    @State var isLoggedIn: Bool = true
//
//    static var previews: some View {
//        NavigationStack {
//            HomeView(viewModel: TestSaintMainHomeViewModel(), isLoggedIn: $isLoggedIn)
//        }
//    }
//}

