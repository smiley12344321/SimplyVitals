import SwiftUI

struct StatsGridView: View {
    let readings: [VitalReading]

    var body: some View {
        GeometryReader { proxy in
            let compact = proxy.size.width < 220

            if readings.isEmpty {
                Text("No stats selected")
                    .font(compact ? .caption : .headline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: compact ? 72 : 132), spacing: compact ? 8 : 14)], spacing: compact ? 8 : 14) {
                    ForEach(readings) { reading in
                        StatTile(reading: reading, compact: compact)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

private struct StatTile: View {
    let reading: VitalReading
    let compact: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 4 : 8) {
            HStack {
                Text(reading.metric.shortTitle)
                    .font(compact ? .caption2 : .caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(reading.freshnessText)
                    .font(.caption2)
                    .foregroundStyle(reading.freshnessText == "Live" ? .green : .secondary)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(reading.displayValue)
                    .font(compact ? .title2 : .largeTitle)
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
                    .monospacedDigit()

                Text(reading.metric.unitLabel)
                    .font(compact ? .caption2 : .footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(compact ? 8 : 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: compact ? 14 : 18, style: .continuous))
    }
}
