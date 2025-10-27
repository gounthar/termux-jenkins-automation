# Jenkins Notification Scripts for Termux

Creative notification scripts for Jenkins builds running on Android/Termux. These scripts provide visual and audio feedback using Android device features like the flashlight and text-to-speech.

## Scripts

### 🎉 celebrate.sh

Visual celebration for successful builds using the device flashlight.

**Features:**
- **Fireworks pattern**: Burst effects with varying intensities
- **Disco lights**: Random flashing patterns
- **Victory sequence**: Morse-like pattern spelling V-I-C-T-O-R-Y

**Usage:**
```bash
./celebrate.sh
```

**Requirements:**
- `termux-api` package
- Termux:API app installed
- Camera permission granted to Termux

**Integration with Jenkins:**
Add to your Jenkinsfile:
```groovy
post {
    success {
        sh '/data/data/com.termux/files/home/celebrate.sh'
    }
}
```

---

### 🚨 failure.sh

Visual alarm for build failures using pulsing flashlight patterns.

**Features:**
- **Alarm pattern**: Three descending-intensity pulses
- **SOS morse code**: Standard distress signal (··· --- ···)
- Red console warnings

**Usage:**
```bash
./failure.sh
```

**Requirements:**
- `termux-api` package
- Termux:API app installed
- Camera permission granted to Termux

**Integration with Jenkins:**
Add to your Jenkinsfile:
```groovy
post {
    failure {
        sh '/data/data/com.termux/files/home/failure.sh'
    }
}
```

---

### 🔊 jenkins-talking.sh

Text-to-speech notification in French that announces "C'est Jenkins qui vous parle!" (It's Jenkins speaking!)

**Features:**
- Variable pitch and rate progression
- FIFO-based TTS queue management
- Automatic `bc` package installation
- Clean signal handling

**Usage:**
```bash
./jenkins-talking.sh
```

**Requirements:**
- `termux-api` package
- Termux:API app installed
- `bc` package (auto-installed if missing)
- Text-to-speech engine on Android

**Customization:**
Edit the `text` variable to change the message:
```bash
text="Your custom message here!"
```

**Integration with Jenkins:**
Add to your Jenkinsfile:
```groovy
post {
    always {
        sh '/data/data/com.termux/files/home/jenkins-talking.sh'
    }
}
```

---

## Installation

### 1. Install Termux:API

Download and install the **Termux:API** app from F-Droid:
```
https://f-droid.org/packages/com.termux.api/
```

### 2. Install termux-api Package

In Termux, run:
```bash
pkg install termux-api
```

### 3. Grant Permissions

Grant the following permissions to Termux in Android Settings:
- **Camera** (for flashlight control)
- **Microphone** (optional, for TTS)

### 4. Copy Scripts to Termux

Copy the scripts to your Termux home directory:
```bash
scp -P 8022 celebrate.sh failure.sh jenkins-talking.sh termux@<phone-ip>:~/
```

Or use Ansible:
```bash
ansible termux_controller -m copy -a "src=celebrate.sh dest=/data/data/com.termux/files/home/ mode=0755"
```

### 5. Test the Scripts

Run each script manually to verify:
```bash
./celebrate.sh    # Should flash the flashlight
./failure.sh      # Should show SOS pattern
./jenkins-talking.sh  # Should speak in French
```

---

## Troubleshooting

### Flashlight not working

**Error**: `termux-torch: command not found`

**Solution**: Install termux-api package
```bash
pkg install termux-api
```

**Error**: Flashlight permission denied

**Solution**: Grant Camera permission to Termux in Android Settings

---

### Text-to-speech not working

**Error**: No audio output

**Solution**:
1. Check Android TTS engine is installed (Settings → Accessibility → Text-to-speech)
2. Test TTS manually: `termux-tts-speak "test"`
3. Ensure device volume is not muted

---

### Scripts don't stop

Press **Ctrl+C** to interrupt any running script. All scripts properly handle cleanup on exit.

---

## CloudNord Talk Demo

These scripts are designed for the CloudNord talk demonstration to showcase:
- Creative reuse of Android device features
- Fun, engaging CI/CD feedback
- Physical world integration with DevOps automation
- Environmental sustainability (repurposing old phones)

**Demo sequence:**
1. Trigger a build in Jenkins
2. Watch the flashlight patterns during execution
3. Hear the French TTS announcement on completion
4. Show SOS pattern for intentional failures

---

## Credits

Created for the CloudNord 2025 talk: "Repurposing Old Android Phones as Jenkins CI/CD Agents"

These scripts demonstrate the playful side of DevOps automation while promoting sustainable computing practices.
