.PHONY: help building cleaning build clean test test-dev td test-integration ti test-prop tp benchmark lint fmt ensure-placeholder compile-tz gen-tz update-tz clean-tz

# --- Colors ---

GREEN := \033[0;32m
CYAN := \033[0;36m
YELLOW := \033[1;33m
RED := \033[0;31m
RESET := \033[0m


# --- Help ---

## Display this help menu with descriptions of each command
help:
	@echo "$(YELLOW)ChronoKit Makefile Commands:$(RESET)"
	@echo ""
	@awk '/^[a-zA-Z\-_0-9\s]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  $(GREEN)%-20s$(RESET) %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ""

# --- Build ---

building:
	@echo "$(CYAN)>>> Building Swift Package in Debug Configuration...$(RESET)"
	@swift build

cleaning:
	@echo "$(YELLOW)>>> Cleaning Swift Package Derived Data...$(RESET)"
	@swift package clean
	@echo "$(GREEN)>>> Success Cleaning Swift Package Derived Data...$(RESET)"

## Build the Swift package using Debug configuration
build:
	@clear
	@$(MAKE) building

## Clean the Swift package build artifacts (Derived Data)
clean:
	@clear
	@$(MAKE) cleaning

# ---- Testings ----

## Run all Unit Tests in Release configuration
test:
	@clear
	@echo "$(CYAN)>>> Running Unit Tests in Release Configuration...$(RESET)"
	@swift test --configuration release

## Run local Unit Tests for development (ChronoCore, ChronoTZ, etc.)
test-dev td:
	@clear
	@echo "$(CYAN)>>> Running Unit Tests in Development Configuration...$(RESET)"
	@swift test \
		--filter ChronoCoreTests \
		--filter ChronoMathTests \
		--filter ChronoFormatterTests \
		--filter ChronoParserTests \
		--filter ChronoSystemTests \
		--filter ChronoTZTests \
		--filter ChronoTZGenTests

## Run cross-module Integration Tests (ChronoIntegrationTests)
test-integration ti:
	@clear
	@echo "$(CYAN)>>> Running Integration Tests...$(RESET)"
	@swift test --filter ChronoIntegrationTests

## Run mathematical property-based tests (ChronoPropertyTests)
test-prop tp:
	@clear
	@echo "$(CYAN)>>> Running Property Tests...$(RESET)"
	@swift test --filter ChronoPropertyTests

## Run performance benchmarks using Release configuration
benchmark:
	@clear
	@echo "$(CYAN)>>> Running Performance Benchmark (ChronoBenchmark) in Release Configuration...$(RESET)"
	@swift run --configuration release ChronoBenchmark

# ---- Format ----

## Run SwiftLint static analysis for code style compliance
lint:
	@clear
	@$(MAKE) cleaning
	@$(MAKE) building
	@echo "$(YELLOW)>>> Running SwiftLint for Code Style Check...$(RESET)"
	@swiftlint

## Automatically format Swift source code using SwiftFormat 
fmt:
	@clear
	@$(MAKE) cleaning
	@$(MAKE) building
	@echo "$(YELLOW)>>> Running SwiftFormat for Code Style Check...$(RESET)"
	@swiftformat --swift-version 6.2 .

# ---- TZ ----

TZDB_DIR = ./Tools/tzdb
ZIC = $(TZDB_DIR)/zic
COMPILED_TZDB = .build/compiled_tzdb

TZ_SOURCE_FILES = \
    $(TZDB_DIR)/africa \
    $(TZDB_DIR)/antarctica \
    $(TZDB_DIR)/asia \
    $(TZDB_DIR)/australasia \
    $(TZDB_DIR)/backward \
    $(TZDB_DIR)/backzone \
    $(TZDB_DIR)/etcetera \
    $(TZDB_DIR)/europe \
    $(TZDB_DIR)/factory \
    $(TZDB_DIR)/northamerica \
    $(TZDB_DIR)/southamerica

OUT_DIR = ./Sources/ChronoTZ
OUT_BIN_TZDB = $(OUT_DIR)/Resources/iana.tzdb
OUT_C_TZDB = $(OUT_DIR)/iana
OUT_SWIFT_TZDB = $(OUT_DIR)/IANA.swift

FORMAT ?= bin

ifeq ($(FORMAT),bin)
	OUT_PATH = $(OUT_BIN_TZDB)
else ifeq ($(FORMAT),c)
	OUT_PATH = $(OUT_C_TZDB)
else ifeq ($(FORMAT),swift)
	OUT_PATH = $(OUT_SWIFT_TZDB)
else
	$(error Invalid FORMAT "$(FORMAT)". Must be 'bin' or 'swift')
endif

## Generate placeholder empty files for iana.tzdb if missing
ensure-placeholder:
	@mkdir -p $(dir $(OUT_BIN_TZDB))
	@if [ ! -f $(OUT_BIN_TZDB) ]; then \
		echo "Creating placeholder for $(OUT_BIN_TZDB)..."; \
		touch $(OUT_BIN_TZDB); \
	fi

## Compile raw textual IANA source files using the 'zic' compiler
compile-tz: 
	@mkdir -p $(COMPILED_TZDB)
	@echo "Compiling IANA source with zic via docker..."
	@docker run --rm \
		-v "$(shell pwd):/workspace" \
		--workdir "/workspace" \
		alpine:latest \
		sh -c "apk add --no-cache tzdata-utils && zic -d $(COMPILED_TZDB) $(TZ_SOURCE_FILES)"

## Extract zic compiled directory into the target format (default: FORMAT=bin)
gen-tz: 
	@$(MAKE) ensure-placeholder
	@$(MAKE) compile-tz
	@echo "Generating $(FORMAT) output at $(OUT_PATH) & $(OUT_BIN_TEST_TZDB)..."
	@swift run ChronoTZGen \
		--input $(COMPILED_TZDB) \
		--output $(OUT_PATH) \
		--format $(FORMAT)

## Pull latest database updates from IANA git submodule and recompile binary asset
update-tz:
	@echo "$(CYAN)>>> Fetching latest IANA data...$(RESET)"
	@git submodule update --remote $(TZDB_DIR)
	@$(MAKE) clean-tz
	@$(MAKE) gen-tz FORMAT=bin
	@echo "$(CYAN)>>> TZDB updated and recompiled.$(RESET)"

## Remove all generated timezone build artifacts and clean zic sub-environment
clean-tz:
	@echo "Cleaning output artifacts..."
	@rm -f $(OUT_BIN_TZDB) $(OUT_C_TZDB).c $(OUT_C_TZDB).h $(OUT_SWIFT_TZDB)
	@rm -rf $(COMPILED_TZDB)
	@$(MAKE) -C $(TZDB_DIR) clean
