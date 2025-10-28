# Fresh Phone Setup - Live Walkthrough

This document tracks a real fresh phone installation for the CloudNord talk demonstration.

## Date
October 28, 2025

## Phone Specifications
- Device: [To be filled]
- Android Version: [To be filled]
- Termux Version: [To be filled]

## Prerequisites Installed

✅ **Termux** - Base terminal environment
- Installation: F-Droid or GitHub releases
- Status: INSTALLED

✅ **Termux:Boot** - Auto-start on device boot
- Installation: F-Droid
- Status: INSTALLED
- Purpose: Automatically start Jenkins and SSH on phone reboot

✅ **Termux:API** - Android system integration
- Installation: F-Droid + `pkg install termux-api`
- Status: INSTALLED
- Purpose: TTS notifications and flashlight alerts for Jenkins jobs

## Setup Progress

### Step 1: Initial Termux Configuration ⏳

**What we need:**
1. Select optimal package mirror
2. Update package repositories
3. Install OpenSSH
4. Get phone IP and user ID
5. Start SSH server

**Commands to run ON THE PHONE:**
```bash
# 1. Select best mirror for your location (IMPORTANT!)
termux-change-repo
# This will show a menu:
#   - Use arrow keys to navigate
#   - Select "Mirrors in <Your Region>" (e.g., Europe, Asia, Americas)
#   - Press Space to select, Enter to confirm
#   - This ensures fast downloads and avoids timeouts

# 2. Update package repositories (this may take a few minutes)
pkg update

# 3. Upgrade existing packages (recommended for fresh install)
pkg upgrade
# Press Y or Enter when prompted to confirm

# 4. Install OpenSSH server
pkg install openssh

# 5. Set a password for SSH login (IMPORTANT!)
passwd
# Enter and confirm a strong password
# This password will be needed for SSH key setup

# 6. Start SSH server
sshd

# 7. Get user ID
whoami
# Expected output: u0_a### (e.g., u0_a556)

# 8. Get IP address
# Just run ifconfig without filtering - easier to read
ifconfig
# Look for the "inet" line under wlan0
# Example output:
#   wlan0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
#           inet 192.168.1.53  netmask 255.255.255.0  broadcast 192.168.1.255
#
# NOTE: You'll see "Warning: cannot open /proc/net/dev" - this is NORMAL in Termux
# Just ignore the warning and look for the inet line with your IP address

# 9. Customize prompt with phone emoji (for demo visual appeal)
echo 'export PS1="📱 \w $ "' >> ~/.bashrc
source ~/.bashrc
# Your prompt will now show: 📱 ~ $

# 10. Start SSH server
sshd
```

**Results:**
- [x] Mirror selected (region): _____________
- [x] pkg update completed
- [x] pkg upgrade completed
- [x] openssh installed
- [x] Password set
- [x] User ID: **u0_a556**
- [x] Phone IP: **192.168.1.53**
- [ ] Prompt customized with 📱 emoji: [ ]
- [ ] SSH server started: [ ]

**Troubleshooting Tips:**
- If `pkg update` is slow or times out, run `termux-change-repo` again and try a different mirror
- Some regions have faster mirrors than others
- The automation playbook will also configure repositories, but starting with a good mirror helps

---

### Step 2: Control Machine Setup ⏳

**What we need:**
1. SSH key for authentication
2. Ansible installed
3. Inventory file updated

**Commands to run ON CONTROL MACHINE:**
```bash
# 1. Check Ansible installation
ansible --version

# 2. Check if SSH key exists (skip generation if it does)
ls -la ~/.ssh/termux_ed25519
# If it exists, you'll see: -rw------- 1 user user 411 ... termux_ed25519
# If not found, generate it:
ssh-keygen -t ed25519 -f ~/.ssh/termux_ed25519 -N ""

# 3. Copy SSH key to phone
# NOTE: Use -o IdentitiesOnly=yes to avoid "Too many authentication failures"
ssh-copy-id -o IdentitiesOnly=yes -p 8022 -i ~/.ssh/termux_ed25519 192.168.1.53
# Enter the password you set earlier with 'passwd'

# 4. Test SSH connection (should NOT ask for password now)
ssh -p 8022 -i ~/.ssh/termux_ed25519 -o IdentitiesOnly=yes 192.168.1.53 "whoami"
# Expected output: u0_a556
```

**Results:**
- [ ] Ansible version: _____________
- [ ] SSH key generated: [ ]
- [ ] SSH key copied to phone: [ ]
- [ ] SSH connection successful: [ ]

---

### Step 3: Update Inventory Configuration ⏳

**File to edit:** `ansible/inventory/hosts.yaml`

**What to update:**
```yaml
phone1:
  ansible_host: <PHONE_IP>        # Update this
  ansible_port: 8022
  ansible_user: <USER_ID>         # Update this (from whoami)
  ansible_connection: ssh
  ansible_ssh_private_key_file: ~/.ssh/termux_ed25519
  ansible_ssh_common_args: '-o IdentitiesOnly=yes'
  ansible_python_interpreter: /data/data/com.termux/files/usr/bin/python
  ansible_remote_tmp: /data/data/com.termux/files/home/.ansible/tmp
```

**Results:**
- [ ] Inventory file updated: [ ]
- [ ] Committed changes: [ ]

---

### Step 4: Test Ansible Connection ⏳

**Command:**
```bash
cd /mnt/c/support/users/talks/2025/termux/termux-jenkins-automation
ansible -i ansible/inventory/hosts.yaml termux_controller -m ping
```

**Expected output:**
```
phone1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

**Results:**
- [ ] Ansible ping successful: [ ]

---

### Step 5: Run Complete Setup ⏳

**Command:**
```bash
ansible-playbook -i ansible/inventory/hosts.yaml \
  ansible/playbooks/99-complete-setup.yaml
```

**Expected phases:**
1. Display welcome message
2. Phase 1: Set up Termux base (SSH, Python, Git, OpenJDK)
3. Phase 2: Install Jenkins controller (download WAR, start Jenkins)
4. Phase 3: Configure agent and build tools
5. Phase 4: Apply Jenkins Configuration as Code
6. Phase 5: Configure boot auto-start
7. Phase 6: Restore jobs from backup (optional)
8. Final summary with access URL

**Estimated time:** 10-15 minutes

**Results:**
- [ ] Phase 1 completed: [ ]
- [ ] Phase 2 completed: [ ]
- [ ] Phase 3 completed: [ ]
- [ ] Phase 4 completed: [ ]
- [ ] Phase 5 completed: [ ]
- [ ] Phase 6 completed: [ ]
- [ ] Setup completed successfully: [ ]

**Jenkins Access Information:**
- Jenkins URL: http://<PHONE_IP>:8080
- Username: admin
- Password: admin (default)

---

### Step 6: Verification ⏳

**Tasks to verify:**

1. **Access Jenkins Web UI**
   ```bash
   # On control machine
   curl -I http://<PHONE_IP>:8080
   # Should return HTTP 200 OK
   ```
   - [ ] Jenkins web UI accessible: [ ]

2. **Login to Jenkins**
   - Open browser: http://<PHONE_IP>:8080
   - Login: admin / admin
   - [ ] Login successful: [ ]

3. **Check Agent Connection**
   - Navigate to: Manage Jenkins → Nodes
   - Check: termux-agent-1 should be online
   - [ ] Agent connected: [ ]

4. **Run Test Job**
   - Open job: hello-world
   - Click "Build Now"
   - Check console output
   - [ ] Job executed successfully: [ ]

5. **Test Notification Scripts** (if Termux:API working)
   ```bash
   # SSH into phone
   ssh -p 8022 -i ~/.ssh/termux_ed25519 <PHONE_IP>

   # Test celebrate script
   ~/celebrate.sh

   # Test failure alarm
   ~/failure.sh

   # Test TTS
   ~/jenkins-talking.sh
   ```
   - [ ] Flashlight works: [ ]
   - [ ] TTS works: [ ]

---

## Issues Encountered

### Issue 1: [Title]
**Description:**


**Solution:**


---

### Issue 2: [Title]
**Description:**


**Solution:**


---

## Timing Breakdown

- Step 1 (Termux config): ___ minutes
- Step 2 (Control machine): ___ minutes
- Step 3 (Inventory update): ___ minutes
- Step 4 (Ansible test): ___ minutes
- Step 5 (Complete setup): ___ minutes
- Step 6 (Verification): ___ minutes

**Total time:** ___ minutes

---

## Configuration Details

### Versions Installed
- Jenkins: 2.528.1 (LTS)
- OpenJDK: 21
- Python: [To be filled]
- Node.js: [To be filled]
- Termux packages: [To be filled]

### Plugin Count
- Total plugins installed: 88 (from jenkins-docs reference)

### Notable Plugins
- configuration-as-code: 2006.v001a_2ca_6b_574
- git: 5.8.0
- workflow-aggregator: 608.v67378e9d3db_1

---

## Lessons Learned

1.
2.
3.

---

## Next Steps After Setup

- [ ] Change default admin password
- [ ] Configure additional agents (if multiple phones)
- [ ] Create custom build jobs
- [ ] Set up job notifications
- [ ] Test auto-boot functionality (reboot phone)
- [ ] Backup Jenkins configuration

---

## References

- Repository: https://github.com/gounthar/termux-jenkins-automation
- CloudNord Talk: [Date/Location]
- UpdateCLI Configuration: `updatecli/updatecli.d/`
- Ansible Playbooks: `ansible/playbooks/`

---

## Notes

_Use this section for any additional observations, tips, or reminders_
