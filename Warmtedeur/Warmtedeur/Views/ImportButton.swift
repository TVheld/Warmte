import SwiftUI
import UniformTypeIdentifiers

struct ImportButton: View {
    var onPicked: (URL) -> Void
    @State private var presenting = false

    var body: some View {
        Button {
            presenting = true
        } label: {
            Label("Importeer bestand", systemImage: "square.and.arrow.down.on.square")
        }
        .fileImporter(
            isPresented: $presenting,
            allowedContentTypes: [.commaSeparatedText, .plainText, UTType(filenameExtension: "csv")!],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                onPicked(url)
            }
        }
        .buttonStyle(.borderedProminent)
    }
}
