# Use an image with Flutter SDK (cirrusci provides good images)
FROM cirrusci/flutter:stable


# install Android SDK commandline tools if not present (cirrus image already contains Android)
# Set working directory
WORKDIR /app


# copy pubspec first (for caching pub get)
COPY pubspec.* ./
RUN flutter pub get


# copy rest
COPY . .


# ensure gradle wrapper executable
RUN chmod +x ./android/gradlew || true


# Accept Android licenses (non-interactive)
RUN yes | sdkmanager --licenses || true
