# Commands
LUAC := luac
LUAC_FLAGS := -p
LUACHECK := luacheck
LUACHECK_FLAGS := --no-color --codes --std luajit
BUSTED = busted

# Directories
BUILD_DIR := ./.build-output
DATA_DIR := $(BUILD_DIR)/data
LOG_DIR := $(BUILD_DIR)/logs
TIMESTAMP := $(shell date +"%Y-%m-%d_%H-%M-%S")
NVIM_LOG_FILE := $(LOG_DIR)/nvim-ci-$(TIMESTAMP).log
LINT_WARNINGS_FILE := $(BUILD_DIR)/lint-warnings.log

# Colors
BLUE := \033[1;34m
GREEN := \033[1;32m
RED := \033[1;31m
YELLOW := \033[1;33m
RESET := \033[0m

# Preserve build output if set (default: 0)
KEEP_BUILD ?= 0

# Find all Lua files in the current directory, but exclude $(DATA_DIR)
LUA_FILES := $(shell find . -type f -name '*.lua' ! -path "$(DATA_DIR)/*")

# Default target
all: prepare compile test lint report_warnings success_cleanup

# Install dependencies
install:
	@echo "Installing dependencies..."
	luarocks install luacheck
	luarocks install busted

# Ensure necessary directories exist
prepare:
	@echo "$(BLUE)========== PREPARING BUILD ENVIRONMENT ==========$(RESET)"
	@# reminding myself what the name of the variable is to preserve the build output
	@echo "$(BLUE)Tip: Run 'make KEEP_BUILD=1' to preserve .build-output even on success$(RESET)"
	@mkdir -p $(DATA_DIR) $(LOG_DIR)
	@rm -f $(LINT_WARNINGS_FILE)
	@echo "$(GREEN)Preparation complete ✅$(RESET)"

# Syntax Check using luac
compile: prepare
	@echo "$(BLUE)========== COMPILING LUA ==========$(RESET)"
	@if [ -n "$(LUA_FILES)" ]; then \
		for file in $(LUA_FILES); do \
			echo "Checking $$file..."; \
			if ! $(LUAC) $(LUAC_FLAGS) $$file; then \
				echo "$(RED)Syntax check failed ❌$(RESET)"; \
				exit 1; \
			fi; \
		done; \
		echo "$(GREEN)Syntax check passed ✅$(RESET)"; \
	else \
		echo "No Lua files found, skipping syntax check."; \
	fi
	@echo "------------------------------------------"

# Linting using luacheck
lint: prepare
	@echo "$(BLUE)========== RUNNING LUA LINTER ==========$(RESET)"
	@if [ -n "$(LUA_FILES)" ]; then \
		$(LUACHECK) $(LUACHECK_FLAGS) $(LUA_FILES) 2>&1 | tee $(LINT_WARNINGS_FILE) | ( \
			EXIT_CODE=$$?; \
			if [ $$EXIT_CODE -ne 1 ]; then exit $$EXIT_CODE; fi \
		); \
	else \
		echo "No Lua files found, skipping linting."; \
	fi
	@echo "$(GREEN)Lint check completed (warnings allowed) ✅$(RESET)"
	@echo "------------------------------------------"

# Run a sanity test suite
test: prepare
	@echo "$(BLUE)========== RUNNING NEOVIM CONFIGURATION TEST ==========$(RESET)"
	@XDG_CONFIG_HOME=$(PWD) \
	 XDG_DATA_HOME=$(DATA_DIR) \
	 NVIM_LOG_FILE=$(NVIM_LOG_FILE) \
	 nvim --headless -V1$(NVIM_LOG_FILE) -c "lua require('test.run-all-tests')" -c "qa!" || (echo "$(RED)Neovim test failed ❌$(RESET)"; exit 1)
	@if grep -E "^E" $(NVIM_LOG_FILE); then \
		echo "$(RED)Neovim encountered Lua errors ❌$(RESET)"; \
		cat $(NVIM_LOG_FILE); \
		exit 1; \
	fi
	@echo "$(GREEN)Neovim configuration sanity check passed ✅$(RESET)"
	@echo "Log saved to: $(NVIM_LOG_FILE)"
	@echo "------------------------------------------"

# Display linter warnings
report_warnings: lint
	@echo "$(YELLOW)========== LINTER WARNINGS ==========$(RESET)"; \
	grep -vE " OK$$|^Checking |Total:" $(LINT_WARNINGS_FILE) || true; \
	grep "Total: " $(LINT_WARNINGS_FILE) | tail -n 1; \
	echo "------------------------------------------";

# Cleanup after successful run (only if KEEP_BUILD is 0)
success_cleanup:
	@echo "$(BLUE)========== CLEANUP AFTER SUCCESS ==========$(RESET)"
	@if [ "$(KEEP_BUILD)" -eq "0" ]; then \
		echo "Cleaning up plugin data directory after success..."; \
		rm -rf "$(BUILD_DIR)"; \
		echo "$(GREEN)$(BUILD_DIR) cleaned ✅$(RESET)"; \
	else \
		echo "$(BLUE)KEEP_BUILD is set, preserving $(BUILD_DIR)$(RESET)"; \
	fi
	@echo "------------------------------------------"

.PHONY: all compile lint test report_warnings success_cleanup
