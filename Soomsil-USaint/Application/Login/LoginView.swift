//
//  LoginView.swift
//  Soomsil-USaint-iOS
//
//  Created by 이조은 on 12/16/24.
//

import SwiftUI
import YDS_SwiftUI
import Rusaint

private enum Dimension {
    enum VStack {
        static let spacing: CGFloat = 8
    }
    enum Button {
        static let minHeight: CGFloat = 48
    }
    static let largeSpace: CGFloat = 44
    static let padding: CGFloat = 16
}

struct LoginView: View {
    @State private var id: String = ""
    @State private var password: String = ""
    @State private var session: USaintSession?

    @Binding var isLoggedIn: Bool
    @State private var isLoading = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: Dimension.VStack.spacing) {
                Text("학번")
                    .font(YDSFont.body1)
                YDSSimpleTextField(text: $id)
                Text("유세인트 비밀번호")
                    .font(YDSFont.body1)
                YDSPasswordTextField(text: $password)
                    .padding(.bottom, Dimension.largeSpace)
                Button(action: {
                    Task {
                        isLoading = true
                        do {
                            self.session =  try await USaintSessionBuilder().withPassword(id: id, password: password)
                            if self.session != nil {

                                await saveUserInfo(id: id, password: password, session: session!)
                                await saveReportCard(session: session!)

                                isLoggedIn = true
                                isLoading = false
                                YDSToast("로그인 성공하였습니다.", haptic: .success)

                            } else {
                                YDSToast("로그인에 실패하였습니다. 다시 시도해주세요!", duration: .long, haptic: .failed)
                                HomeRepository.shared.deleteAllData()
                            }
                        } catch {
                            isLoading = false

                            YDSToast("로그인에 실패하였습니다. 다시 시도해주세요!", duration: .long, haptic: .failed)
                            HomeRepository.shared.deleteAllData()
                        }
                    }
                }, label: {
                    Text("로그인")
                        .foregroundStyle(YDSColor.buttonBright)
                        .font(YDSFont.button4).frame(maxWidth: .infinity, minHeight: Dimension.Button.minHeight)
                        .background(YDSColor.buttonPoint, in: RoundedRectangle(cornerRadius: 5))
                })
                .buttonStyle(.plain)
                HStack {
                    YDSIcon.warningcircleLine
                        .renderingMode(.template)
                    Text("숨쉴때 유세인트 서비스 이용을 위한 유세인트 학번 및 비밀번호는 사용자 기기에만 저장되며, 유어슈는 유세인트 서비스를 통하여 이용자의 정보를 일체 수집ㆍ저장하지 않습니다.")
                        .font(.caption2)
                }
                .foregroundStyle(YDSColor.textPointed)
                Spacer()
            }
            .registerYDSToast()
            .padding(Dimension.padding)
            .navigationTitle("로그인")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Color.clear
                    .tapToHideKeyboard()
            )
            .onAppear {
                initial()
            }

            if isLoading {
                CircleLoadingView()
            }
        }
    }

    private func initial() {
        let info = HomeRepository.shared.getUserInformation()
        switch info {
        case .success(let success):
            self.id = success.id
            self.password = success.password
        case .failure:
            self.id = ""
            self.password = ""
        }
    }
    private func saveUserInfo(id: String, password: String, session: USaintSession) async {
        HomeRepository.shared.updateUserInformation(id: id, password: password)

        do {
            let personalInfo = try await StudentInformationApplicationBuilder().build(session: self.session!).general()
            let name = personalInfo.name.replacingOccurrences(of: " ", with: "")
            let major = personalInfo.appliedDepartment
            let schoolYear = "\(personalInfo.grade)학년"
            HomeRepository.shared.updateUserInformation(name: name,
                                                        major: major,
                                                        schoolYear: schoolYear)
        } catch {
            print("Failed to save userInfo: \(error)")
        }
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

        } catch {
            print("Failed to save reportCard: \(error)")
        }
    }
}

struct CircleLoadingView: View {
    @State private var isLoading = false

       var body: some View {
           ZStack {
               Color(red: 0.77, green: 0.77, blue: 0.77).opacity(0.3)
                      .edgesIgnoringSafeArea(.all)
               ZStack {
                   Circle()
                       .stroke(Color(red: 0.89, green: 0.88, blue: 0.91), lineWidth: 7)
                       .frame(width: 50, height: 50)

                   Circle()
                       .trim(from: 0, to: 0.2)
                       .stroke(
                           Color(red: 0.49, green: 0.44, blue: 0.8),
                           style: StrokeStyle(
                               lineWidth: 7,
                               lineCap: .round
                           )
                       )
                       .frame(width: 50, height: 50)
                       .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                       .animation(
                           .linear(duration: 1)
                               .repeatForever(autoreverses: false),
                           value: isLoading
                       )
                       .onAppear() {
                           self.isLoading = true
                   }
               }
               .padding(.bottom, 140)
           }
       }
}

//#Preview {
////    @State var isLoggedIn: Bool = false
////
////    LoginView(isLoggedIn: $isLoggedIn)
//}

struct loadingView_Previews: PreviewProvider {

    static var previews: some View {
        CircleLoadingView()
    }
}
