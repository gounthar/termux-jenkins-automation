#!/data/data/com.termux/files/usr/bin/bash

# Check if bc is installed
if ! command -v bc &> /dev/null; then
    echo "Installing bc package..."
    pkg install bc -y && echo "bc installed successfully" || { echo "Installation failed"; exit 1; }
fi

# FIFO setup
FIFO_PATH="$HOME/.tts_queue_$(date +%s)"
RUNNING=true

cleanup() {
    RUNNING=false
    rm -f "$FIFO_PATH" 2>/dev/null
    kill "$TTS_PID" 2>/dev/null
    echo "Cleanup complete"
}
trap cleanup EXIT INT TERM

# Create FIFO
mkfifo "$FIFO_PATH" || { echo "Failed to create FIFO"; exit 1; }

# Start TTS engine in background
(
    while $RUNNING; do
        if read -r line < "$FIFO_PATH"; then
            eval "termux-tts-speak $line"
        fi
    done
) &
TTS_PID=$!
echo "TTS engine started (PID: $TTS_PID)"

# Parameters
text="C'est Jenkins qui vous parle !"
p_start=1.0
p_end=2.0
r_start=1.0
r_end=2.0
steps=$(echo "($p_end - $p_start)/0.1" | bc)

echo "Starting TTS loop..."
echo "Press Ctrl+C to stop"

for i in $(seq 0 $steps); do
    p=$(echo "$p_start + $i*0.1" | bc)
    p=$(echo "if($p>$p_end) $p_end else $p" | bc)
    r=$(echo "scale=2; $r_start + ($r_end-$r_start)*($p-$p_start)/($p_end-$p_start)" | bc)
    
    echo "Speaking: p=$p, r=$r"
    echo "-l fr -p $p -r $r \"$text\"" > "$FIFO_PATH"
done

echo "TTS loop completed"
