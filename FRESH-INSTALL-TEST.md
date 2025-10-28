# Fresh Install Test Plan

## Goal
Follow the README.md Quick Start exactly as a new user would, documenting each step and any issues encountered.

## Pre-Test Setup

### 1. Backup Current Installation (SAFETY NET)
```bash
# Run from laptop/PC
ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/backup-jenkins.yaml
```
- [ ] Backup created in `ansible/playbooks/backups/`
- [ ] Note backup filename: `jenkins-<timestamp>.tar.gz`

### 2. Document Current State
- Current Jenkins URL: http://192.168.1.53:8080
- Current username: admin/admin
- Jobs present: (list them)
- Agent status: (connected/disconnected)

### 3. Wipe Phone
**On Android device:**
- [ ] Option A: Clear Termux app data (Settings > Apps > Termux > Storage > Clear Data)
- [ ] Option B: Uninstall and reinstall Termux from GitHub Releases

---

## Test Execution (Following README.md)

## STEP 1: Prepare Termux on Android Device

**Reference:** README.md lines 45-70

### 1.1 Update Packages
```bash
# In Termux on Android phone
pkg update && pkg upgrade
```
- [ ] Commands completed without errors
- [ ] Note any warnings or issues:

### 1.2 Install OpenSSH and Python
```bash
# In Termux
pkg install openssh python
```
- [ ] Installation successful
- [ ] Note message about ssh-agent and termux-services (expected)
- [ ] Any unexpected errors:

### 1.3 Start SSH Daemon
```bash
# In Termux
sshd
```
- [ ] sshd started without errors
- [ ] Verify: `pgrep sshd` returns a PID

### 1.4 Set Password
```bash
# In Termux
passwd
```
- [ ] Password set (use: poddingue)

### 1.5 Get Username and IP
```bash
# In Termux
whoami          # Expected: u0_a557
ifconfig wlan0  # Expected: 192.168.1.53
```
- [ ] Username: __________
- [ ] IP Address: __________
- [ ] Match expected values: YES / NO

---

## STEP 2: Set up SSH Key Authentication

**Reference:** README.md lines 72-87

### 2.1 Generate SSH Key (Laptop)
```bash
# On your laptop/PC
ssh-keygen -t ed25519 -f ~/.ssh/termux_ed25519 -N ""
```
- [ ] Key generated successfully
- [ ] Files exist: `~/.ssh/termux_ed25519` and `~/.ssh/termux_ed25519.pub`

### 2.2 Display Public Key (Laptop)
```bash
# On laptop
cat ~/.ssh/termux_ed25519.pub
```
- [ ] Public key displayed
- [ ] Copy the entire output

### 2.3 Add Public Key to Termux (Phone)
```bash
# In Termux on phone
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo 'YOUR_PUBLIC_KEY_HERE' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```
- [ ] Commands completed
- [ ] Verify: `cat ~/.ssh/authorized_keys` shows your key

### 2.4 Test SSH Connection (Laptop)
```bash
# On laptop - manual test before automation
ssh -i ~/.ssh/termux_ed25519 -p 8022 u0_a557@192.168.1.53 "echo 'SSH works'"
```
- [ ] Connection successful
- [ ] Output: "SSH works"
- [ ] Any errors:

---

## STEP 3: Run Ansible Automation

**Reference:** README.md lines 89-114 (Option A: Interactive Setup Script)

### 3.1 Clone Repository
```bash
# On laptop/PC
git clone https://github.com/gounthar/termux-jenkins-automation.git
cd termux-jenkins-automation
```
- [ ] Repository cloned
- [ ] Working directory: `/mnt/c/support/users/talks/2025/termux/termux-jenkins-automation`

### 3.2 Run Interactive Setup
```bash
# On laptop/PC
./scripts/run-setup.sh
```

**Expected Prompts:**
1. Device IP address: `192.168.1.53`
2. SSH port: `8022` (press Enter for default)
3. Termux username: `u0_a557`
4. Jenkins admin password: `admin` (or choose your own)
5. Authentication method: `1` (SSH key)
6. SSH private key file: `~/.ssh/termux_ed25519` (press Enter for default)
7. Confirm settings: `y`

**Document each prompt:**
- [ ] All prompts appeared as expected
- [ ] Automation started
- [ ] Any unexpected prompts or errors:

### 3.3 Monitor Execution
Watch the output for:
- [ ] Phase 1: Set up Termux base - SUCCESS / FAIL
- [ ] Phase 2: Install Jenkins controller - SUCCESS / FAIL
- [ ] Phase 3: Configure agent and build tools - SUCCESS / FAIL
- [ ] Phase 4: Apply Jenkins Configuration as Code - SUCCESS / FAIL
- [ ] Phase 5: Configure boot auto-start - SUCCESS / FAIL
- [ ] Phase 6: Deploy notification scripts - SUCCESS / FAIL
- [ ] Phase 7: Restore jobs from backup - SUCCESS / FAIL

**Total execution time:** ________ minutes

**Final output:**
- [ ] "Setup Complete!" message displayed
- [ ] Jenkins URL shown: http://192.168.1.53:8080
- [ ] Login credentials shown: admin / [password]

### 3.4 Document Any Errors
**Errors encountered:**
1.
2.
3.

**Warnings encountered:**
1. JCasC reload 403 (expected - documented in issue #41)
2.
3.

---

## STEP 4: Verify Installation

### 4.1 Access Jenkins Web UI
```bash
# From laptop browser
http://192.168.1.53:8080
```
- [ ] Jenkins UI loads
- [ ] Login page appears
- [ ] Login with admin/[password] succeeds
- [ ] Dashboard displays

### 4.2 Verify Plugins
Navigate to: Manage Jenkins > Plugins > Installed plugins
- [ ] 94+ plugins installed
- [ ] Key plugins present:
  - [ ] configuration-as-code
  - [ ] ssh-slaves
  - [ ] git
  - [ ] workflow-aggregator (Pipeline)
  - [ ] job-dsl

### 4.3 Verify Agent
Navigate to: Manage Jenkins > Nodes
- [ ] Agent "termux-agent-1" exists
- [ ] Agent status: Connected / Disconnected
- [ ] Executors: 2
- [ ] Labels: android, termux, mobile

If disconnected:
- [ ] Click on agent > Launch agent
- [ ] Check logs for errors

### 4.4 Verify Notification Scripts (NEW TEST)
```bash
# SSH into phone
ssh -i ~/.ssh/termux_ed25519 -p 8022 u0_a557@192.168.1.53

# Check scripts exist
ls -lh ~/jenkins-talking.sh ~/celebrate.sh ~/failure.sh

# Test one script
./celebrate.sh
```
- [ ] All three scripts exist
- [ ] Scripts are executable
- [ ] Test script runs without errors

### 4.5 Verify Jobs
Check if jobs were restored from backup:
- [ ] Jobs folder exists
- [ ] Jobs listed on dashboard:
  - [ ] hello-world-pipeline
  - [ ] python-test
  - [ ] node-build
  - [ ] termux-stats
  - [ ] Gamification (YOUR TEST JOB)

If no jobs:
- [ ] This is expected (no backup was present)
- [ ] Jobs can be created manually or restored later

---

## STEP 5: Test Sample Jobs

### 5.1 Test Hello World Job
- [ ] Navigate to "hello-world-pipeline"
- [ ] Click "Build Now"
- [ ] Build status: SUCCESS / FAILURE
- [ ] Console output shows phone specs
- [ ] Build ran on agent: termux-agent-1

**If failed, error message:**

### 5.2 Test Gamification Job (With Notification Scripts)
- [ ] Navigate to "Gamification" job
- [ ] Click "Build Now"
- [ ] Build status: SUCCESS / FAILURE
- [ ] Console output shows: `/data/data/com.termux/files/home/jenkins-talking.sh` executed
- [ ] NO "not found" error (THIS IS THE KEY TEST)

**If failed, error message:**

### 5.3 Test Python Job (Optional)
- [ ] Navigate to "python-test"
- [ ] Click "Build Now"
- [ ] Build status: SUCCESS / FAILURE

**If failed, error message:**

---

## STEP 6: Test Auto-Start on Boot (Optional)

### 6.1 Check Termux:Boot Configuration
- [ ] Termux:Boot app installed (from F-Droid or GitHub)
- [ ] Boot scripts deployed to `~/.termux/boot/`

### 6.2 Test Reboot
1. Reboot Android device
2. Wait 2-3 minutes
3. Check Jenkins status:
```bash
# From laptop
curl -s http://192.168.1.53:8080 | grep -q "Jenkins" && echo "Jenkins is up"
```
- [ ] Jenkins started automatically
- [ ] Agent reconnected

**If not started:**
- [ ] Check if Termux:Boot is installed
- [ ] Boot scripts gracefully skipped (expected if no Termux:Boot)

---

## Test Results Summary

### Overall Success Rate
- Total phases: 7
- Phases succeeded: ____ / 7
- Phases failed: ____ / 7

### Critical Features Working
- [ ] Jenkins web UI accessible
- [ ] Admin login works
- [ ] Plugins installed correctly
- [ ] Agent connected
- [ ] **Notification scripts deployed** (jenkins-talking.sh, celebrate.sh, failure.sh)
- [ ] Jobs can be created/run
- [ ] Gamification job works WITHOUT "not found" error

### Time Metrics
- Termux preparation: ________ minutes
- SSH setup: ________ minutes
- Automation execution: ________ minutes
- Total time: ________ minutes
- **Compared to README estimate:** 10-15 minutes

### Issues Found
1.
2.
3.

### Improvements Needed
1.
2.
3.

### README Accuracy
- [ ] README steps were clear and accurate
- [ ] All prerequisites were mentioned
- [ ] Estimated time was realistic
- [ ] Screenshots/examples would help at:

---

## Restoration (If Needed)

If test fails and you need to restore:

```bash
# 1. Extract backup
cd ansible/playbooks/backups
tar -xzf jenkins-<timestamp>.tar.gz

# 2. SSH to phone
ssh -i ~/.ssh/termux_ed25519 -p 8022 u0_a557@192.168.1.53

# 3. Copy job configs
# (Manual restoration instructions from backup README)
```

---

## Next Steps After Test

### If Test Succeeds (90%+ features working)
- [ ] Document success in GitHub issue or discussion
- [ ] Consider adding screenshots to README
- [ ] Mark project as "Production Ready"
- [ ] Share results with community

### If Test Partially Succeeds (70-90%)
- [ ] Document issues found
- [ ] Create GitHub issues for each problem
- [ ] Fix issues and retest
- [ ] Update README with workarounds

### If Test Fails (<70%)
- [ ] Analyze failure points
- [ ] Check if issues are environmental (network, device-specific)
- [ ] Debug most critical failures first
- [ ] Consider phased rollback and testing

---

## Test Metadata

- **Test Date:** __________
- **Tester:** Bruno
- **Device Model:** __________
- **Android Version:** __________
- **Termux Version:** __________
- **Jenkins Version:** (from automation)
- **Test Duration:** ________ minutes
- **README Version:** Latest commit (4289698)

---

## Notes

(Add any additional observations, insights, or recommendations here)
