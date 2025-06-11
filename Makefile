# Defining variables for all scripts
SCRIPTS_DIR := scripts
INIT_APP_SCRIPT := $(SCRIPTS_DIR)/init_app.sh
CLEAN_IOS_SCRIPT := $(SCRIPTS_DIR)/clean_ios.sh
CODEGEN_SCRIPT := $(SCRIPTS_DIR)/build_runner.sh
INTL_SCRIPT := $(SCRIPTS_DIR)/intl_with_format.sh
FORMAT_SCRIPT := $(SCRIPTS_DIR)/format.sh
FLUTTER_ANALYZE := $(SCRIPTS_DIR)/flutter_analyze.sh

# Tasks to run each script
init_app:
	sh $(INIT_APP_SCRIPT)

clean_ios:
	sh $(CLEAN_IOS_SCRIPT)

codegen:
	sh $(CODEGEN_SCRIPT)

intl_with_format:
	sh $(INTL_SCRIPT)

format:
	sh $(FORMAT_SCRIPT)

analyze:
	sh $(FLUTTER_ANALYZE)

# By default, we display a message about available tasks
all:
	@echo "Available tasks:"
	@echo " - init_app: flutter clean, clean_ios, pub get, pub run build_runner, dart format -l 120"
	@echo " - clean_ios: Clears local dependencies for iOS."
	@echo " - codegen: build_runner build & dart format"
	@echo " - intl_with_format: Intl generation with formatting"
	@echo " - format: fvm dart format -l 120 lib test"
	@echo " - analyze: flutter analyze"
