//
//  HomeView.swift
//  Soomsil-USaint-iOS 
//
//  Created by 이조은 on 12/16/24.
//

import SwiftUI
import YDS_SwiftUI

// swiftlint:disable identifier_name

struct HomeView<VM: HomeViewModel>: View {
    @State var path: [StackView] = []
    @StateObject var viewModel: VM

    @State private var isLoggedIn = false

    var body: some View {
        if !isLoggedIn {
            LoginView(isLoggedIn: $isLoggedIn)
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

                        if viewModel.hasFeature(.grade) {
                            GradeItemGroup()
                        }
                        Spacer()
                    }
                    .frame(height: 900)
                    .background(Color(red: 0.95, green: 0.96, blue: 0.97))
                }
                .background(.white)
                .onAppear {

                    if viewModel.hasCachedUserInformation() {
                        viewModel.syncCachedUserInformation()
                        isLoggedIn = viewModel.isLogedIn()
                    }
                }
                .registerYDSToast()
                .animation(.easeInOut, value: viewModel.isLogedIn())
                .navigationDestination(for: StackView.self) { stackView in
                    switch stackView.type {
                    case .Setting:
                        SettingView(path: $path)
                    case .SemesterList:
                        SettingView(path: $path)
                    case .SemesterDetail:
                        SettingView(path: $path)
                    case .WebViewTerm:
                        WebViewContainer(path: $path, urlToLoad: "https://auth.yourssu.com/terms/service.html")
                    case .WebViewPrivacy:
                        WebViewContainer(path: $path, urlToLoad: "https://auth.yourssu.com/terms/information.html")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func userInformationView() -> some View {
        if viewModel.isLogedIn(),
           let person = viewModel.person {
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
                        Text(person.name)
                            .font(YDSFont.subtitle1)
                            .padding(.bottom, 1.0)
                        Text("\(person.major) \(person.schoolYear)")
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
    }

    @ViewBuilder
    private func GradeItemGroup() -> some View {
        Button(action: {
            path.append(StackView(type: .SemesterList))
        }, label: {
            SaintItemGroupView(listType: .grade) {
                SaintItemView(.grade)
                let creditCard = HomeRepository.shared.getTotalReportCard()
                detailGradeListView(
                    average: creditCard.gpa,
                    credit: creditCard.earnedCredit,
                    graduateCredit: creditCard.graduateCredit
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
                Text("/ \(String(format: "%.2f", credit))").font(YDSFont.subtitle3)
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
                Text(String(Int(credit))).font(YDSFont.subtitle2)
                    .foregroundColor(Color(red: 0.51, green: 0.43, blue: 0.93))
                Text("/ \(String(Int(graduateCredit)))").font(YDSFont.subtitle3)
                    .foregroundColor(Color(red: 0.56, green: 0.58, blue: 0.6))
                    .padding(.leading, -4)
            }
            .frame(height: 23)
            .padding(.vertical, Dimension.DetailPadding.vertical)
            .padding(.horizontal, Dimension.DetailPadding.horizontal)

            Button(action: {
                // SemesterList로 이동
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

struct SaintMainHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(viewModel: TestSaintMainHomeViewModel())
        }
    }
}

