# Stage 1: Build
FROM debian:latest AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Check flutter version and pre-download binaries
RUN flutter doctor -v
RUN flutter config --enable-web

# Copy project files
WORKDIR /app
COPY . .

# Get dependencies and build web
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy build files from Stage 1
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port (default for Nginx is 80)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
