import SwiftUI
import SwiftData
import UserNotifications

struct ReminderListView: View {
    @Bindable var tank: Tank
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddReminder = false

    var sortedReminders: [Reminder] {
        tank.reminders.sorted { $0.nextDue < $1.nextDue }
    }

    var body: some View {
        NavigationStack {
            Group {
                if tank.reminders.isEmpty {
                    ContentUnavailableView {
                        Label(String(localized: "No Reminders"), systemImage: "bell.slash")
                    } description: {
                        Text("Set up recurring maintenance reminders.")
                    } actions: {
                        Button(String(localized: "Add Reminder")) { showingAddReminder = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(sortedReminders) { reminder in
                            ReminderRowView(reminder: reminder)
                        }
                        .onDelete { offsets in
                            for i in offsets { modelContext.delete(sortedReminders[i]) }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Reminders"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddReminder = true }) {
                        Label(String(localized: "Add"), systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            AddEditReminderView(tank: tank)
        }
    }
}

struct ReminderRowView: View {
    @Bindable var reminder: Reminder
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: reminder.isOverdue ? "exclamationmark.circle.fill" : "bell.fill")
                        .foregroundStyle(reminder.isOverdue ? .red : (reminder.isActive ? .orange : .secondary))
                    Text(reminder.title)
                        .font(.headline)
                        .strikethrough(!reminder.isActive)
                }
                Text(reminder.frequency.localizedName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Next: \(reminder.nextDue.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundStyle(reminder.isOverdue ? .red : .secondary)
            }
            Spacer()
            Button(String(localized: "Done")) {
                reminder.markDone()
                scheduleNotification(for: reminder)
            }
            .font(.caption.bold())
            .buttonStyle(.bordered)
        }
    }

    private func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = String(localized: "Time for tank maintenance!")
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.nextDue)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: reminder.persistentModelID.hashValue.description, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

struct AddEditReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let tank: Tank
    var existing: Reminder?

    @State private var title = ""
    @State private var notes = ""
    @State private var frequency: ReminderFrequency = .weekly
    @State private var customDays = 7
    @State private var nextDue = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Reminder Info")) {
                    TextField(String(localized: "Title (e.g. Water Change)"), text: $title)
                    TextField(String(localized: "Notes"), text: $notes)
                }
                Section(String(localized: "Schedule")) {
                    Picker(String(localized: "Frequency"), selection: $frequency) {
                        ForEach(ReminderFrequency.allCases, id: \.self) { f in
                            Text(f.localizedName).tag(f)
                        }
                    }
                    if frequency == .custom {
                        Stepper(String(localized: "Every \(customDays) day(s)"), value: $customDays, in: 1...365)
                    }
                    DatePicker(String(localized: "Next Due"), selection: $nextDue, displayedComponents: .date)
                }
            }
            .navigationTitle(existing != nil ? String(localized: "Edit Reminder") : String(localized: "New Reminder"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(String(localized: "Cancel")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let r = existing { title = r.title; notes = r.notes; frequency = r.frequency; customDays = r.customIntervalDays; nextDue = r.nextDue }
                requestNotificationPermission()
            }
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    private func save() {
        if let r = existing {
            r.title = title; r.notes = notes; r.frequency = frequency; r.customIntervalDays = customDays; r.nextDue = nextDue
        } else {
            let r = Reminder(title: title, notes: notes, frequency: frequency, customIntervalDays: customDays, nextDue: nextDue)
            r.tank = tank
            modelContext.insert(r)
        }
        dismiss()
    }
}
