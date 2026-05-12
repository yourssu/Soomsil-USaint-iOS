//
//  ChapelSeatMapView.swift
//  Soomsil-USaint
//
//  Created by 정민지 on 5/12/26.
//

import SwiftUI

/// 확대 가능한 채플 좌석표
struct ZoomableChapelSeatMapView: View {
    // MARK: - Properties

    let seatLocation: ChapelSeatLocation

    @State private var zoomScale: CGFloat = 1
    @State private var lastZoomScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let mapWidth: CGFloat = 820
    private let mapHeight: CGFloat = 620
    private let indicatorHeight: CGFloat = 16

    // MARK: - Body

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                GeometryReader { proxy in
                    let fitScale = min(proxy.size.width / mapWidth, proxy.size.height / mapHeight)
                    let scaledSize = CGSize(
                        width: mapWidth * fitScale * zoomScale,
                        height: mapHeight * fitScale * zoomScale
                    )
                    let boundedOffset = clampedOffset(
                        offset,
                        contentSize: scaledSize,
                        containerSize: proxy.size
                    )

                    ChapelSeatMapView(seatLocation: seatLocation)
                        .frame(width: mapWidth, height: mapHeight)
                        .scaleEffect(fitScale * zoomScale)
                        .frame(width: scaledSize.width, height: scaledSize.height)
                        .position(
                            x: proxy.size.width / 2 + boundedOffset.width,
                            y: proxy.size.height / 2 + boundedOffset.height
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    zoomScale = min(max(lastZoomScale * value, 1), 4)
                                    offset = clampedOffset(
                                        offset,
                                        contentSize: scaledSize,
                                        containerSize: proxy.size
                                    )
                                }
                                .onEnded { _ in
                                    zoomScale = min(max(zoomScale, 1), 4)
                                    lastZoomScale = zoomScale
                                    offset = clampedOffset(
                                        offset,
                                        contentSize: scaledSize,
                                        containerSize: proxy.size
                                    )
                                    lastOffset = offset
                                }
                        )
                        .simultaneousGesture(
                            DragGesture()
                                .onChanged { value in
                                    guard zoomScale > 1 else { return }

                                    offset = clampedOffset(
                                        CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        ),
                                        contentSize: scaledSize,
                                        containerSize: proxy.size
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                }
            }
            .aspectRatio(mapWidth / mapHeight, contentMode: .fit)
            .clipped()

            seatIndicatorView
                .frame(height: indicatorHeight)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(.gray25)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.slate100, lineWidth: 1)
        )
        .onTapGesture(count: 2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                zoomScale = 1
                lastZoomScale = 1
                offset = .zero
                lastOffset = .zero
            }
        }
    }

    private var seatIndicatorView: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.up")
                .font(.system(size: 13, weight: .bold))

            Text(TextLiteral.ChapelSeatLocationView.selectedSeatTitle)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(.blue500)
    }

    private func clampedOffset(
        _ offset: CGSize,
        contentSize: CGSize,
        containerSize: CGSize
    ) -> CGSize {
        let maxX = max((contentSize.width - containerSize.width) / 2, 0)
        let maxY = max((contentSize.height - containerSize.height) / 2, 0)

        return CGSize(
            width: min(max(offset.width, -maxX), maxX),
            height: min(max(offset.height, -maxY), maxY)
        )
    }
}

/// 채플 좌석표
struct ChapelSeatMapView: View {
    // MARK: - Properties

    let seatLocation: ChapelSeatLocation

    private let zoneRows: [[ChapelSeatZone]] = [
        [.a, .b, .c, .d, .e],
        [.f, .g, .h, .i, .j]
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 28) {
            Text(TextLiteral.ChapelSeatLocationView.stageTitle)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(.gray800)

            VStack(spacing: 38) {
                ForEach(zoneRows.indices, id: \.self) { rowIndex in
                    HStack(alignment: .top, spacing: 22) {
                        ForEach(zoneRows[rowIndex]) { zone in
                            ChapelSeatZoneView(
                                zone: zone,
                                seatLocation: seatLocation
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 24)
        .background(.gray25)
    }
}

// MARK: - Seat Zone

private struct ChapelSeatZoneView: View {
    // MARK: - Properties

    let zone: ChapelSeatZone
    let seatLocation: ChapelSeatLocation

    private let seatSize: CGFloat = 7
    private let seatGap: CGFloat = 3
    private let rowGap: CGFloat = 10

    private var selectedRow: Int? {
        guard seatLocation.zone == zone.id else {
            return nil
        }
        return seatLocation.row
    }

    private var selectedColumn: Int? {
        guard seatLocation.zone == zone.id else {
            return nil
        }
        return seatLocation.column
    }

    private var zoneWidth: CGFloat {
        CGFloat(zone.columns) * seatSize + CGFloat(zone.columns - 1) * seatGap
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            Text(zone.id)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.gray800)

            VStack(spacing: seatGap) {
                ForEach(zone.rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: seatGap) {
                        ForEach(zone.rows[rowIndex].seats.indices, id: \.self) { columnIndex in
                            seatSlotView(
                                seatColumn: zone.rows[rowIndex].seats[columnIndex],
                                row: rowIndex + 1,
                                slot: columnIndex + 1
                            )
                        }
                    }

                    if zone.aisleAfterRows.contains(rowIndex + 1) {
                        Spacer()
                            .frame(height: rowGap)
                    }
                }
            }
            .frame(width: zoneWidth)
        }
        .frame(width: 118)
    }

    @ViewBuilder
    private func seatSlotView(seatColumn: Int?, row: Int, slot: Int) -> some View {
        if let seatColumn {
            seatView(row: row, column: seatColumn)
        } else {
            Color.clear
                .frame(width: seatSize, height: seatSize)
        }
    }

    private func seatView(row: Int, column: Int) -> some View {
        let isSelected = selectedRow == row && selectedColumn == column

        return RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(isSelected ? Color.blue500 : Color.gray200)
            .frame(width: seatSize, height: seatSize)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(.blue500.opacity(0.35), lineWidth: 4)
                }
            }
            .accessibilityLabel(
                TextLiteral.ChapelSeatMap.accessibilityLabel(
                    zone: zone.id,
                    row: row,
                    column: column
                )
            )
    }
}

// MARK: - Preview

#Preview {
    ZoomableChapelSeatMapView(
        seatLocation: ChapelSeatLocation(seatPosition: "B-1-1")
    )
    .padding(24)
}
