//
//  StudentInfoView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/6/26.
//

import SwiftUI

struct StudentInfoView: View {
    var student: StudentInfo
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(student.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.adaptivePrimaryText)
                    .lineLimit(1)

                Text(student.subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.adaptiveSecondaryText)
                    .lineLimit(1)
            }

            Spacer()

            if let studentID = student.trimmedStudentID {
                Text(TextLiteral.StudentInfoView.studentID(studentID))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.adaptivePrimaryText)
                    .lineLimit(1)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color.adaptiveMutedSurface)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(Color.adaptiveSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.adaptiveBorder, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private extension StudentInfo {
    var subtitle: String {
        TextLiteral.StudentInfoView.subtitle(
            major: major,
            schoolYear: schoolYear
        )
    }

    var trimmedStudentID: String? {
        guard let studentID = studentID?.trimmingCharacters(in: .whitespacesAndNewlines),
              !studentID.isEmpty else {
            return nil
        }
        return studentID
    }
}

#Preview {
    ZStack(alignment: .center) {
        Color.gray.ignoresSafeArea()
        
        StudentInfoView(
            student: StudentInfo(
                name: "김숨실",
                major: "글로벌미디어학부",
                schoolYear: "4학년",
                studentID: "20201234"
            )
        )
        .padding(.horizontal, 20)
    }
}
