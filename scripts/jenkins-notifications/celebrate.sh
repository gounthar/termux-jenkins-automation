#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# FESTIVE CELEBRATION SCRIPT FOR TERMUX-TORCH
# ==========================================

# Cleanup handler to ensure torch is off on exit
cleanup() {
    # Ensure torch is off on exit
    termux-torch off 2>/dev/null
}
trap cleanup EXIT INT TERM

# Function: Show colorful console message
show_banner() {
    echo -e "\n\033[1;36m"
    echo "   ╔══════════════════════════╗"
    echo "   ║    🎉 CELEBRATION 🎉    ║"
    echo "   ╚══════════════════════════╝"
    echo -e "\033[0m"
}

# Function: Fireworks pattern
fireworks() {
    # Initial burst
    termux-torch on && sleep 0.1 && termux-torch off && sleep 0.05
    termux-torch on && sleep 0.08 && termux-torch off && sleep 0.05
    termux-torch on && sleep 0.05 && termux-torch off && sleep 0.3
    
    # Cluster of quick flashes
    for i in {1..12}; do
        duration=$(awk -v i="$i" 'BEGIN{print 0.02 + i*0.01}')
        termux-torch on && sleep $duration
        termux-torch off && sleep 0.03
        [ $((i % 3)) -eq 0 ] && sleep 0.1  # Pause every 3 flashes
    done
    
    # Final big burst
    termux-torch on && sleep 0.4 && termux-torch off && sleep 0.1
    termux-torch on && sleep 0.3 && termux-torch off && sleep 0.05
    termux-torch on && sleep 0.2 && termux-torch off
}

# Function: Disco light pattern
disco() {
    local flashes=$((10 + RANDOM % 15))  # Random number of flashes (10-25)
    
    for ((i=0; i<flashes; i++)); do
        # Random duration (0.04 to 0.2 seconds)
        duration=$(awk -v i="$i" 'BEGIN{print 0.04 + (rand()*0.16)}')
        
        termux-torch on && sleep $duration
        termux-torch off && sleep 0.05
        
        # Occasionally add longer pauses
        [ $((RANDOM % 4)) -eq 0 ] && sleep 0.2
    done
}

# Function: Victory sequence
victory() {
    # V-I-C-T-O-R-Y in morse-like pattern
    local pattern=(0.3 0.1 0.3 0.1 0.1 0.1 0.3 0.1 0.3 0.1 0.3 0.3 0.1 0.1)
    
    for duration in "${pattern[@]}"; do
        termux-torch on && sleep $duration
        termux-torch off && sleep 0.08
    done
    
    # Final flourish
    termux-torch on && sleep 0.5 && termux-torch off
}

# Main celebration sequence
show_banner
echo "Starting celebration sequence..."
echo "Press Ctrl+C to stop early"

# Run all patterns with pauses between
fireworks
sleep 0.5
disco
sleep 0.3
victory

echo -e "\n\033[1;32mCelebration complete! \033[0m 🎊"
