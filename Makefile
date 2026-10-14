.PHONY: gen fingerprint-debug fingerprint-release fingerprints signing-report gen-release-keystore

# Build runner code generator
gen:
	dart run build_runner build --delete-conflicting-outputs

# --- Android Certificate Fingerprints ---

# Use the JDK bundled with Android Studio (macOS).
# The system has no standalone Java runtime, so we must point to
# Android Studio's embedded JBR.
JAVA_HOME ?= /Applications/Android Studio.app/Contents/jbr/Contents/Home
KEYTOOL   ?= $(JAVA_HOME)/bin/keytool

# Resolve home directory
HOME_DIR ?= $(HOME)
DEBUG_KEYSTORE ?= $(HOME_DIR)/.android/debug.keystore

# Read release keystore credentials from android/key.properties
KEY_PROPS       = android/key.properties
RELEASE_STOREPASS ?= $(shell grep '^storePassword=' $(KEY_PROPS) | cut -d= -f2-)
RELEASE_KEYPASS   ?= $(shell grep '^keyPassword='   $(KEY_PROPS) | cut -d= -f2-)
RELEASE_ALIAS     ?= $(if $(ALIAS),$(ALIAS),$(shell grep '^keyAlias=' $(KEY_PROPS) | cut -d= -f2-))
RELEASE_KEYSTORE  ?= $(if $(KEYSTORE),$(KEYSTORE),android/app/upload-keystore.jks)

# Gradle wrapper executable (macOS always uses ./gradlew)
GRADLEW = ./gradlew

# View SHA-1 & SHA-256 fingerprints for Android Debug keystore
fingerprint-debug:
	@echo "Fetching Android Debug certificate fingerprints..."
	@echo "Using keytool at: $(KEYTOOL)"
	"$(KEYTOOL)" -list -v -keystore "$(DEBUG_KEYSTORE)" -alias androiddebugkey -storepass android -keypass android

# View SHA-1 & SHA-256 fingerprints for Android Release keystore
# Usage: make fingerprint-release
# Or:    make fingerprint-release KEYSTORE=path/to/my-key.jks ALIAS=my-key-alias
fingerprint-release:
	@echo "Fetching Android Release certificate fingerprints for $(RELEASE_KEYSTORE) (alias: $(RELEASE_ALIAS))..."
	"$(KEYTOOL)" -list -v -keystore "$(RELEASE_KEYSTORE)" -alias "$(RELEASE_ALIAS)" -storepass "$(RELEASE_STOREPASS)" -keypass "$(RELEASE_KEYPASS)"

# Helper to run both debug and release fingerprint checks
fingerprints: fingerprint-debug

# Run Gradle signingReport to inspect all configured build variant keys (debug & release)
signing-report:
	cd android && $(GRADLEW) signingReport

# Optional helper to generate a new release keystore if you don't have one yet
# Usage: make gen-release-keystore
gen-release-keystore:
	"$(KEYTOOL)" -genkey -v -keystore "$(RELEASE_KEYSTORE)" -alias "$(RELEASE_ALIAS)" -storepass "$(RELEASE_STOREPASS)" -keypass "$(RELEASE_KEYPASS)" -keyalg RSA -keysize 2048 -validity 10000