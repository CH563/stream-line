import SwiftUI

struct AddEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var emoji = "📝"
    
    let emojiOptions = ["📝", "🎉", "💼", "🏆", "🚀", "🎯", "📅", "🔍", "💡", "🛠️"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("事件信息")) {
                    TextField("标题", text: $title)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("描述")
                                .foregroundColor(.gray.opacity(0.8))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                }
                
                Section(header: Text("选择图标")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))]) {
                        ForEach(emojiOptions, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title)
                                .padding(8)
                                .background(self.emoji == emoji ? Color.blue.opacity(0.2) : Color.clear)
                                .clipShape(Circle())
                                .onTapGesture {
                                    self.emoji = emoji
                                }
                        }
                    }
                }
            }
            .navigationTitle("添加新事件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveEvent() {
        let newEvent = Item(
            timestamp: Date(),
            title: title,
            eventDescription: description,
            emoji: emoji
        )
        
        modelContext.insert(newEvent)
        dismiss()
    }
}
