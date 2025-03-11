//
//  ContentView.swift
//  StreamLine
//
//  Created by Liwen on 2025/3/11.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var events: [Item]
    @State private var showingAddEvent = false
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // 事件列表标签页
            NavigationStack {
                ZStack {
                    List {
                        ForEach(events) { event in
                            NavigationLink {
                                EventDetailView(event: event)
                            } label: {
                                HStack {
                                    Text(event.emoji)
                                        .font(.title)
                                        .padding(.trailing, 10)
                                    
                                    VStack(alignment: .leading) {
                                        Text(event.title)
                                            .font(.headline)
                                        Text(event.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .navigationTitle("我的事件")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                    }
                    
                    // 浮动添加按钮
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showingAddEvent = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title)
                                    .frame(width: 60, height: 60)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .padding()
                        }
                    }
                }
                .sheet(isPresented: $showingAddEvent) {
                    AddEventView()
                }
            }
            .tabItem {
                Label("事件", systemImage: "list.bullet")
            }
            .tag(0)
            
            // 日历标签页
            CalendarView(events: events)
                .tabItem {
                    Label("日历", systemImage: "calendar")
                }
                .tag(1)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(events[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
