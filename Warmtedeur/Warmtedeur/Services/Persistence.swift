import CoreData
import Combine


@MainActor
final class PersistenceController: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "WarmteverliesModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func batchInsert(records: [RecordRow]) throws {
        let ctx = container.viewContext
        for r in records {
            let obj = CDRecord(context: ctx)
            obj.id = UUID()
            obj.date = r.datum
            obj.location = r.locatie
            obj.doorWidth = r.deurbreedte
            obj.tempInside = r.tempBinnen
            obj.tempOutside = r.tempBuiten
            obj.lossMJ = r.warmteverliesMJ
            obj.savedM3 = r.gasBesparingM3
            obj.savedEUR = r.kostenBesparingEUR
        }
        try ctx.save()
    }

    func fetchAll() throws -> [RecordRow] {
        let req = NSFetchRequest<CDRecord>(entityName: "CDRecord")
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let items = try container.viewContext.fetch(req)
        return items.map { i in
            RecordRow(
                datum: i.date ?? Date(),
                locatie: i.location ?? "—",
                deurbreedte: i.doorWidth,
                tempBinnen: i.tempInside,
                tempBuiten: i.tempOutside,
                warmteverliesMJ: i.lossMJ,
                gasBesparingM3: i.savedM3,
                kostenBesparingEUR: i.savedEUR
            )
        }
    }

    func wipe() throws {
        let ctx = container.viewContext
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CDRecord")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetch)
        try ctx.execute(batchDelete)
        try ctx.save()
    }
}

