#!/bin/bash

# Download Swiss Ephemeris files for Astrolog project
# This script downloads ephemeris data files and source code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
EPHE_DIR="$PROJECT_ROOT/SwissEphemeris"

echo "🌟 Swiss Ephemeris Download Script"
echo "=================================="
echo ""

# Create directories
mkdir -p "$EPHE_DIR/Data"
mkdir -p "$EPHE_DIR/Source"
mkdir -p "$EPHE_DIR/Include"

# Swiss Ephemeris version
SWEPH_VERSION="2.10.03"
BASE_URL="https://www.astro.com/ftp/swisseph"

echo "📥 Downloading Swiss Ephemeris data files..."
echo ""

# Essential ephemeris files for 1800-2399
EPHEMERIS_FILES=(
    "seas_18.se1"  # Asteroids
    "semo_18.se1"  # Moon
    "sepl_18.se1"  # Planets
)

cd "$EPHE_DIR/Data"

for file in "${EPHEMERIS_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Downloading $file..."
        curl -O "$BASE_URL/ephe/$file" || {
            echo "⚠️  Failed to download $file"
        }
    else
        echo "✓ $file already exists"
    fi
done

echo ""
echo "📚 Note: Additional ephemeris files available at:"
echo "   $BASE_URL/ephe/"
echo ""
echo "   Optional files for extended date ranges:"
echo "   - se1_*.se1  (3000 BC - 3000 AD)"
echo "   - se2_*.se1  (600 AD - 2400 AD, high precision)"
echo ""

# Download source code (optional - can also use SPM)
echo "📦 Downloading Swiss Ephemeris source code..."
echo ""

cd "$PROJECT_ROOT"

if [ ! -f "sweph_${SWEPH_VERSION}.tar.gz" ]; then
    curl -O "$BASE_URL/sweph_${SWEPH_VERSION}.tar.gz"
    tar -xzf "sweph_${SWEPH_VERSION}.tar.gz"

    # Copy files to appropriate directories
    if [ -d "sweph/src" ]; then
        echo "Copying source files..."
        cp sweph/src/*.c "$EPHE_DIR/Source/" 2>/dev/null || true
        cp sweph/src/*.h "$EPHE_DIR/Include/" 2>/dev/null || true

        # Cleanup
        rm -rf sweph
        rm "sweph_${SWEPH_VERSION}.tar.gz"
    fi
else
    echo "✓ Source archive already downloaded"
fi

echo ""
echo "✅ Swiss Ephemeris download complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Verify files in: $EPHE_DIR"
echo "2. Add files to Xcode project"
echo "3. Configure Bridging Header"
echo "4. Update Build Settings"
echo ""
echo "See SWISS_EPHEMERIS_INTEGRATION.md for detailed instructions"
echo ""

# Display file sizes
echo "📊 Downloaded files summary:"
du -sh "$EPHE_DIR/Data"/* 2>/dev/null || echo "No data files found"
echo ""

# Check for source files
SOURCE_COUNT=$(ls -1 "$EPHE_DIR/Source"/*.c 2>/dev/null | wc -l)
HEADER_COUNT=$(ls -1 "$EPHE_DIR/Include"/*.h 2>/dev/null | wc -l)

echo "Source files: $SOURCE_COUNT .c files"
echo "Header files: $HEADER_COUNT .h files"
echo ""

# License reminder
echo "⚖️  License Information:"
echo ""
echo "Swiss Ephemeris is available under dual licensing:"
echo "  • GNU GPL v2 or later (for open-source projects)"
echo "  • Swiss Ephemeris Professional License (for commercial use)"
echo ""
echo "For commercial projects, purchase a license at:"
echo "https://www.astro.com/swisseph/swephinfo_e.htm"
echo ""
echo "Current project: Review license requirements before release!"
echo ""
