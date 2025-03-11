import SwiftUI

struct EventDetailView: View {
    let event: Item

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(event.emoji)
                        .font(.system(size: 60))

                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.largeTitle)
                            .bold()

                        Text(
                            event.timestamp,
                            format: Date.FormatStyle(
                                date: .complete, time: .standard)
                        )
                        .foregroundColor(.secondary)
                    }
                }
                .padding()

                Divider()

                Text(event.eventDescription)
                    .padding()

                Spacer()
            }
        }
        .navigationTitle("事件详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
