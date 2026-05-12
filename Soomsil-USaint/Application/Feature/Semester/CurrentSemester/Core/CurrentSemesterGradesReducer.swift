//
//  CurrentSemesterGradesReducer.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/12/26.
//

import ComposableArchitecture

@Reducer
struct CurrentSemesterGradesReducer {
    @ObservableState
    struct State {
        var currentSemesterYear: Int?
        var currentSemester: String?
        var currentSemesterLectures: [LectureDetail] = []
        var isLoading = false
        var toastMessage = ""
    }

    enum Action {
        case onAppear
        case fetchCurrentSemesterGradeResponse(Result<CurrentSemesterGradePayload, Error>)
    }

    @Dependency(\.gradeClient) var gradeClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true

                return .run { send in
                    await send(.fetchCurrentSemesterGradeResponse(Result {
                        if let currentSemester = try await gradeClient.currentYearAndSemester() {
                            let lectures = try await gradeClient.fetchGrades(
                                currentSemester.year,
                                currentSemester.semester
                            )

                            return CurrentSemesterGradePayload(
                                year: currentSemester.year,
                                semester: currentSemester.semester.toString().replacingOccurrences(of: " ", with: ""),
                                lectures: lectures.toLectureDetails()
                            )
                        } else {
                            let lectures = try await gradeClient.fetchGrades(2025, .one)

                            return CurrentSemesterGradePayload(
                                year: 2025,
                                semester: "1학기",
                                lectures: lectures.toLectureDetails()
                            )
                        }
                    }))
                }

            case .fetchCurrentSemesterGradeResponse(.success(let payload)):
                state.currentSemesterYear = payload.year
                state.currentSemester = payload.semester
                state.currentSemesterLectures = payload.lectures
                state.isLoading = false
                return .none

            case .fetchCurrentSemesterGradeResponse(.failure(let error)):
                state.toastMessage = String(describing: error)
                state.isLoading = false
                return .none
            }
        }
    }
}
