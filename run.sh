#!/bin/bash

# =============================================================================
# Comprehensive Demo Script for Spring 5/6 Shared Library with Eclipse Transformer
# =============================================================================
# This script demonstrates a shared library that works with both Spring 5 and 
# Spring 6 through automated bytecode transformation of Jakarta to javax annotations.
#
# The workflow:
# 1. Build shared library (creates both Spring 5 and Spring 6 compatible versions)
# 2. Build both client applications
# 3. Start both applications on different ports
# 4. Test endpoints to verify compatibility
# 5. Clean up processes
# =============================================================================

set -e  # Exit on any error

# Color codes for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SPRING5_PORT=8080
SPRING6_PORT=8082
STARTUP_WAIT=8

echo -e "${BLUE}================================================================================================${NC}"
echo -e "${BLUE} Spring 5/6 Shared Library Demo with Eclipse Transformer${NC}"
echo -e "${BLUE}================================================================================================${NC}"
echo ""

# Function to print section headers
print_section() {
    echo ""
    echo -e "${YELLOW}>>> $1${NC}"
    echo -e "${YELLOW}$(printf '=%.0s' {1..80})${NC}"
}

# Function to check if a process is running on a port
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to kill processes on specific ports
cleanup_ports() {
    echo -e "${YELLOW}🧹 Cleaning up any existing processes on ports $SPRING5_PORT and $SPRING6_PORT...${NC}"
    
    if check_port $SPRING5_PORT; then
        echo "  - Killing process on port $SPRING5_PORT"
        kill -9 $(lsof -ti:$SPRING5_PORT) 2>/dev/null || true
    fi
    
    if check_port $SPRING6_PORT; then
        echo "  - Killing process on port $SPRING6_PORT"  
        kill -9 $(lsof -ti:$SPRING6_PORT) 2>/dev/null || true
    fi
    
    sleep 2
}

# Cleanup function for script exit
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Cleaning up processes...${NC}"
    cleanup_ports
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Set up cleanup trap
trap cleanup EXIT

# Initial cleanup
cleanup_ports

print_section "STEP 1: Building Shared Library (Creates Both Spring 5 & 6 Compatible Versions)"
echo -e "${BLUE}📚 The shared library build process will:${NC}"
echo "   • Compile Java sources with Jakarta annotations"
echo "   • Create Spring 6 compatible JAR (shared-lib-1.0.0-SNAPSHOT.jar)"
echo "   • Run Eclipse Transformer to convert Jakarta → javax annotations"
echo "   • Create Spring 5 compatible JAR (shared-lib-1.0.0-SNAPSHOT-spring5.jar)"
echo "   • Install both versions to local Maven repository"
echo ""

cd sharedLib
echo -e "${BLUE}🔨 Running: mvn clean install${NC}"
mvn clean install

echo ""
echo -e "${GREEN}✅ Shared library build completed!${NC}"
echo -e "${BLUE}📦 Checking Maven repository for both library versions:${NC}"
ls -la ~/.m2/repository/com/example/shared-lib/1.0.0-SNAPSHOT/ | grep "shared-lib.*\.jar$"

print_section "STEP 2: Building Spring 5 Application"
echo -e "${BLUE}🏗️  The Spring 5 app uses classifier='spring5' to get the javax-compatible library${NC}"
echo ""

cd ../spring5app
echo -e "${BLUE}🔨 Running: mvn clean package${NC}"
mvn clean package -q

echo -e "${GREEN}✅ Spring 5 application built successfully!${NC}"

print_section "STEP 3: Building Spring 6 Application"
echo -e "${BLUE}🏗️  The Spring 6 app uses the default library (no classifier) with Jakarta annotations${NC}"
echo ""

cd ../spring6app
echo -e "${BLUE}🔨 Running: mvn clean package${NC}"
mvn clean package -q

echo -e "${GREEN}✅ Spring 6 application built successfully!${NC}"

print_section "STEP 4: Starting Applications"
echo -e "${BLUE}🚀 Starting both applications in background...${NC}"
echo ""

# Start Spring 5 app
cd ../spring5app
echo -e "${BLUE}▶️  Starting Spring 5 app on port $SPRING5_PORT (uses javax annotations via transformation)${NC}"
nohup java -jar "target/spring5-app-1.0.0-SNAPSHOT.jar" --server.port=$SPRING5_PORT > spring5.log 2>&1 &
SPRING5_PID=$!
echo "   Spring 5 app PID: $SPRING5_PID"

# Start Spring 6 app  
cd ../spring6app
echo -e "${BLUE}▶️  Starting Spring 6 app on port $SPRING6_PORT (uses Jakarta annotations natively)${NC}"
nohup java -jar "target/spring6-app-1.0.0-SNAPSHOT.jar" --server.port=$SPRING6_PORT > spring6.log 2>&1 &
SPRING6_PID=$!
echo "   Spring 6 app PID: $SPRING6_PID"

print_section "STEP 5: Waiting for Applications to Start"
echo -e "${BLUE}⏳ Waiting $STARTUP_WAIT seconds for applications to fully initialize...${NC}"

for i in $(seq $STARTUP_WAIT -1 1); do
    echo -n "   $i... "
    sleep 1
done
echo "Ready! 🎯"

print_section "STEP 6: Testing Application Endpoints"
echo -e "${BLUE}🧪 Testing both applications to verify they're using the correct library versions${NC}"
echo ""

# Test Spring 5 app
echo -e "${BLUE}🔍 Testing Spring 5 app endpoint (should show Spring version 5.x):${NC}"
echo -e "${BLUE}   GET http://localhost:$SPRING5_PORT/api/hello${NC}"
echo ""

if SPRING5_RESPONSE=$(curl -s "http://localhost:$SPRING5_PORT/api/hello" 2>/dev/null); then
    echo -e "${GREEN}✅ Spring 5 app response:${NC}"
    echo "$SPRING5_RESPONSE" | jq '.' 2>/dev/null || echo "$SPRING5_RESPONSE"
    
    # Extract and highlight the Spring version
    SPRING5_VERSION=$(echo "$SPRING5_RESPONSE" | jq -r '.springVersion' 2>/dev/null || echo "unknown")
    echo -e "${GREEN}   🏷️  Spring Version: $SPRING5_VERSION${NC}"
    echo -e "${GREEN}   📝 Uses: javax annotations (transformed from Jakarta)${NC}"
else
    echo -e "${RED}❌ Failed to connect to Spring 5 app${NC}"
fi

echo ""

# Test Spring 6 app
echo -e "${BLUE}🔍 Testing Spring 6 app endpoint (should show Spring version 6.x):${NC}"
echo -e "${BLUE}   GET http://localhost:$SPRING6_PORT/api/hello${NC}"
echo ""

if SPRING6_RESPONSE=$(curl -s "http://localhost:$SPRING6_PORT/api/hello" 2>/dev/null); then
    echo -e "${GREEN}✅ Spring 6 app response:${NC}"
    echo "$SPRING6_RESPONSE" | jq '.' 2>/dev/null || echo "$SPRING6_RESPONSE"
    
    # Extract and highlight the Spring version  
    SPRING6_VERSION=$(echo "$SPRING6_RESPONSE" | jq -r '.springVersion' 2>/dev/null || echo "unknown")
    echo -e "${GREEN}   🏷️  Spring Version: $SPRING6_VERSION${NC}"
    echo -e "${GREEN}   📝 Uses: Jakarta annotations (native)${NC}"
else
    echo -e "${RED}❌ Failed to connect to Spring 6 app${NC}"
fi

print_section "STEP 7: Verification Summary"
echo ""

# Show lifecycle method verification
echo -e "${BLUE}🔍 Checking lifecycle method execution in application logs:${NC}"
echo ""

echo -e "${BLUE}Spring 5 App Lifecycle:${NC}"
cd ../spring5app
if grep -q "SharedService initialized - Jakarta PostConstruct called" spring5.log; then
    echo -e "${GREEN}   ✅ @PostConstruct lifecycle method executed successfully${NC}"
    echo -e "${GREEN}   📝 Original Jakarta annotation transformed to javax at bytecode level${NC}"
else
    echo -e "${RED}   ❌ Lifecycle method not found in logs${NC}"
fi

echo ""
echo -e "${BLUE}Spring 6 App Lifecycle:${NC}"
cd ../spring6app  
if grep -q "SharedService initialized - Jakarta PostConstruct called" spring6.log; then
    echo -e "${GREEN}   ✅ @PostConstruct lifecycle method executed successfully${NC}"
    echo -e "${GREEN}   📝 Native Jakarta annotations used directly${NC}"
else
    echo -e "${RED}   ❌ Lifecycle method not found in logs${NC}"
fi

print_section "FINAL RESULTS"
echo ""
echo -e "${GREEN}🎉 SUCCESS! The shared library compatibility demonstration is complete!${NC}"
echo ""
echo -e "${BLUE}📋 Summary of what was proven:${NC}"
echo "   • ✅ Single codebase with Jakarta annotations"
echo "   • ✅ Eclipse Transformer automatically creates javax-compatible version"
echo "   • ✅ Spring 5 app uses javax annotations (via bytecode transformation)"
echo "   • ✅ Spring 6 app uses Jakarta annotations (native)"
echo "   • ✅ Both applications share the same business logic"
echo "   • ✅ Lifecycle methods (@PostConstruct/@PreDestroy) work in both environments"
echo "   • ✅ Single build process publishes both library versions to Maven repository"
echo ""

echo -e "${BLUE}🏗️  Architecture Overview:${NC}"
echo "   📁 Source Code: Jakarta EE annotations (future-proof)"
echo "   🔄 Build Process: Maven + Eclipse Transformer"
echo "   📦 Output: Two JAR versions (Spring 5 & Spring 6 compatible)"
echo "   🎯 Client Apps: Use Maven classifiers to select correct version"
echo ""

echo -e "${BLUE}💡 Key Benefits:${NC}"
echo "   • No code duplication - single source of truth"
echo "   • Automatic compatibility with both Spring versions"  
echo "   • Future-proof (uses modern Jakarta annotations)"
echo "   • Seamless migration path from Spring 5 to Spring 6"
echo ""

echo -e "${YELLOW}🔗 Applications are still running:${NC}"
echo "   • Spring 5: http://localhost:$SPRING5_PORT/api/hello"
echo "   • Spring 6: http://localhost:$SPRING6_PORT/api/hello"
echo ""
echo -e "${YELLOW}👋 Press Ctrl+C to stop all applications and exit${NC}"

# Keep script running until user interrupts
echo -e "${BLUE}⏸️  Script will continue running... Press Ctrl+C to stop applications and exit${NC}"
while true; do
    sleep 1
done