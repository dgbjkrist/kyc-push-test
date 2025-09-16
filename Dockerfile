FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y \
    curl unzip git xz-utils zip libglu1-mesa openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_VERSION=3.24.0
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter \
    && cd /usr/local/flutter \
    && git checkout $FLUTTER_VERSION \
    && ./bin/flutter precache

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:$PATH"

RUN flutter doctor

WORKDIR /app
COPY . /app

CMD ["flutter", "run"]