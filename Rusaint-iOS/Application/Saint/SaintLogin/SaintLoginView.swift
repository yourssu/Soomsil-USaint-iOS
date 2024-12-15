//
//  SaintLoginView.swift
//  Soomsil
//
//  Created by 정종인 on 12/19/23.
//  Copyright © 2023 Yourssu. All rights reserved.
//

import SwiftUI
import YDS_SwiftUI
import SaintNexus

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

struct SaintLoginView: View {
    @Environment(\.dismiss) var dismiss
    @State private var id: String = ""
    @State private var password: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: Dimension.VStack.spacing) {
            Text("학번")
                .font(YDSFont.body1)
            YDSSimpleTextField(text: $id)
            Text("비밀번호")
                .font(YDSFont.body1)
            YDSPasswordTextField(text: $password)
                .padding(.bottom, Dimension.largeSpace)
            Button(action: {
                submit()
                Task {
                    do {
                        let response = try await SaintNexus.shared.loadPersonalInformation()
                        if response.status == 200 {
                            guard let personalInfo = response.rdata else { return }
                            let name = personalInfo.name.replacingOccurrences(of: " ", with: "")
                            let major = "\(personalInfo.department) \(personalInfo.major)"
                            let schoolYear = "\(personalInfo.schoolYear.replacingOccurrences(of: " ", with: ""))학년"
                            SaintRepository.shared.updateUserInformation(
                                name: name,
                                major: major,
                                schoolYear: schoolYear
                            )
                            YDSToast("로그인 성공.", haptic: .success)
                            dismiss()
                        } else {
                            YDSToast("로그인에 실패하였습니다. 다시 시도해주세요!", duration: .long, haptic: .failed)
                            SaintRepository.shared.deleteAllData()
                        }
                    } catch {
                        SaintRepository.shared.deleteAllData()
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
        .registerYDSToast()
        .saintNexusOnSheet {
            LoadingCoverView()
        }
    }
    private func initial() {
        let info = SaintRepository.shared.getUserInformation()
        switch info {
        case .success(let success):
            self.id = success.id
            self.password = success.password
        case .failure:
            self.id = ""
            self.password = ""
        }
    }
    private func submit() {
        SaintRepository.shared.updateUserInformation(id: id, password: password)
    }
}

#Preview {
    NavigationStack {
        SaintLoginView()
    }
}
