import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            todaySpent: "0 د.ع",
            remainingBudget: "750,000 د.ع",
            budgetProgress: 0.25,
            title: "صُـرّة",
            remainingLabel: "الميزانية المتبقية",
            todaySpentLabel: "مصاريف اليوم",
            quickAddLabel: "إضافة"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getEntryFromUserDefaults()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getEntryFromUserDefaults()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func getEntryFromUserDefaults() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.haider.surrah")
        let hideBalance = userDefaults?.bool(forKey: "hide_balance") ?? false
        let todaySpentVal = userDefaults?.double(forKey: "today_spent") ?? 0
        let remainingBudgetVal = userDefaults?.double(forKey: "remaining_budget") ?? 0
        let budgetProgressVal = userDefaults?.double(forKey: "budget_progress") ?? 0
        let currency = userDefaults?.string(forKey: "currency") ?? "د.ع"

        let titleStr = userDefaults?.string(forKey: "widget_title") ?? "صُـرّة"
        let remainingLabelStr = userDefaults?.string(forKey: "remaining_budget_label") ?? "الميزانية المتبقية"
        let todaySpentLabelStr = userDefaults?.string(forKey: "today_spent_label") ?? "مصاريف اليوم"
        let quickAddLabelStr = userDefaults?.string(forKey: "quick_add_label") ?? "إضافة"

        let spentText = hideBalance ? "•••• \(currency)" : String(format: "%.0f %@", todaySpentVal, currency)
        let remainingText = hideBalance ? "•••• \(currency)" : String(format: "%.0f %@", remainingBudgetVal, currency)

        return SimpleEntry(
            date: Date(),
            todaySpent: spentText,
            remainingBudget: remainingText,
            budgetProgress: budgetProgressVal,
            title: titleStr,
            remainingLabel: remainingLabelStr,
            todaySpentLabel: todaySpentLabelStr,
            quickAddLabel: quickAddLabelStr
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todaySpent: String
    let remainingBudget: String
    let budgetProgress: Double
    let title: String
    let remainingLabel: String
    let todaySpentLabel: String
    let quickAddLabel: String
}

struct SurrahWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Link(destination: URL(string: "pockaw://add_transaction")!) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.80, blue: 0.80))
                    Spacer()
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.0, green: 0.80, blue: 0.80))
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: geometry.size.width, height: 6)
                            .foregroundColor(Color(red: 0.17, green: 0.10, blue: 0.21))
                        RoundedRectangle(cornerRadius: 3)
                            .frame(width: geometry.size.width * CGFloat(min(max(entry.budgetProgress, 0.0), 1.0)), height: 6)
                            .foregroundColor(Color(red: 0.0, green: 0.80, blue: 0.80))
                    }
                }
                .frame(height: 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.remainingLabel)
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.69, green: 0.69, blue: 0.69))
                    Text(entry.remainingBudget)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.todaySpentLabel)
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.69, green: 0.69, blue: 0.69))
                    Text(entry.todaySpent)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.30, blue: 0.50))
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.05, green: 0.0, blue: 0.07), Color(red: 0.12, green: 0.06, blue: 0.15)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct SurrahWidget: Widget {
    let kind: String = "SurrahWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SurrahWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Pockaw Widget")
        .description("متابعة سريعة للميزانية ومصاريف اليوم")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
