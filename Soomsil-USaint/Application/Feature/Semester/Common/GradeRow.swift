//
//  GradeRow.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/19/24.
//

import SwiftUI
import YDS

// TODO: GradeRowView로 변경됨(반영 완료 후, 삭제)
private enum Dimension {
    enum Spacing {
        static let mainHStack = 16.0
        static let innerVStack = 2.0
    }

    enum Size {
        static let gradeIcon = 48.0
        static let maskingViewHeight = 25.0
    }

    enum Padding {
        static let mainHStack = 8.0
    }
}

struct MaskedGradeRow: View {
    var grade: Grade = .unknown
    
//    private var gradeImage: Image {
//        Image(grade.string)
//    }
    
    var body: some View {
        HStack(spacing: Dimension.Spacing.mainHStack) {
            Image(grade.string)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimension.Size.gradeIcon)
            Color(YDSColor.bgSelected)
                .frame(maxHeight: Dimension.Size.maskingViewHeight)
        }
        .padding(.vertical, Dimension.Padding.mainHStack)
    }
    
//    private var gradeIcon: UIImage {
//        guard let image = UIImage(
//            named: grade.string,
//            in: Bundle(identifier: "com.yourssu.SoomsilUI"),
//            with: nil
//        ) else {
//            return Icon.unknown
//        }
//        image.accessibilityIdentifier = grade.string
//        return image
//    }
//    
//    var body: some View {
//        HStack(spacing: Dimension.Spacing.mainHStack) {
//            Image(uiImage: gradeIcon)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: Dimension.Size.gradeIcon)
//            Color(YDSColor.bgSelected)
//                .frame(maxHeight: Dimension.Size.maskingViewHeight)
//        }
//        .padding(.vertical, Dimension.Padding.mainHStack)
//    }
}

struct GradeRow: View {
    private var lectureName: String
    private var professor: String
    private var credit: Double
    private var grade: Grade
    init(lectureName: String, professor: String = "", credit: Double, grade: Grade = .unknown) {
        self.lectureName = lectureName
        self.professor = professor
        self.credit = credit
        self.grade = grade
    }
    private var professorAndCredit: String {
        let professor: String
        if self.professor == " " { // %C20%A0 에 해당하는 공백
            professor = ""
        } else {
            professor = self.professor
        }
        if professor == "" && credit == 0.0 {
            return ""
        } else if credit == 0 {
            return professor
        } else if professor == "" {
            return "\(credit)학점"
        } else {
            return "\(professor) · \(credit)학점"
        }
    }
    var body: some View {
        HStack(spacing: Dimension.Spacing.mainHStack) {
            Image(grade.string)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Dimension.Size.gradeIcon)
            
            VStack(alignment: .leading, spacing: Dimension.Spacing.innerVStack) {
                Text(lectureName)
                    .font(Font(YDSFont.subtitle1))
                Text(professorAndCredit)
                    .font(Font(YDSFont.body2))
                    .foregroundColor(Color(YDSColor.textTertiary))
            }
            Spacer()
        }
        .padding(.vertical, Dimension.Padding.mainHStack)
    }
}

struct MaskedGradeRow_Previews: PreviewProvider {
    static var previews: some View {
        MaskedGradeRow(grade: .aPlus)
    }
}

struct GradeRow_Previews: PreviewProvider {
    static var previews: some View {
        GradeRow(lectureName: "컴퓨팅적 사고", credit: 4.0)
    }
}
