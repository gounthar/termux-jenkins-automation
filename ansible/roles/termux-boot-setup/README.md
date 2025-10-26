# Ansible Role: termux-boot-setup

Configure Jenkins to start automatically when your Android device boots using Termux:Boot.

## Description

This role automates the setup of Termux:Boot scripts to ensure Jenkins CI/CD and SSH services start automatically when your Android device reboots. This eliminates the need for manual intervention and creates a truly hands-free Jenkins environment.

## Requirements

**Required:**
- Ansible 2.10 or higher
- Termux installed on Android device
- SSH access to the device
- Jenkins and SSH already configured (via `jenkins-controller` and `jenkins-agent` roles)

**Highly Recommended:**
- **Termux:Boot** app installed on Android device
  - [F-Droid](https://f-droid.org/packages/com.termux.boot/)
  - [GitHub Releases](https://github.com/termux/termux-boot/releases)

**Note:** Without Termux:Boot, this role will display warnings and skip boot script creation. The role gracefully handles missing Termux:Boot and provides installation instructions.

## Role Variables

Available variables with their default values (see `defaults/main.yaml`):

```yaml
# Termux home directory
termux_home: /data/data/com.termux/files/home

# Boot script configuration
boot_script_name: start-jenkins.sh
boot_script_path: "{{ termux_home }}/.termux/boot/{{ boot_script_name }}"

# Network wait time (seconds) before starting services
network_wait_seconds: 30

# Services to enable on boot
boot_services:
  - sshd      # SSH daemon for remote access
  - jenkins   # Jenkins CI/CD server

# Enable wake lock to prevent device sleep
enable_wake_lock: true
```

### Customization Examples

**Change network wait time:**
```yaml
network_wait_seconds: 60  # Wait longer for slow networks
```

**Disable wake lock:**
```yaml
enable_wake_lock: false  # Allow device to sleep
```

**Add more services:**
```yaml
boot_services:
  - sshd
  - jenkins
  - postgresql  # Example: additional service
```

## Dependencies

This role works best when used after:
- `termux-base` - Sets up basic Termux environment
- `jenkins-controller` - Installs Jenkins
- `jenkins-agent` - Configures Jenkins agent

## Example Playbook

### Basic Usage

```yaml
---
- name: Configure Jenkins auto-start on boot
  hosts: termux_controller
  roles:
    - termux-boot-setup
```

### With Custom Variables

```yaml
---
- name: Configure boot with custom settings
  hosts: termux_controller
  roles:
    - role: termux-boot-setup
      vars:
        network_wait_seconds: 45
        enable_wake_lock: true
        boot_services:
          - sshd
          - jenkins
```

### Integrated with Complete Setup

```yaml
---
- name: Complete Jenkins setup with auto-start
  hosts: termux_controller
  roles:
    - termux-base
    - jenkins-controller
    - jenkins-agent
    - jenkins-jcasc
    - termux-boot-setup  # Configure auto-start last
```

## What This Role Does

### When Termux:Boot is Installed:

1. ✅ Checks for Termux:Boot installation
2. ✅ Creates `~/.termux/boot` directory if needed
3. ✅ Deploys boot script from template
4. ✅ Configures services to start on boot (SSH + Jenkins)
5. ✅ Sets up logging (`start-jenkins.log`)
6. ✅ Optionally acquires wake lock to prevent sleep
7. ✅ Waits for network before starting services
8. ✅ Tests script syntax
9. ✅ Provides testing instructions

### When Termux:Boot is NOT Installed:

1. ⚠️ Detects missing Termux:Boot
2. ⚠️ Displays clear warning message
3. ⚠️ Provides installation instructions
4. ⚠️ Shows manual start commands
5. ⚠️ Skips boot script creation gracefully

## Boot Script Details

The deployed boot script (`~/.termux/boot/start-jenkins.sh`):

```bash
#!/data/data/com.termux/files/usr/bin/bash
# {{ ansible_managed }}

# Logging to ~/.termux/boot/start-jenkins.log
LOG_FILE="{{ termux_home }}/.termux/boot/start-jenkins.log"
exec > "$LOG_FILE" 2>&1

echo "==================================="
echo "Jenkins Boot Script"
echo "Started: $(date)"
echo "==================================="

# 1. Acquire wake lock (if enabled)
{% if enable_wake_lock %}
echo "[$(date +%T)] Acquiring wake lock..."
termux-wake-lock
if [ $? -eq 0 ]; then
    echo "[$(date +%T)] ✓ Wake lock acquired"
else
    echo "[$(date +%T)] ⚠ Failed to acquire wake lock"
fi
{% endif %}

# 2. Wait for network (default: 30s)
echo "[$(date +%T)] Waiting {{ network_wait_seconds }} seconds for network..."
sleep {{ network_wait_seconds }}
echo "[$(date +%T)] Network wait complete"

# 3. Start services
echo "[$(date +%T)] Starting services..."
{% for service in boot_services %}
echo "[$(date +%T)] Starting {{ service }}..."
sv up "$PREFIX/var/service/{{ service }}"
if [ $? -eq 0 ]; then
    echo "[$(date +%T)] ✓ {{ service }} started"
else
    echo "[$(date +%T)] ✗ Failed to start {{ service }}"
fi
{% endfor %}

echo "==================================="
echo "Jenkins Boot Script Complete"
echo "Finished: $(date)"
echo "==================================="
```

### Log File

Boot logs are saved to: `~/.termux/boot/start-jenkins.log`

View logs:
```bash
cat ~/.termux/boot/start-jenkins.log
```

## Testing

### Test Boot Script Manually

```bash
# SSH into device
ssh -p 8022 termux@<phone-ip>

# Run boot script
~/.termux/boot/start-jenkins.sh

# Check log
cat ~/.termux/boot/start-jenkins.log
```

### Test Actual Boot Sequence

1. Reboot Android device
2. Wait 60-90 seconds (network wait + Jenkins startup)
3. Check Jenkins: `http://<phone-ip>:8080`
4. Check SSH: `ssh -p 8022 termux@<phone-ip>`

### Verify Services Running

```bash
sv status jenkins
sv status sshd
```

## Troubleshooting

### Jenkins Doesn't Start on Boot

**Check Termux:Boot installed:**
```bash
ls ~/.termux/boot
```

**Check boot script exists:**
```bash
ls -la ~/.termux/boot/start-jenkins.sh
```

**Check boot script is executable:**
```bash
chmod +x ~/.termux/boot/start-jenkins.sh
```

**Review boot logs:**
```bash
cat ~/.termux/boot/start-jenkins.log
```

**Test boot script manually:**
```bash
~/.termux/boot/start-jenkins.sh
```

### Termux:Boot Not Working

1. **Reinstall Termux:Boot** from F-Droid
2. **Grant boot permissions** in Android settings
3. **Reboot device once** to initialize Termux:Boot
4. **Re-run this playbook** to recreate boot scripts

### Services Not Starting

**Check termux-services installed:**
```bash
pkg list-installed | grep termux-services
```

**Check runit running:**
```bash
ps aux | grep runsvdir
```

**Manually enable services:**
```bash
sv-enable sshd
sv-enable jenkins
sv status jenkins
```

## Without Termux:Boot

If you choose not to install Termux:Boot, you must manually start Jenkins after each reboot:

```bash
# SSH into device
ssh -p 8022 termux@<phone-ip>

# Start services
sv-enable sshd
sv-enable jenkins

# Verify
sv status jenkins
```

## License

MIT

## Author

CloudNord Termux Jenkins Automation Project

## Related Documentation

- [Termux:Boot Wiki](https://wiki.termux.com/wiki/Termux:Boot)
- [Termux Services](https://wiki.termux.com/wiki/Termux-services)
- [Project README](../../../README.md)
