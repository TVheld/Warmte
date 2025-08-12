iOS Dashboard PoC — SwiftUI (CSV importer + Charts)

What you get:
- A working SwiftUI app source bundle with: CSV import, Core Data storage, Dashboard with KPI cards and Charts, and a simple mapping layer.
- No external dependencies required (uses Swift Charts from Apple). XLSX files can be used by exporting to CSV (File > Save As > CSV) for the PoC.

How to set up (Xcode 15+ / iOS 17+ recommended):
1) Open Xcode → File → New → App
   - Product Name: WarmteverliesDashboard
   - Interface: SwiftUI
   - Language: Swift
   - Use Core Data: CHECKED
   - Include Tests: optional
2) After project creation, delete the default ContentView.swift and WarmteverliesDashboardApp.swift files.
3) Drag the files from this folder into your Xcode project (copy if needed):
   - App/WarmteverliesDashboardApp.swift
   - Models/DomainModels.swift
   - Services/Persistence.swift (replaces/extends your Core Data stack)
   - Services/Importing.swift
   - ViewModels/DashboardVM.swift
   - Views/DashboardView.swift
   - Views/ImportButton.swift
   - Resources/SampleData.csv
4) Ensure your target minimum iOS is 16.0 or later (Targets → iOS Deployment Target).
5) Build & run on a simulator or device.
6) In the app, tap “Importeer bestand” and select Resources/SampleData.csv or your own CSV export.
   - For Excel: open the .xlsx in Excel/LibreOffice and "Save As…" → CSV (UTF‑8). Then import.

Notes:
- This PoC normalizes typical columns (Datum, Locatie, Deurbreedte, TempBinnen, TempBuiten, WarmteverliesMJ, GasBesparingM3, KostenBesparingEUR).
- If your CSV headers differ, the app will try to match by fuzzy names; you can tweak the header map in Importing.swift.
- Later, to support native .xlsx on-device, you can add the CoreXLSX package and implement XlsxImporter that conforms to DataImporter.

Enjoy!