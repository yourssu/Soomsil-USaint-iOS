//
//  SemesterDetailView.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/17/24.
//

import SwiftUI

struct SemesterDetailView<VM: SemesterDetailViewModel>: View {
    @StateObject private var semesterDetailViewModel: VM
    @State private var isShowSummary: Bool = true
    init(semesterDetailViewModel: VM, isShowSummary: Bool = true) {
        self._semesterDetailViewModel = StateObject(wrappedValue: semesterDetailViewModel)
        self.isShowSummary = isShowSummary
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .bottomTrailing) {
                
            }
        }
    }
}
