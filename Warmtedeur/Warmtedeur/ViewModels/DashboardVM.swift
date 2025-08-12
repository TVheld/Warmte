import Foundation
import Combine

@MainActor
final class DashboardVM: ObservableObject {
    @Published var records: [RecordRow] = []
    @Published var kpi: KPIBundle = .init(totaalMJ: 0, bespaardeM3: 0, besparingEUR: 0, gemiddeldMJPerDeur: 0)
    @Published var errorMessage: String? = nil

    func reloadFromStorage() {
        do {
            let data = try PersistenceController.shared.fetchAll()
            self.records = data
            self.kpi = data.kpis()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func ingest(fileURL: URL) async {
        do {
            let parsed = try await ImportCoordinator.shared.importFile(url: fileURL)
            try PersistenceController.shared.batchInsert(records: parsed)
            reloadFromStorage()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func resetData() {
        do {
            try PersistenceController.shared.wipe()
            reloadFromStorage()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
