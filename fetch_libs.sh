#!/bin/bash
set -e

# Define directories
TARGET_DIR="PunchThrough/Libs"
TEMP_DIR="temp_libs"

# Clean up any existing libs and temp dirs
rm -rf "$TARGET_DIR" "$TEMP_DIR"
mkdir -p "$TARGET_DIR"
mkdir -p "$TEMP_DIR"

echo "Cloning libraries..."

# Create directories
mkdir -p "$TARGET_DIR/LibStub"
mkdir -p "$TARGET_DIR/CallbackHandler-1.0"

# Fetch LibStub
echo "Fetching LibStub..."
curl -sS -o "$TARGET_DIR/LibStub/LibStub.lua" "https://raw.githubusercontent.com/lua-wow/LibStub/master/LibStub.lua"

# Fetch CallbackHandler
echo "Fetching CallbackHandler-1.0..."
curl -sS -o "$TARGET_DIR/CallbackHandler-1.0/CallbackHandler-1.0.lua" "https://raw.githubusercontent.com/Details-Damage-Meter/Details-Damage-Meter/master/Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua"
curl -sS -o "$TARGET_DIR/CallbackHandler-1.0/CallbackHandler-1.0.xml" "https://raw.githubusercontent.com/Details-Damage-Meter/Details-Damage-Meter/master/Libs/CallbackHandler-1.0/CallbackHandler-1.0.xml"

# Clone Ace3 repository
echo "Cloning Ace3..."
git clone --depth 1 https://github.com/WoWUIDev/Ace3.git "$TEMP_DIR/Ace3"


# Copy Ace3 libraries
echo "Copying Ace3 libraries..."
libraries=(
    "AceAddon-3.0"
    "AceEvent-3.0"
    "AceDB-3.0"
    "AceConsole-3.0"
    "AceGUI-3.0"
    "AceConfig-3.0"
)

for lib in "${libraries[@]}"; do
    echo "Copying $lib..."
    mkdir -p "$TARGET_DIR/$lib"
    cp -r "$TEMP_DIR/Ace3/$lib/"* "$TARGET_DIR/$lib/"
done

# Clean up temp files
rm -rf "$TEMP_DIR"
echo "Libraries successfully fetched and installed to $TARGET_DIR!"
