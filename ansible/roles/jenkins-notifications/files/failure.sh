#!/data/data/com.termux/files/usr/bin/bash

# ======================================
# FAILURE NOTIFICATION SCRIPT FOR TERMUX
# ======================================

# Visual banner with red warning
show_warning() {
    echo -e "\n\033[1;31m"
    echo "   ╔══════════════════════════╗"
    echo "   ║    🚨 BUILD FAILED 🚨   ║"
    echo "   ╚══════════════════════════╝"
    echo -e "\033[0m"
}

# Pulsing "alarm" pattern
alarm_pattern() {
    # 3 long pulses with descending intensity
    for i in 3 2 1; do
        termux-torch on
        sleep 0.8  # Long on duration
        termux-torch off
        sleep 0.3  # Short pause
        
        # Additional short blink for each pulse
        termux-torch on
        sleep 0.2
        termux-torch off
        sleep 0.1
    done
}

# SOS morse pattern
sos_pattern() {
    # S.O.S in morse code (··· --- ···)
    local s=(0.2 0.2 0.2)    # S = short x3
    local o=(0.6 0.6 0.6)    # O = long x3
    local pause=0.3
    
    # Flash S
    for dur in "${s[@]}"; do
        termux-torch on && sleep $dur
        termux-torch off && sleep 0.1
    done
    sleep $pause
    
    # Flash O
    for dur in "${o[@]}"; do
        termux-torch on && sleep $dur
        termux-torch off && sleep 0.1
    done
    sleep $pause
    
    # Flash S
    for dur in "${s[@]}"; do
        termux-torch on && sleep $dur
        termux-torch off && sleep 0.1
    done
}

# Main failure sequence
show_warning
echo "Build failed! Visual alert starting..."
echo "Press Ctrl+C to stop"

# Combine both patterns for clear failure signal
alarm_pattern
sleep 0.5
sos_pattern

# Ensure torch is off when done
termux-torch off

echo -e "\n\033[1;31mAlert sequence completed.\033[0m"
echo "Investigate the build immediately!"

