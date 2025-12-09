.PHONY: build release clean install uninstall

# Configuration
APP_NAME = HolyReminder
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
DEBUG_DIR = $(BUILD_DIR)/debug
INSTALL_DIR = /usr/local/bin

# Build commands
build:
	@echo "🔨 Building $(APP_NAME)..."
	swift build
	@echo "✅ Build complete!"

release:
	@echo "🚀 Building release version..."
	swift build -c release
	@echo "✅ Release build complete!"
	@echo "📍 Binary: $(RELEASE_DIR)/$(APP_NAME)"

clean:
	@echo "🧹 Cleaning build artifacts..."
	swift package clean
	rm -rf $(BUILD_DIR)
	@echo "✅ Clean complete!"

install: release
	@echo "📦 Installing $(APP_NAME)..."
	cp $(RELEASE_DIR)/$(APP_NAME) $(INSTALL_DIR)/$(APP_NAME)
	@echo "✅ Installed to $(INSTALL_DIR)/$(APP_NAME)"

uninstall:
	@echo "🗑️ Uninstalling $(APP_NAME)..."
	rm -f $(INSTALL_DIR)/$(APP_NAME)
	@echo "✅ Uninstalled!"

run:
	@echo "🏃 Running $(APP_NAME)..."
	swift run

test:
	@echo "🧪 Running tests..."
	swift test

# Create distributable app bundle
bundle: release
	@echo "📦 Creating app bundle..."
	mkdir -p "$(APP_NAME).app/Contents/MacOS"
	mkdir -p "$(APP_NAME).app/Contents/Resources"
	cp $(RELEASE_DIR)/$(APP_NAME) "$(APP_NAME).app/Contents/MacOS/"
	cp Info.plist "$(APP_NAME).app/Contents/"
	@echo "✅ App bundle created: $(APP_NAME).app"

help:
	@echo "Holy Reminder Build System"
	@echo ""
	@echo "Commands:"
	@echo "  make build    - Build debug version"
	@echo "  make release  - Build optimized release version"
	@echo "  make run      - Build and run the app"
	@echo "  make install  - Install to /usr/local/bin"
	@echo "  make uninstall - Remove from /usr/local/bin"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make bundle   - Create .app bundle"
	@echo "  make help     - Show this help"
