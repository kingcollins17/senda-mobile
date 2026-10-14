.PHONY: gen fingerprint-debug fingerprint-release fingerprints signing-report gen-release-keystore

# Build runner code generator
gen:
	dart run build_runner build --delete-conflicting-outputs

# --- Android Certificate Fingerprints ---

# Resolve home directory across Windows and macOS/Linux
HOME_DIR ?= $(if $(USERPROFILE),$(USERPROFILE),$(HOME))
DEBUG_KEYSTORE ?= $(HOME_DIR)/.android/debug.keystore

# Default release keystore configuration (can be overridden on command line: make fingerprint-release KEYSTORE=... ALIAS=...)
RELEASE_KEYSTORE ?= $(if $(KEYSTORE),$(KEYSTORE),android/app/upload-keystore.jks)
RELEASE_ALIAS ?= $(if $(ALIAS),$(ALIAS),upload)

# Gradle wrapper executable based on OS
GRADLEW = $(if $(filter Windows%,$(OS)),gradlew.bat,./gradlew)

# View SHA-1 & SHA-256 fingerprints for Android Debug keystore
fingerprint-debug:
	@echo Fetching Android Debug certificate fingerprints...
	keytool -list -v -keystore "$(DEBUG_KEYSTORE)" -alias androiddebugkey -storepass android -keypass android

# View SHA-1 & SHA-256 fingerprints for Android Release keystore
# Usage: make fingerprint-release
# Or:    make fingerprint-release KEYSTORE=path/to/my-key.jks ALIAS=my-key-alias
fingerprint-release:
	@echo Fetching Android Release certificate fingerprints for $(RELEASE_KEYSTORE) (alias: $(RELEASE_ALIAS))...
	keytool -list -v -keystore "$(RELEASE_KEYSTORE)" -alias "$(RELEASE_ALIAS)"

# Helper to run both debug and release fingerprint checks
fingerprints: fingerprint-debug

# Run Gradle signingReport to inspect all configured build variant keys (debug & release)
signing-report:
	cd android && $(GRADLEW) signingReport

# Optional helper to generate a new release keystore if you don't have one yet
# Usage: make gen-release-keystore
gen-release-keystore:
	keytool -genkey -v -keystore "$(RELEASE_KEYSTORE)" -alias "$(RELEASE_ALIAS)" -keyalg RSA -keysize 2048 -validity 10000