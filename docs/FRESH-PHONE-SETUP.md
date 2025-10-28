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
1. Phone IP address
2. Termux user ID (from `whoami` command)
3. SSH server running on phone

**Commands to run ON THE PHONE:**
```bash
# 1. Start SSH server
sshd

# 2. Get user ID
whoami
# Expected output: u0_a### (e.g., u0_a504)

# 3. Get IP address
ifconfig wlan0 | grep inet
# Or simpler:
ip addr show wlan0 | grep "inet "
```

**Results:**
- [ ] Phone IP: _____________
- [ ] User ID: _____________
- [ ] SSH server running: [ ]

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

# 2. Generate SSH key (if not exists)
ls ~/.ssh/termux_ed25519 || ssh-keygen -t ed25519 -f ~/.ssh/termux_ed25519 -N ""

# 3. Copy SSH key to phone
ssh-copy-id -p 8022 -i ~/.ssh/termux_ed25519 <PHONE_IP>
# You'll need to enter password (default: no password, just press Enter)

# 4. Test SSH connection
ssh -p 8022 -i ~/.ssh/termux_ed25519 <PHONE_IP> "whoami"
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
