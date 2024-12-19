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

    var body: some View {
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
                    do {
                        self.session =  try await USaintSessionBuilder().withPassword(id: id, password: password)
                        if self.session != nil {
                            isLoggedIn = true
                            YDSToast("로그인 성공하였습니다.", haptic: .success)

                            await withTaskGroup(of: Void.self) { group in
                               group.addTask {
                                   await saveUserInfo(id: id, password: password, session: session!)
                               }
                               group.addTask {
                                   await saveReportCard(session: session!)
                               }
                           }
                        } else {
                            YDSToast("로그인에 실패하였습니다. 다시 시도해주세요!", duration: .long, haptic: .failed)
                            HomeRepository.shared.deleteAllData()
                        }
                    } catch {
                        HomeRepository.shared.deleteAllData()
                        YDSToast("로그인에 실패하였습니다. 다시 시도해주세요!", duration: .long, haptic: .failed)
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
                Text("숨쉴때 성적표 서비스 이용을 위한 유세인트 학번 및 비밀번호는 사용자 기기에만 저장되며, 유어슈는 성적표 서비스를 통하여 이용자의 정보를 일체 수집ㆍ저장하지 않습니다.")
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
            let graduateCredit = graduationRequirement.requirements.filter { $0.value.category == "졸업필수 요건" }
                .compactMap { $0.value.requirement }
                .map { Float($0) }

            HomeRepository.shared.updateTotalReportCard(gpa: courseGrades.gradePointsAvarage, earnedCredit: courseGrades.earnedCredits, graduateCredit: Float(graduateCredit[0]))

        } catch {
            print("Failed to save reportCard: \(error)")
        }
    }
}

#Preview {
    @State var isLoggedIn: Bool = false

    LoginView(isLoggedIn: $isLoggedIn)
}
