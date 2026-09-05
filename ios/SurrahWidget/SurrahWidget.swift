import WidgetKit
import SwiftUI

// MARK: - Transaction Model for Widget
struct WidgetTransaction: Identifiable, Decodable {
    let id: Int
    let title: String
    let amount: Double
    let amount_formatted: String
    let type: String
    let category: String
    let date: String
    
    var isExpense: Bool {
        return type.lowercased() == "expense"
    }
    var isIncome: Bool {
        return type.lowercased() == "income"
    }
    var isTransfer: Bool {
        return type.lowercased() == "transfer"
    }
}

// MARK: - Timeline Entry
struct FinancialWidgetEntry: TimelineEntry {
    let date: Date
    let hasActiveWallet: Bool
    let walletName: String
    let walletBalanceFormatted: String
    let currencySymbol: String
    let todayIncomeFormatted: String
    let todayExpensesFormatted: String
    let incomeTodayLabel: String
    let expensesTodayLabel: String
    let recentTransactionsLabel: String
    let addTransactionLabel: String
    let noActiveWalletLabel: String
    let noTransactionsTodayLabel: String
    let noRecentTransactionsLabel: String
    let openAppLabel: String
    let isRtl: Bool
    let hideBalance: Bool
    let recentTransactions: [WidgetTransaction]
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FinancialWidgetEntry {
        FinancialWidgetEntry(
            date: Date(),
            hasActiveWallet: true,
            walletName: "Main Wallet",
            walletBalanceFormatted: "1,250,000 IQD",
            currencySymbol: "IQD",
            todayIncomeFormatted: "+100,000 IQD",
            todayExpensesFormatted: "-25,000 IQD",
            incomeTodayLabel: "Income today",
            expensesTodayLabel: "Expenses today",
            recentTransactionsLabel: "Recent Transactions",
            addTransactionLabel: "+ Add Transaction",
            noActiveWalletLabel: "No active wallet",
            noTransactionsTodayLabel: "No transactions today",
            noRecentTransactionsLabel: "No recent transactions",
            openAppLabel: "Open Pockaw",
            isRtl: false,
            hideBalance: false,
            recentTransactions: [
                WidgetTransaction(id: 1, title: "Coffee", amount: 5000, amount_formatted: "-5,000 IQD", type: "expense", category: "Food & Drinks", date: ""),
                WidgetTransaction(id: 2, title: "Groceries", amount: 35000, amount_formatted: "-35,000 IQD", type: "expense", category: "Groceries", date: ""),
                WidgetTransaction(id: 3, title: "Salary", amount: 500000, amount_formatted: "+500,000 IQD", type: "income", category: "Salary", date: "")
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FinancialWidgetEntry) -> ()) {
        let entry = getEntryFromUserDefaults()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FinancialWidgetEntry>) -> ()) {
        let entry = getEntryFromUserDefaults()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func getEntryFromUserDefaults() -> FinancialWidgetEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.haider.surrah")
        
        let hasActiveWallet = userDefaults?.object(forKey: "has_active_wallet") as? Bool ?? true
        let walletName = userDefaults?.string(forKey: "wallet_name") ?? (userDefaults?.string(forKey: "widget_title") ?? "Main Wallet")
        let currencySymbol = userDefaults?.string(forKey: "currency") ?? "IQD"
        
        let hideBalance = userDefaults?.bool(forKey: "hide_balance") ?? false
        let isRtl = userDefaults?.bool(forKey: "is_rtl") ?? false
        
        // Formatted strings
        var balanceStr = userDefaults?.string(forKey: "wallet_balance_formatted")
        if balanceStr == nil || balanceStr!.isEmpty {
            if let totalVal = userDefaults?.double(forKey: "total_balance") {
                balanceStr = String(format: "%.0f %@", totalVal, currencySymbol)
            } else {
                balanceStr = "0 " + currencySymbol
            }
        }
        
        var todayIncomeStr = userDefaults?.string(forKey: "today_income_formatted")
        if todayIncomeStr == nil || todayIncomeStr!.isEmpty {
            let incVal = userDefaults?.double(forKey: "today_income") ?? 0.0
            todayIncomeStr = String(format: "+%.0f %@", incVal, currencySymbol)
        }
        
        var todayExpensesStr = userDefaults?.string(forKey: "today_expenses_formatted")
        if todayExpensesStr == nil || todayExpensesStr!.isEmpty {
            let expVal = userDefaults?.double(forKey: "today_spent") ?? (userDefaults?.double(forKey: "today_expenses") ?? 0.0)
            todayExpensesStr = String(format: "-%.0f %@", expVal, currencySymbol)
        }
        
        // Labels
        let incomeTodayLabel = userDefaults?.string(forKey: "income_today_label") ?? (isRtl ? "دخل اليوم" : "Income today")
        let expensesTodayLabel = userDefaults?.string(forKey: "expenses_today_label") ?? (userDefaults?.string(forKey: "today_spent_label") ?? (isRtl ? "مصاريف اليوم" : "Expenses today"))
        let recentTransactionsLabel = userDefaults?.string(forKey: "recent_transactions_label") ?? (isRtl ? "أحدث المعاملات" : "Recent Transactions")
        let addTransactionLabel = userDefaults?.string(forKey: "add_transaction_label") ?? (userDefaults?.string(forKey: "quick_add_label") ?? (isRtl ? "+ إضافة معاملة" : "+ Add Transaction"))
        let noActiveWalletLabel = userDefaults?.string(forKey: "no_active_wallet_label") ?? (isRtl ? "لا توجد محفظة نشطة" : "No active wallet")
        let noTransactionsTodayLabel = userDefaults?.string(forKey: "no_transactions_today_label") ?? (isRtl ? "لا توجد معاملات اليوم" : "No transactions today")
        let noRecentTransactionsLabel = userDefaults?.string(forKey: "no_recent_transactions_label") ?? (isRtl ? "لا توجد معاملات مؤخراً" : "No recent transactions")
        let openAppLabel = userDefaults?.string(forKey: "open_app_label") ?? (isRtl ? "فتح صُـرّة" : "Open Pockaw")
        
        // Parse recent transactions JSON
        var recentTransactions: [WidgetTransaction] = []
        if let jsonString = userDefaults?.string(forKey: "recent_transactions"),
           let jsonData = jsonString.data(using: .utf8) {
            do {
                recentTransactions = try JSONDecoder().decode([WidgetTransaction].self, from: jsonData)
            } catch {
                recentTransactions = []
            }
        }

        return FinancialWidgetEntry(
            date: Date(),
            hasActiveWallet: hasActiveWallet,
            walletName: walletName,
            walletBalanceFormatted: hideBalance ? "•••• \(currencySymbol)" : balanceStr!,
            currencySymbol: currencySymbol,
            todayIncomeFormatted: todayIncomeStr!,
            todayExpensesFormatted: todayExpensesStr!,
            incomeTodayLabel: incomeTodayLabel,
            expensesTodayLabel: expensesTodayLabel,
            recentTransactionsLabel: recentTransactionsLabel,
            addTransactionLabel: addTransactionLabel,
            noActiveWalletLabel: noActiveWalletLabel,
            noTransactionsTodayLabel: noTransactionsTodayLabel,
            noRecentTransactionsLabel: noRecentTransactionsLabel,
            openAppLabel: openAppLabel,
            isRtl: isRtl,
            hideBalance: hideBalance,
            recentTransactions: recentTransactions
        )
    }
}

// MARK: - Colors & Theme
struct SarraTheme {
    static let backgroundStart = Color(red: 0.05, green: 0.0, blue: 0.07)
    static let backgroundEnd = Color(red: 0.12, green: 0.05, blue: 0.15)
    static let cardBackground = Color(white: 1.0, opacity: 0.07)
    static let cardBorder = Color(white: 1.0, opacity: 0.10)
    
    static let primaryCyan = Color(red: 0.0, green: 0.80, blue: 0.80)     // #00CCCD
    static let primaryCyanSoft = Color(red: 0.10, green: 0.91, blue: 0.90) // #19E8E6
    static let incomeGreen = Color(red: 0.32, green: 0.87, blue: 0.51)     // #52DF83
    static let expenseRed = Color(red: 1.0, green: 0.17, blue: 0.43)      // #FF2C6D
    static let transferBlue = Color(red: 0.30, green: 0.60, blue: 1.0)     // Blue for transfer
    static let neutralSubtext = Color(red: 0.70, green: 0.70, blue: 0.73) // #B0B0B0
    static let neutralDark = Color(red: 0.13, green: 0.15, blue: 0.17)
}

// MARK: - Small Widget View (Edge-to-Edge Fill)
struct SmallWidgetView: View {
    let entry: FinancialWidgetEntry

    var body: some View {
        Link(destination: URL(string: "surrah://manage-wallets")!) {
            VStack(alignment: entry.isRtl ? .trailing : .leading, spacing: 0) {
                if !entry.hasActiveWallet {
                    Spacer()
                    Image(systemName: "wallet.pass")
                        .font(.system(size: 24))
                        .foregroundColor(SarraTheme.primaryCyan)
                        .padding(.bottom, 6)
                    Text(entry.noActiveWalletLabel)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Text(entry.openAppLabel)
                        .font(.system(size: 11))
                        .foregroundColor(SarraTheme.neutralSubtext)
                    Spacer()
                } else {
                    // Header: Wallet Name
                    HStack {
                        if entry.isRtl { Spacer() }
                        HStack(spacing: 5) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 11))
                                .foregroundColor(SarraTheme.primaryCyan)
                            Text(entry.walletName)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(SarraTheme.primaryCyan)
                                .lineLimit(1)
                        }
                        if !entry.isRtl { Spacer() }
                    }
                    
                    Spacer()
                    
                    // Balance Section (Visual Focal Point)
                    VStack(alignment: entry.isRtl ? .trailing : .leading, spacing: 2) {
                        Text(entry.isRtl ? "الرصيد الحالي" : "Current Balance")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(SarraTheme.neutralSubtext)
                        
                        Text(entry.walletBalanceFormatted)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.65)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Quick Expense & Income Links
                    HStack(spacing: 6) {
                        Link(destination: URL(string: "surrah://add_transaction?type=expense")!) {
                            HStack(spacing: 3) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 9))
                                Text(entry.isRtl ? "مصروف" : "Expense")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(SarraTheme.expenseRed)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(SarraTheme.expenseRed.opacity(0.15))
                            .cornerRadius(6)
                        }
                        
                        Link(destination: URL(string: "surrah://add_transaction?type=income")!) {
                            HStack(spacing: 3) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 9))
                                Text(entry.isRtl ? "دخل" : "Income")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundColor(SarraTheme.incomeGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(SarraTheme.incomeGreen.opacity(0.15))
                            .cornerRadius(6)
                        }
                    }
                    .environment(\.layoutDirection, entry.isRtl ? .rightToLeft : .leftToRight)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Medium Widget View (Edge-to-Edge Fill)
struct MediumWidgetView: View {
    let entry: FinancialWidgetEntry

    var body: some View {
        VStack(alignment: entry.isRtl ? .trailing : .leading, spacing: 8) {
            if !entry.hasActiveWallet {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 28))
                            .foregroundColor(SarraTheme.primaryCyan)
                        Text(entry.noActiveWalletLabel)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text(entry.openAppLabel)
                            .font(.system(size: 12))
                            .foregroundColor(SarraTheme.neutralSubtext)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                // Top Row: Active Wallet Header & Balance
                HStack(alignment: .top) {
                    Link(destination: URL(string: "surrah://manage-wallets")!) {
                        VStack(alignment: entry.isRtl ? .trailing : .leading, spacing: 2) {
                            HStack(spacing: 5) {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(SarraTheme.primaryCyan)
                                Text(entry.walletName)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(SarraTheme.primaryCyan)
                                    .lineLimit(1)
                            }
                            Text(entry.walletBalanceFormatted)
                                .font(.system(size: 21, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.7)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    // Quick Action Action Buttons: Expense, Income, Transfer
                    HStack(spacing: 5) {
                        Link(destination: URL(string: "surrah://add_transaction?type=expense")!) {
                            HStack(spacing: 2) {
                                Text("-")
                                    .font(.system(size: 13, weight: .black))
                                Text(entry.isRtl ? "مصروف" : "Expense")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(SarraTheme.expenseRed)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(SarraTheme.expenseRed.opacity(0.18))
                            .cornerRadius(8)
                        }
                        
                        Link(destination: URL(string: "surrah://add_transaction?type=income")!) {
                            HStack(spacing: 2) {
                                Text("+")
                                    .font(.system(size: 13, weight: .black))
                                Text(entry.isRtl ? "دخل" : "Income")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(SarraTheme.incomeGreen)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(SarraTheme.incomeGreen.opacity(0.18))
                            .cornerRadius(8)
                        }

                        Link(destination: URL(string: "surrah://add_transaction?type=transfer")!) {
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 8, weight: .bold))
                                Text(entry.isRtl ? "تحويل" : "Transfer")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundColor(SarraTheme.transferBlue)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(SarraTheme.transferBlue.opacity(0.18))
                            .cornerRadius(8)
                        }
                    }
                }
                .environment(\.layoutDirection, entry.isRtl ? .rightToLeft : .leftToRight)
                
                Spacer()
                
                // Cash Flow Cards (Income Today & Expenses Today)
                HStack(spacing: 8) {
                    // Income Card
                    HStack(spacing: 6) {
                        Circle()
                            .fill(SarraTheme.incomeGreen.opacity(0.18))
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "arrow.down.left")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(SarraTheme.incomeGreen)
                            )
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(entry.incomeTodayLabel)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(SarraTheme.neutralSubtext)
                                .lineLimit(1)
                            Text(entry.todayIncomeFormatted)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(SarraTheme.incomeGreen)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(7)
                    .background(SarraTheme.cardBackground)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SarraTheme.cardBorder, lineWidth: 1))
                    .cornerRadius(8)
                    
                    // Expenses Card
                    HStack(spacing: 6) {
                        Circle()
                            .fill(SarraTheme.expenseRed.opacity(0.18))
                            .frame(width: 22, height: 22)
                            .overlay(
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(SarraTheme.expenseRed)
                            )
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(entry.expensesTodayLabel)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(SarraTheme.neutralSubtext)
                                .lineLimit(1)
                            Text(entry.todayExpensesFormatted)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(SarraTheme.expenseRed)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(7)
                    .background(SarraTheme.cardBackground)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(SarraTheme.cardBorder, lineWidth: 1))
                    .cornerRadius(8)
                }
                .environment(\.layoutDirection, entry.isRtl ? .rightToLeft : .leftToRight)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Large Widget View (Edge-to-Edge Fill)
struct LargeWidgetView: View {
    let entry: FinancialWidgetEntry

    var body: some View {
        VStack(alignment: entry.isRtl ? .trailing : .leading, spacing: 8) {
            // Header Row: Wallet Name & Balance Link
            Link(destination: URL(string: "surrah://manage-wallets")!) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 12))
                            .foregroundColor(SarraTheme.primaryCyan)
                        Text(entry.walletName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(SarraTheme.primaryCyan)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text(entry.walletBalanceFormatted)
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
                .environment(\.layoutDirection, entry.isRtl ? .rightToLeft : .leftToRight)
            }
            
            // Income vs Expenses Strip
            HStack(spacing: 8) {
                // Income Badge
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.left")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SarraTheme.incomeGreen)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(entry.incomeTodayLabel)
                            .font(.system(size: 9))
                            .foregroundColor(SarraTheme.neutralSubtext)
                        Text(entry.todayIncomeFormatted)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(SarraTheme.incomeGreen)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(6)
                .background(SarraTheme.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SarraTheme.cardBorder, lineWidth: 1))
                .cornerRadius(8)
                
                // Expense Badge
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(SarraTheme.expenseRed)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(entry.expensesTodayLabel)
                            .font(.system(size: 9))
                            .foregroundColor(SarraTheme.neutralSubtext)
                        Text(entry.todayExpensesFormatted)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(SarraTheme.expenseRed)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(6)
                .background(SarraTheme.cardBackground)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SarraTheme.cardBorder, lineWidth: 1))
                .cornerRadius(8)
            }
            .environment(\.layoutDirection, entry.isRtl ? .rightToLeft : .leftToRight)
            
            // Recent Transactions Section Header
            HStack {
                Text(entry.recentTransactionsLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(SarraTheme.neutralSubtext)
                Spacer()
            }
            .environment(\.layoutDirection, entry.isRtl ? .rightToLeft : .leftToRight)
            
            // Recent Transactions List (2-3 items)
            VStack(spacing: 5) {
                if entry.recentTransactions.isEmpty {
                    Spacer()
                    Text(entry.noRecentTransactionsLabel)
                        .font(.system(size: 11))
                        .foregroundColor(SarraTheme.neutralSubtext)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    ForEach(entry.recentTransactions.prefix(3)) { tx in
                        let txColor = tx.isIncome ? SarraTheme.incomeGreen : (tx.isTransfer ? SarraTheme.transferBlue : SarraTheme.expenseRed)
                        let txIcon = tx.isIncome ? "banknote.fill" : (tx.isTransfer ? "arrow.left.arrow.right" : "cart.fill")

                        Link(destination: URL(string: "surrah://transaction/\(tx.id)")!) {
                            HStack(spacing: 7) {
                                Circle()
                                    .fill(txColor.opacity(0.15))
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        Image(systemName: txIcon)
                                            .font(.system(size: 10))
                                            .foregroundColor(txColor)
                                    )
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(tx.title)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Text(tx.category)
                                        .font(.system(size: 9))
                                        .foregroundColor(SarraTheme.neutralSubtext)
                                        .lineLimit(1)
                                
                                }
                                
                                Spacer()
                                
                                Text(tx.amount_formatted)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(txColor)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(SarraTheme.cardBackground)
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(SarraTheme.cardBorder, lineWidth: 1))
                            .cornerRadius(7)
                        }
                        .environment(\.layoutDirection, entry.isRtl ? .rightToLeft : .leftToRight)
                    }
                }
            }
            
            Spacer()
            
            // Bottom Action Bar: [Expense] [Income] [Transfer]
            HStack(spacing: 6) {
                Link(destination: URL(string: "surrah://add_transaction?type=expense")!) {
                    HStack(spacing: 3) {
                        Text("-")
                            .font(.system(size: 13, weight: .black))
                        Text(entry.isRtl ? "مصروف" : "Expense")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(SarraTheme.expenseRed)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(SarraTheme.expenseRed.opacity(0.18))
                    .cornerRadius(8)
                }

                Link(destination: URL(string: "surrah://add_transaction?type=income")!) {
                    HStack(spacing: 3) {
                        Text("+")
                            .font(.system(size: 13, weight: .black))
                        Text(entry.isRtl ? "دخل" : "Income")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(SarraTheme.incomeGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(SarraTheme.incomeGreen.opacity(0.18))
                    .cornerRadius(8)
                }

                Link(destination: URL(string: "surrah://add_transaction?type=transfer")!) {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 9, weight: .bold))
                        Text(entry.isRtl ? "تحويل" : "Transfer")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(SarraTheme.transferBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(SarraTheme.transferBlue.opacity(0.18))
                    .cornerRadius(8)
                }
            }
            .environment(\.layoutDirection, entry.isRtl ? .rightToLeft : .leftToRight)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Root Entry View Dispatcher with iOS 17 containerBackground Support
struct SurrahWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .systemLarge:
                LargeWidgetView(entry: entry)
            default:
                MediumWidgetView(entry: entry)
            }
        }
        .widgetBackground(
            LinearGradient(
                gradient: Gradient(colors: [SarraTheme.backgroundStart, SarraTheme.backgroundEnd]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Widget Background Extension for Edge-to-Edge iOS Compatibility
extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}

// MARK: - Widget Declaration
struct SurrahWidget: Widget {
    let kind: String = "SurrahWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SurrahWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Sarra Finance")
        .description("Active wallet balance, daily cash flow, and recent transactions.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabledIfAvailable()
    }
}

// MARK: - Content Margins Helper
extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
