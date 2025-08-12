import Foundation
import UniformTypeIdentifiers
import Combine


protocol DataImporter {
    func canImport(url: URL) -> Bool
    func importData(from url: URL) async throws -> [RecordRow]
}

final class CSVImporter: DataImporter {
    func canImport(url: URL) -> Bool {
        url.pathExtension.lowercased() == "csv"
    }

    func importData(from url: URL) async throws -> [RecordRow] {
        let raw = try String(contentsOf: url, encoding: .utf8)
        return try CSVParser.parse(csv: raw)
    }
}

enum CSVParser {
    static func parse(csv: String) throws -> [RecordRow] {
        var rows: [RecordRow] = []
        let lines = csv
            .components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard let header = lines.first else { return [] }
        let headers = header.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }

        func idx(_ keys: [String]) -> Int? {
            headers.firstIndex { h in keys.contains { h.contains($0) } }
        }

        let iDatum = idx(["datum","date"])
        let iLoc = idx(["locatie","location","deur","door"])
        let iWidth = idx(["deurbreedte","breedte","width"])
        let iTin = idx(["tempbinnen","binnen","inside"])
        let iTout = idx(["tempbuiten","buiten","outside"])
        let iMJ = idx(["warmteverlies","mj","verliesmj"])
        let iM3 = idx(["gas","m3","besparingm3"])
        let iEUR = idx(["kosten","euro","eur","besparing"])

        let df = ISO8601DateFormatter()
        let altDF: DateFormatter = {
            let f = DateFormatter()
            f.locale = Locale(identifier: "nl_NL")
            f.dateFormat = "dd-MM-yyyy"
            return f
        }()

        for line in lines.drop(1) where !line.trimmingCharacters(in: .whitespaces).isEmpty {
            let cols = line.split(separator: ",").map { String($0) }
            func val(_ i: Int?) -> String { (i != nil && i! < cols.count) ? cols[i!] : "" }

            let dStr = val(iDatum)
            let date = df.date(from: dStr) ?? altDF.date(from: dStr) ?? Date()

            func dbl(_ i: Int?) -> Double {
                let s = val(i).replacingOccurrences(of: ",", with: ".")
                return Double(s) ?? 0
            }

            let row = RecordRow(
                datum: date,
                locatie: val(iLoc).isEmpty ? "Onbekend" : val(iLoc),
                deurbreedte: dbl(iWidth),
                tempBinnen: dbl(iTin),
                tempBuiten: dbl(iTout),
                warmteverliesMJ: dbl(iMJ),
                gasBesparingM3: dbl(iM3),
                kostenBesparingEUR: dbl(iEUR)
            )
            rows.append(row)
        }
        return rows
    }
}

@MainActor
final class ImportCoordinator: ObservableObject {
    let objectWillChange = ObservableObjectPublisher() // nodig als je geen @Published hebt
    static let shared = ImportCoordinator()
    private let importers: [DataImporter] = [CSVImporter()] // later: add XlsxImporter

    func importFile(url: URL) async throws -> [RecordRow] {
        if let importer = importers.first(where: { $0.canImport(url: url) }) {
            return try await importer.importData(from: url)
        } else {
            throw NSError(domain: "Import", code: 415, userInfo: [NSLocalizedDescriptionKey: "Bestandstype niet ondersteund. Exporteer Excel naar CSV."])
        }
    }
}
