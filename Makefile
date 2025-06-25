# DemoApp Makefile

.PHONY: build run-cli run-mac clean release help

# Default target
help:
	@echo "Available targets:"
	@echo "  build      - Build all targets"
	@echo "  run-cli    - Build and run the command line application"
	@echo "  run-mac    - Build and run the macOS GUI application"
	@echo "  clean      - Clean build artifacts"
	@echo "  release    - Build release versions"
	@echo "  help       - Show this help message"

# Build all targets
build:
	@echo "Building all targets..."
	swift build

# Run the command line application
run-cli:
	@echo "Running command line application..."
	swift run DemoAppCLI

# Run the macOS GUI application
run-mac:
	@echo "Running macOS GUI application..."
	swift run DemoAppMac

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	swift package clean

# Build release versions
release:
	@echo "Building release versions..."
	swift build -c release

# Test if we can build (useful for CI)
test-build:
	@echo "Testing build..."
	swift build --dry-run
