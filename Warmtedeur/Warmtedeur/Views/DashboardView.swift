import SwiftUI
import Charts
import UniformTypeIdentifiers

struct DashboardView: View {
    @StateObject private var vm = DashboardVM()
    @State private var showImporter = false
    @State private var showAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Dashboard").font(.largeTitle).bold()
                    Spacer()
                    ImportButton { url in
                        Task { await vm.ingest(fileURL: url) }
                    }
                }

                KPIGrid(bundle: vm.kpi)

                if vm.records.isEmpty {
                    ContentUnavailableView("Nog geen data", systemImage: "tray", description: Text("Importeer een CSV-bestand om te starten."))
                        .frame(maxWidth: .infinity)
                } else {
                    ChartSection(records: vm.records, title: "Warmteverlies over tijd", keyPath: \.warmteverliesMJ, valueLabel: "MJ")
                    ChartTopLocations(records: vm.records)
                }

                HStack {
                    Button(role: .destructive) {
                        vm.resetData()
                    } label: {
                        Label("Wis data", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
        .onAppear { vm.reloadFromStorage() }
        .alert("Fout", isPresented: Binding(get: { vm.errorMessage != nil }, set: { _ in vm.errorMessage = nil })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}

struct KPIGrid: View {
    let bundle: KPIBundle
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            KPICard(title: "Totaal verlies (MJ)", value: bundle.totaalMJ)
            KPICard(title: "Bespaarde m³", value: bundle.bespaardeM3)
            KPICard(title: "Besparing (€)", value: bundle.besparingEUR)
            KPICard(title: "Gemiddeld per deur (MJ)", value: bundle.gemiddeldMJPerDeur)
        }
    }
}

struct KPICard: View {
    let title: String
    let value: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(value.formatted(.number.precision(.fractionLength(0...1))))
                .font(.system(size: 28, weight: .semibold))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: .rect(cornerRadius: 16))
        .shadow(radius: 4, y: 3)
    }
}

struct ChartSection: View {
    let records: [RecordRow]
    let title: String
    let keyPath: KeyPath<RecordRow, Double>
    let valueLabel: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.title2).bold()
            Chart(records, id: \.id) { r in
                LineMark(
                    x: .value("Datum", r.datum),
                    y: .value(valueLabel, r[keyPath: keyPath])
                )
                PointMark(
                    x: .value("Datum", r.datum),
                    y: .value(valueLabel, r[keyPath: keyPath])
                )
            }
            .frame(height: 220)
        }
        .padding(.vertical, 8)
    }
}

struct ChartTopLocations: View {
    struct Item: Identifiable {
        let id = UUID()
        let locatie: String
        let total: Double
    }
    let items: [Item]
    init(records: [RecordRow]) {
        var dict: [String: Double] = [:]
        for r in records { dict[r.locatie, default: 0] += r.warmteverliesMJ }
        self.items = dict.map { Item(locatie: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
            .prefix(5).map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Top locaties (MJ)").font(.title2).bold()
            Chart(items) { i in
                BarMark(
                    x: .value("MJ", i.total),
                    y: .value("Locatie", i.locatie)
                )
            }
            .frame(height: 260)
        }
        .padding(.vertical, 8)
    }
}
