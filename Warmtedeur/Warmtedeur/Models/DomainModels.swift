import Foundation

struct RecordRow: Identifiable, Hashable {
    let id = UUID()
    let datum: Date
    let locatie: String
    let deurbreedte: Double
    let tempBinnen: Double
    let tempBuiten: Double
    let warmteverliesMJ: Double
    let gasBesparingM3: Double
    let kostenBesparingEUR: Double
}

struct KPIBundle {
    let totaalMJ: Double
    let bespaardeM3: Double
    let besparingEUR: Double
    let gemiddeldMJPerDeur: Double
}

extension Array where Element == RecordRow {
    func kpis() -> KPIBundle {
        let totaal = self.reduce(0) { $0 + $1.warmteverliesMJ }
        let m3 = self.reduce(0) { $0 + $1.gasBesparingM3 }
        let eur = self.reduce(0) { $0 + $1.kostenBesparingEUR }
        let perDeur = self.isEmpty ? 0 : totaal / Double(Set(self.map{ $0.locatie }).count)
        return KPIBundle(totaalMJ: totaal, bespaardeM3: m3, besparingEUR: eur, gemiddeldMJPerDeur: perDeur)
    }
}
