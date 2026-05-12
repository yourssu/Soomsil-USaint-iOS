//
//  ChapelSeatMapModels.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/12/26.
//

import Foundation

struct ChapelSeatZone: Identifiable {
    let id: String
    let columns: Int
    let rows: [ChapelSeatRow]
    let aisleAfterRows: Set<Int>
    let entranceDirection: ChapelSeatEntranceDirection
}

struct ChapelSeatRow {
    let seats: [Int?]

    var seatCount: Int {
        seats.compactMap { $0 }.count
    }
}

enum ChapelSeatEntranceDirection {
    case left
    case right

    var directionText: String {
        switch self {
        case .left:
            return TextLiteral.ChapelSeatMap.leftDirection
        case .right:
            return TextLiteral.ChapelSeatMap.rightDirection
        }
    }
}

struct ChapelSeatLocation {
    let zone: String
    let row: Int?
    let column: Int?

    var guideText: String {
        let zone = ChapelSeatZone.definition(for: zone)
        let entranceDirection = zone?.entranceDirection(row: row, column: column)

        return TextLiteral.ChapelSeatLocationView.seatGuide(
            entranceDirection: entranceDirection?.directionText ?? TextLiteral.ChapelSeatMap.leftDirection,
            row: row,
            seatIndexFromEntrance: zone?.seatIndexFromEntrance(row: row, column: column)
        )
    }

    init(seatPosition: String) {
        let parts = seatPosition
            .components(separatedBy: CharacterSet(charactersIn: TextLiteral.ChapelSeatInfoView.zoneSeparator))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        zone = parts.first?.uppercased() ?? TextLiteral.ChapelSeatInfoView.defaultZone

        if parts.count >= 3 {
            row = Int(parts[1])
            column = Int(parts[2])
        } else if let seatNumber = parts.dropFirst().first.flatMap(Int.init) {
            row = ((seatNumber - 1) / 4) + 1
            column = ((seatNumber - 1) % 4) + 1
        } else {
            row = nil
            column = nil
        }
    }
}

extension ChapelSeatZone {
    func entranceDirection(row: Int?, column: Int?) -> ChapelSeatEntranceDirection {
        guard [ChapelSeatZone.c.id, ChapelSeatZone.h.id].contains(id),
              let row,
              let column,
              rows.indices.contains(row - 1) else {
            return entranceDirection
        }

        let seatCount = rows[row - 1].seatCount
        return column <= Int(ceil(Double(seatCount) / 2)) ? .left : .right
    }

    func seatIndexFromEntrance(row: Int?, column: Int?) -> Int? {
        guard let row,
              let column,
              rows.indices.contains(row - 1) else {
            return nil
        }

        let seats = rows[row - 1].seats
        guard seats.contains(column) else {
            return nil
        }

        switch entranceDirection(row: row, column: column) {
        case .left:
            return column
        case .right:
            return rows[row - 1].seatCount - column + 1
        }
    }
}
