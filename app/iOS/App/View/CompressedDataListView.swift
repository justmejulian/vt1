//
//  vt1 Mobile App
//
//  Created by Julian Visser on 24.04.2024.
//

import SwiftUI
import SwiftData
import OSLog
import Foundation

struct CompressedDataListView: View {
    @ObservationIgnored
    let compressedDataListViewModel: CompressedDataListViewModel
    
    @Query var compressedDataList: [CompressedData]

    @State private var isConfirming: Bool = false
    @State private var exporting: Bool = false

    init(dataSource: DataSource) {
        self.compressedDataListViewModel = CompressedDataListViewModel(dataSource: dataSource)
    }

    var body: some View {
        Text("List of Compressed Sensor Data")
            .font(.title3)
            .bold()
        
        Spacer()
        
        if compressedDataList.isEmpty {
            VStack{
                Spacer()
                Text("Looks like there are no Compressed Sensor Data yet...")
                Spacer()
                Button(action: {
                    compressedDataListViewModel.compressData()
                }) {
                    Label("Compress All", systemImage: "trash")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .onAppear {
                Logger.viewCycle.info("CompressedDataListView Empty VStack Appeared!")
            }
        } else {
            NavigationStack {
                List(compressedDataList) { compressedData in
                    VStack{
                        Button(String(compressedData.fileName)) {
                            exporting = true
                        }
                        .fileExporter(
                            isPresented: $exporting,
                            document: compressedData,
                            contentType: .json,
                            defaultFilename: compressedData.fileName
                        ){ result in
                            switch result {
                            case .success(let url):
                                print("Saved to \(url)")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
                    .listStyle(.automatic)
                
                VStack{
                    Button(action: {
                        compressedDataListViewModel.compressData()
                    }) {
                        Label("Compress All", systemImage: "trash")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                    Button(action: {
                        isConfirming = true
                    }) {
                        Label("Delete All", systemImage: "trash")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .confirmationDialog(
                        "Are you sure you want delete all?",
                        isPresented: $isConfirming
                    ) {
                        // todo move to
                        Button("Delete All", role: .destructive) {
                            compressedDataListViewModel.clearAll()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .onAppear {
                Logger.viewCycle.info("RecordingListView NavigationStack Appeared!")
            }
        }
    }
}
