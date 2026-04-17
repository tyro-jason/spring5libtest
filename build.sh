#!/bin/bash

# Build Script for Spring 5/6 Multi-Version Library Demo
set -e

echo "🏗️  Building Spring 5/6 Multi-Version Library Demo"
echo "=================================================="

# Build shared library for Spring 5
echo "📦 Building shared library for Spring 5..."
cd sharedLib
mvn clean install -Pspring5 -q
echo "✅ Spring 5 version built successfully"

# Build shared library for Spring 6
echo "📦 Building shared library for Spring 6..."
mvn clean install -Pspring6 -q
echo "✅ Spring 6 version built successfully"

cd ..

# Build Spring 5 application
echo "📦 Building Spring 5 application..."
cd spring5app
mvn clean compile -q
echo "✅ Spring 5 application built successfully"

cd ..

# Build Spring 6 application
echo "📦 Building Spring 6 application..."
cd spring6app
mvn clean compile -q
echo "✅ Spring 6 application built successfully"

cd ..

echo ""
echo "🎉 All builds completed successfully!"
echo ""
echo "To run the applications:"
echo "  Spring 5 app: cd spring5app && mvn spring-boot:run (port 8085)"
echo "  Spring 6 app: cd spring6app && mvn spring-boot:run (port 8086)"
echo ""
echo "Test endpoints:"
echo "  Spring 5: curl http://localhost:8085/api/hello"
echo "  Spring 6: curl http://localhost:8086/api/hello"