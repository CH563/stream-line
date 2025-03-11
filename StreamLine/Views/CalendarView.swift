import SwiftData
import SwiftUI

struct CalendarView: View {
    let events: [Item]
    @State private var selectedDate = Date()

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // 设置周一为一周的第一天
        return calendar
    }

    var body: some View {
        NavigationStack {
            VStack {
                // 日历视图
                CalendarGridView(
                    selectedDate: $selectedDate,
                    events: events
                )

                Divider()

                // 选中日期的事件列表
                List {
                    let dayEvents = eventsForSelectedDate()
                    if dayEvents.isEmpty {
                        Text("当天没有事件")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(dayEvents) { event in
                            NavigationLink {
                                EventDetailView(event: event)
                            } label: {
                                HStack {
                                    Text(event.emoji)
                                        .font(.title2)

                                    VStack(alignment: .leading) {
                                        Text(event.title)
                                            .font(.headline)
                                        Text(
                                            event.timestamp,
                                            format: .dateTime.hour().minute()
                                        )
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("日历视图")
        }
    }

    private func eventsForSelectedDate() -> [Item] {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return events.filter { event in
            event.timestamp >= startOfDay && event.timestamp < endOfDay
        }
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    let events: [Item]

    @State private var currentMonth = Date()

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // 设置周一为一周的第一天
        return calendar
    }

    var body: some View {
        VStack {
            // 月份选择器
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(monthYearFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // 星期标题
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 日历网格
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 7),
                spacing: 10
            ) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayView(
                            date: date,
                            isSelected: calendar.isDate(
                                date, inSameDayAs: selectedDate),
                            hasEvents: hasEvents(on: date),
                            eventEmojis: eventEmojisForDate(date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        // 空白单元格
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        // 调整顺序，使周一在前
        if calendar.firstWeekday == 2 {
            return Array(symbols[1...]) + [symbols[0]]
        }
        return symbols
    }

    private func daysInMonth() -> [Date?] {
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let firstDay = calendar.date(
            from: calendar.dateComponents([.year, .month], from: currentMonth))!

        // 获取月份第一天是星期几
        let firstWeekday = calendar.component(.weekday, from: firstDay)

        // 计算需要在第一天之前添加多少个空白单元格
        let offsetDays = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days = Array(repeating: nil as Date?, count: offsetDays)

        for day in 1...range.count {
            if let date = calendar.date(
                byAdding: .day, value: day - 1, to: firstDay)
            {
                days.append(date)
            }
        }

        // 补齐最后一行
        let remainingCells = (7 - (days.count % 7)) % 7
        days += Array(repeating: nil as Date?, count: remainingCells)

        return days
    }

    private func hasEvents(on date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return events.contains { event in
            event.timestamp >= startOfDay && event.timestamp < endOfDay
        }
    }

    private func eventEmojisForDate(_ date: Date) -> [String] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return
            events
            .filter { event in
                event.timestamp >= startOfDay && event.timestamp < endOfDay
            }
            .map { $0.emoji }
    }

    private func previousMonth() {
        if let newDate = calendar.date(
            byAdding: .month, value: -1, to: currentMonth)
        {
            currentMonth = newDate
        }
    }

    private func nextMonth() {
        if let newDate = calendar.date(
            byAdding: .month, value: 1, to: currentMonth)
        {
            currentMonth = newDate
        }
    }
}

struct DayView: View {
    let date: Date
    let isSelected: Bool
    let hasEvents: Bool
    let eventEmojis: [String]

    private var calendar: Calendar {
        Calendar.current
    }

    var body: some View {
        VStack {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 30, height: 30)
                .background(isSelected ? Color.blue : Color.clear)
                .clipShape(Circle())

            if hasEvents {
                HStack(spacing: 2) {
                    ForEach(Array(Set(eventEmojis)).prefix(3), id: \.self) {
                        emoji in
                        Text(emoji)
                            .font(.system(size: 10))
                    }
                }
                .frame(height: 12)
            } else {
                Spacer()
                    .frame(height: 12)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    let previewEvents = [
        Item(
            timestamp: Date(), title: "测试事件1", eventDescription: "描述",
            emoji: "🎉"),
        Item(
            timestamp: Date().addingTimeInterval(86400), title: "测试事件2",
            eventDescription: "描述", emoji: "🚀"),
    ]

    return CalendarView(events: previewEvents)
}
