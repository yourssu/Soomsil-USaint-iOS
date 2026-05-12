//
//  ChapelSeatMapData.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/12/26.
//

import Foundation

extension ChapelSeatZone {
    static func definition(for id: String) -> ChapelSeatZone? {
        all.first { $0.id == id }
    }

    static let all: [ChapelSeatZone] = [
        .a,
        .b,
        .c,
        .d,
        .e,
        .f,
        .g,
        .h,
        .i,
        .j
    ]

    private static func zone(
        id: String,
        pattern: [String],
        entranceDirection: ChapelSeatEntranceDirection
    ) -> ChapelSeatZone {
        var rows: [ChapelSeatRow] = []
        var aisleAfterRows = Set<Int>()
        let columns = pattern
            .filter { $0 != "gap" }
            .map(\.count)
            .max() ?? 0

        for item in pattern {
            if item == "gap" {
                aisleAfterRows.insert(rows.count)
                continue
            }

            var seatNumber = 0
            let seats = item.map { character -> Int? in
                guard character == "1" else {
                    return nil
                }

                seatNumber += 1
                return seatNumber
            }

            rows.append(ChapelSeatRow(seats: seats))
        }

        return ChapelSeatZone(
            id: id,
            columns: columns,
            rows: rows,
            aisleAfterRows: aisleAfterRows,
            entranceDirection: entranceDirection
        )
    }

    static let a = zone(
        id: "A",
        pattern: [
            "00011111",
            "00111111",
            "01111111",
            "11111111",
            "11111111",
            "11111111",
            "01111111",
            "gap",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111100"
        ],
        entranceDirection: .left
    )

    static let b = zone(
        id: "B",
        pattern: [
            "0111111",
            "0111111",
            "0111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "gap",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1110000"
        ],
        entranceDirection: .left
    )

    static let c = zone(
        id: "C",
        pattern: [
            "111111111",
            "1111111111",
            "1111111111",
            "1111111111",
            "1111111111",
            "11111111111",
            "11111111111",
            "gap",
            "11111111111",
            "11111111111",
            "11111111111",
            "11111111111",
            "11111111111",
            "11111111111",
            "11111111111",
            "11111111111"
        ],
        entranceDirection: .left
    )

    static let d = zone(
        id: "D",
        pattern: [
            "1111100",
            "1111110",
            "1111110",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "gap",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111"
        ],
        entranceDirection: .right
    )

    static let e = zone(
        id: "E",
        pattern: [
            "11111000",
            "11111100",
            "11111110",
            "11111111",
            "11111111",
            "11111111",
            "11111110",
            "gap",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "0011111"
        ],
        entranceDirection: .right
    )

    static let f = zone(
        id: "F",
        pattern: [
            "11111111",
            "11111111",
            "11111111",
            "11111111",
            "11111111",
            "11111111",
            "gap",
            "11100000",
            "11100000",
            "11100000",
            "11100000",
            "11111111",
            "11111111",
            "11111111",
            "00111111",
            "00111110"
        ],
        entranceDirection: .left
    )

    static let g = zone(
        id: "G",
        pattern: [
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "gap",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111110",
            "1111110"
        ],
        entranceDirection: .left
    )

    static let h = zone(
        id: "H",
        pattern: [
            "111111111",
            "111111111",
            "111111111",
            "111111111",
            "111111111",
            "111111111",
            "gap",
            "111111111",
            "111111111",
            "111111111",
            "111111111",
            "111111111",
            "111111111",
            "111111111",
            "111111111",
            "111111111",
            "111111111"
        ],
        entranceDirection: .left
    )

    static let i = zone(
        id: "I",
        pattern: [
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "gap",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111",
            "1111111"
        ],
        entranceDirection: .right
    )

    static let j = zone(
        id: "J",
        pattern: [
            "11111111",
            "11111111",
            "11111111",
            "11111111",
            "11111111",
            "11111111",
            "gap",
            "00000111",
            "00000111",
            "00000111",
            "00000111",
            "11111111",
            "11111111",
            "11111111",
            "11111100",
            "01111100"
        ],
        entranceDirection: .right
    )
}
