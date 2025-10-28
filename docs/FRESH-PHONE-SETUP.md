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

# 9. Install Python (REQUIRED for Ansible)
pkg install python
# This is CRITICAL for Ansible automation
# Without Python, Ansible cannot gather facts or execute any modules
# This must be installed BEFORE running the automation playbook

# 10. Customize prompt with old phone emoji (for demo visual appeal)
echo 'export PS1="☎️  \w $ "' >> ~/.bashrc
source ~/.bashrc
# Your prompt will now show: ☎️  ~ $

# 11. Start SSH server
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
- [x] Python installed (required for Ansible)
- [x] Prompt customized with ☎️ emoji
- [x] SSH server started

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

**IMPORTANT NOTE**: This test will likely **FAIL** on a fresh phone because Python is not installed yet. This is EXPECTED and NORMAL.

**Command:**
```bash
cd <path-to-your-cloned-repo>
ansible -i ansible/inventory/hosts.yaml termux_controller -m ping
```

**Expected output on fresh phone (Python not installed yet):**
```
phone1 | FAILED! => {
    "msg": "The module interpreter '/data/data/com.termux/files/usr/bin/python' was not found."
}
```

**What this means:**
- ✅ SSH connection is working (if you see this error)
- ✅ Ansible can reach the phone
- ❌ Python is not installed yet (will be installed in Phase 1 of automation)

**After automation completes, you should see:**
```
phone1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

**Results:**
- [x] Ansible test run: **FAILED (as expected - Python not installed)**
- [x] SSH connection verified: **Working**
- [ ] Python installation pending: **Will be installed by automation**

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

### Issue 1: Plugin Installation Failed (CRITICAL)
**Description:**
Only 3 plugins were installed instead of the expected 88 plugins from `plugins.txt`.

**Actual plugins installed:**
- ant:520.vd082ecfb_16a_9
- commons-lang3-api (dependency)
- structs (dependency)

**Expected:** 88 plugins including configuration-as-code, git, workflow-aggregator, ssh-slaves, etc.

**Root Cause:**
The jenkins-jcasc role attempts to install plugins using jenkins-plugin-cli, but this tool either:
1. Doesn't exist in the Jenkins installation
2. Failed silently during execution
3. Requires additional setup not performed by the playbook

**Impact:**
- ❌ SSH agent plugin not installed → Agent cannot connect to controller
- ❌ Git plugin missing → Cannot run git-based jobs
- ❌ Pipeline plugins missing → Cannot run pipeline jobs
- ❌ Configuration-as-code plugin missing → JCasC not fully functional

**Workaround:**
Manual plugin installation required via Jenkins UI or CLI after setup.

**GitHub Issue:** #35

---

### Issue 2: Agent Not Connected (Consequence of Issue #1)
**Description:**
Jenkins agent (termux-agent-1) is configured but not connected to the controller.

**Configuration status:**
- ✅ Agent directories created
- ✅ SSH key generated
- ✅ SSH test passed (localhost:8022)
- ✅ JCasC configuration deployed
- ❌ Agent node not visible in Jenkins UI

**Root Cause:**
Missing ssh-slaves plugin (dependency of Issue #1). Without this plugin, Jenkins cannot create SSH-based agent nodes even with valid JCasC configuration.

**Verification attempted:**
```bash
curl -s http://localhost:8080/computer/api/json
# Returns 403 Forbidden (requires authentication)
# Manual UI check confirms: no agent nodes present
```

**Workaround:**
1. Install ssh-slaves plugin manually
2. Apply JCasC configuration again
3. Or manually create agent node via Jenkins UI

---

### Issue 3: Termux:Boot Detection Failed (Minor)
**Description:**
The termux-boot-setup role reported that Termux:Boot was NOT installed, but it actually IS installed.

**Evidence:**
```bash
pm list packages | grep termux
# Output shows: package:com.termux.boot
```

**Impact:**
- ❌ Boot scripts were NOT deployed to ~/.termux/boot/
- ❌ Jenkins will NOT auto-start on device reboot
- ⚠️ Manual start required after reboot: `sv-enable sshd && sv-enable jenkins`

**Root Cause:**
The Termux:Boot detection check in the playbook likely checks for:
1. Wrong package name
2. Wrong installation path
3. Wrong permissions or access method

**Workaround:**
Manually run the boot configuration playbook:
```bash
ansible-playbook -i ansible/inventory/hosts.yaml \
  ansible/playbooks/05-configure-boot.yaml
```

**GitHub Issue:** #36

---

### Issue 4: Python Must Be Installed Manually (DOCUMENTED)
**Description:**
Ansible requires Python on the target device before it can execute any modules, but fresh Termux installations don't have Python.

**Solution:** ✅ DOCUMENTED in Step 1
```bash
pkg install python
```

This is now a mandatory prerequisite step before running the automation.

---

### Issue 5: ssh-copy-id Authentication Failures (DOCUMENTED)
**Description:**
Multiple SSH keys in ~/.ssh/ cause "Too many authentication failures" when running ssh-copy-id.

**Solution:** ✅ DOCUMENTED in Step 2
```bash
ssh-copy-id -o IdentitiesOnly=yes -p 8022 -i ~/.ssh/termux_ed25519 192.168.1.53
```

---

## Timing Breakdown

- Step 1 (Termux config): ~3 minutes
- Step 2 (Control machine): ~2 minutes
- Step 3 (Inventory update): ~1 minute
- Step 4 (Ansible test): ~1 minute
- Step 5 (Complete setup): ~15 minutes
- Step 6 (Verification): ~1 minute

**Total time:** ~23 minutes (including manual Python installation)

---

## Configuration Details

### Versions Installed
- Jenkins: 2.528.1 (LTS)
- OpenJDK: 21.0.9
- Python: 3.12.12
- Node.js: v24.9.0
- Git: 2.51.2
- Go: latest (installed)
- Ruby: latest (installed)
- Maven: latest (installed)

### Plugin Count
- **Expected:** 88 plugins (from plugins.txt)
- **Actually Installed:** 3 plugins (ant, commons-lang3-api, structs)
- **Status:** ❌ PLUGIN INSTALLATION FAILED (see Issue #1)

### Notable Missing Plugins
- ❌ configuration-as-code: Not installed
- ❌ git: Not installed
- ❌ workflow-aggregator: Not installed
- ❌ ssh-slaves: Not installed
- **Impact:** Jenkins is running but lacks most functionality

---

## Lessons Learned

1. **Python is a critical prerequisite** - Ansible cannot work without Python on the target. This must be installed manually before automation (`pkg install python`).

2. **Multiple SSH keys cause authentication failures** - The `-o IdentitiesOnly=yes` flag is essential when using ssh-copy-id if you have multiple keys in ~/.ssh/.

3. **Plugin installation mechanism needs verification** - The jenkins-plugin-cli approach failed silently. Need to investigate alternative methods (Jenkins CLI, REST API, or manual installation).

4. **Termux:Boot detection is unreliable** - The package detection check failed even though the app is installed. Need better detection method (perhaps checking the .termux/boot directory existence).

5. **Fresh phone testing reveals hidden issues** - Issues that might not appear when upgrading existing installations become obvious on fresh setups.

6. **JCasC depends on plugins** - Configuration-as-code YAML can be deployed, but it won't work without the required plugins installed first.

7. **Agent setup is multi-layered** - Even with perfect SSH configuration, agent connection fails without the ssh-slaves plugin.

8. **Automation reports can be misleading** - Ansible playbook reported "success" even though plugin installation failed. Need better verification steps.

9. **Old phone emoji (☎️) works great** - Visual distinction for demo purposes (vs modern smartphone emoji 📱).

10. **Total time is reasonable** - ~23 minutes for complete fresh phone setup is acceptable for CloudNord demo, even with manual interventions needed.

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
