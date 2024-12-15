//
//  SwiftUIView.swift
//  Soomsil
//
//  Created by 이조은 on 11/17/24.
//  Copyright © 2024 Yourssu. All rights reserved.
//

import SwiftUI
import Rusaint

struct SwiftUIView: View {
    @State private var session: USaintSession? = nil
    @State private var semesterGrades: [SemesterGrade?]? = nil
    var body: some View {
        VStack {
            Text("Hello")
        }
        .padding()
//        .onAppear{
//            setupSession()
//            print("print \(String(describing: session))")
//            print("print \(String(describing: semesterGrades))")
//        }
    }

    func setupSession() {
        Task {
            do {
                self.session = try await USaintSessionBuilder().withPassword(id: "20201555", password: "woody12!@")
                getSemesterGrades()
                print("Session initialized successfully: \(String(describing: session))")
            } catch {
                print("Failed to initialize session: \(error)")
            }
        }
    }

    func getSemesterGrades() {
        Task {
            do {
                self.semesterGrades = try await CourseGradesApplicationBuilder().build(session: session!).semesters(courseType: CourseType.bachelor)
                print("Session initialized successfully: \(String(describing: semesterGrades))")
            } catch {
                print("Failed to initialize session: \(error)")
            }
        }
    }
}

#Preview {
    SwiftUIView()
}
