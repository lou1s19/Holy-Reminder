cask "holy-reminder" do
  version "1.0.0"
  sha256 :no_check # Update this with actual SHA256 when releasing

  url "https://github.com/YOUR-USERNAME/holy-reminder/releases/download/v#{version}/HolyReminder-#{version}.zip"
  name "Holy Reminder"
  desc "Daily Bible verse reminders for macOS with mood-based selection"
  homepage "https://github.com/YOUR-USERNAME/holy-reminder"

  depends_on macos: ">= :ventura"

  app "Holy Reminder.app"

  zap trash: [
    "~/Library/Preferences/com.holyreminder.app.plist",
    "~/Library/Application Support/HolyReminder",
  ]
end
