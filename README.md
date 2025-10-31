# Jenkins on Termux - CloudNord Automation

Transform your Android phone into a functional Jenkins CI/CD environment in minutes using Ansible and Termux.

## 🎯 Project Goal

This repository provides a turnkey Ansible-based automation that:
- Installs Jenkins on Android devices running Termux
- Configures a Jenkins agent for running builds
- Uses Jenkins Configuration as Code (JCasC) for reproducible setup
- Demonstrates infrastructure-as-code principles on consumer hardware

**From the CloudNord talk**: "Repurpose aging Android smartphones for DevOps automation"

## ⚡ Quick Start (10 Minutes)

### Prerequisites

**On your Android phone:**
- **Termux** installed (required)
  - Recommended: [GitHub Releases](https://github.com/termux/termux-app/releases) (Latest: [v0.118.3](https://github.com/termux/termux-app/releases/tag/v0.118.3))
  - Alternative: [F-Droid](https://f-droid.org/packages/com.termux/)
  - ⚠️ **Do NOT use Google Play Store version** (outdated and incompatible)
- **Termux companion apps** (optional but recommended):
  - **Termux:API** - Enables Android device API access (battery, location, notifications, etc.)
    - [GitHub](https://github.com/termux/termux-api/releases) (Latest: [v0.53.0](https://github.com/termux/termux-api/releases/tag/v0.53.0)) | [F-Droid](https://f-droid.org/packages/com.termux.api/)
  - **Termux:Boot** - Auto-start Jenkins on device boot (hands-free operation)
    - [GitHub](https://github.com/termux/termux-boot/releases) (Latest: [v0.8.1](https://github.com/termux/termux-boot/releases/tag/v0.8.1)) | [F-Droid](https://f-droid.org/packages/com.termux.boot/)
    - **Why needed**: Without Termux:Boot, Jenkins must be started manually after each reboot
    - **With Termux:Boot**: ✅ Jenkins starts automatically, ✅ Perfect for demos/production
    - **Configuration**: Automated via `termux-boot-setup` role (optional)
- Storage requirements:
  - **Minimum**: 500MB free storage (base installation)
  - **Recommended**: 2GB+ free storage (complete setup with all packages)
  - Automatic storage validation before installation
- Connected to WiFi

**On your laptop/PC:**
- Ansible >= 2.10
- SSH client
- Same WiFi network as phone

### Installation

**Step 1: Prepare Termux on your Android device**

⚠️ **CRITICAL**: Complete these steps ON YOUR ANDROID DEVICE in Termux before running Ansible:

```bash
# In Termux on your Android phone:

# 1. Update packages
pkg update && pkg upgrade

# 2. Install OpenSSH and Python (required for Ansible)
pkg install openssh python

# Note: You may see a message about ssh-agent and termux-services
# This is informational - termux-services will be installed automatically

# 3. Start SSH daemon
sshd

# 4. Set a password (Ansible needs this to connect)
passwd

# 5. Get your username and IP address (you'll need these for Ansible)
whoami          # Note this username (e.g., u0_a504)
ifconfig wlan0  # Note your IP address
```

**Step 2: Set up SSH key authentication**

```bash
# On your laptop/PC:

# 1. Generate SSH key for Ansible automation
ssh-keygen -t ed25519 -f ~/.ssh/termux_ed25519 -N ""

# 2. Display the public key
cat ~/.ssh/termux_ed25519.pub

# Copy the output, then on your Termux device run:
# mkdir -p ~/.ssh && chmod 700 ~/.ssh
# echo 'YOUR_PUBLIC_KEY_HERE' >> ~/.ssh/authorized_keys
# chmod 600 ~/.ssh/authorized_keys
```

**Step 3: Run Ansible automation from your laptop/PC**

**Option A: Interactive Setup Script (Recommended)**

```bash
# On your laptop/PC:

# 1. Clone this repository
git clone https://github.com/gounthar/termux-jenkins-automation.git
cd termux-jenkins-automation

# 2. Run interactive setup
./scripts/run-setup.sh

# The script will prompt you for:
# - Device IP address
# - SSH port (default: 8022)
# - Termux username (from whoami)
# - Jenkins admin password
# - Authentication method (SSH key or password)

# 3. Access Jenkins
# On phone: http://localhost:8080
# From laptop: http://<phone-ip>:8080
# Login: admin / <password-you-chose>
```

**Option B: Manual Configuration**

```bash
# On your laptop/PC:

# 1. Clone this repository
git clone https://github.com/gounthar/termux-jenkins-automation.git
cd termux-jenkins-automation

# 2. Check prerequisites
./scripts/check-requirements.sh

# 3. Update inventory with your phone's details
# Edit ansible/inventory/hosts.yaml:
#   - Replace ansible_host: 192.168.1.53 with your phone's IP
#   - Replace ansible_user: u0_a504 with your username from whoami

# 4. Configure Ansible to use your SSH key
# Edit ansible/inventory/hosts.yaml and add under phone1:
#   ansible_ssh_private_key_file: ~/.ssh/termux_ed25519

# 5. Run complete setup (interactive)
ansible-playbook ansible/playbooks/99-complete-setup.yaml

# 6. Access Jenkins
# On phone: http://localhost:8080
# From laptop: http://<phone-ip>:8080
# Login: admin / <password-from-setup>
```

## 📚 Documentation

- [Termux Setup](docs/TERMUX-SETUP.md) - Complete package documentation (223 packages with versions, Termux add-on apps, device info)
- [termux-complete-setup Role](ansible/roles/termux-complete-setup/README.md) - Comprehensive Ansible role documentation with usage examples and customization options
- See inline documentation in playbooks and roles for additional details

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│      Android Phone (Termux)         │
│  ┌────────────────────────────────┐ │
│  │  Jenkins Controller (Minimal)  │ │
│  │  - Port 8080 (Web UI)          │ │
│  │  - JCaC configured             │ │
│  └──────────┬─────────────────────┘ │
│             │ SSH (localhost:8022)  │
│  ┌──────────▼─────────────────────┐ │
│  │  Jenkins Agent (SSH)           │ │
│  │  - Build tools pre-installed   │ │
│  │  - Python/Node.js/Git          │ │
│  └────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## 🎭 What Gets Installed

**On Termux:**
- **Core packages**: OpenJDK 21, Jenkins LTS, SSH daemon
- **Comprehensive package suite** (60+ packages via `termux-complete-setup` role):
  - **Build Essentials** (15): clang, gcc-8*, cmake, make, autoconf, automake, libtool, etc.
  - **Programming Languages** (6): openjdk-21, python, golang, rust, perl, tcl
  - **Development Tools** (14): git, gh, maven, gnupg, curl, wget, dos2unix, etc.
  - **Network Tools** (8): openssh, nmap, inetutils, iproute2, net-tools, lsof, rsync
  - **System Utilities** (10): htop, nano, termux-services, runit, procps, psmisc
  - **Archive Tools** (7): tar, gzip, bzip2, xz-utils, zip, unzip, zstd
- **Additional Repositories**: Automatically configured (pointless, root) for extended package availability*
- **Termux:API CLI tools**: Automatically installed if Termux:API companion app is present (see Prerequisites)

*gcc-8 and some packages require additional repositories which are automatically configured

**Jenkins Configuration:**
- Pre-configured admin user
- SSH agent connection (localhost)
- Sample jobs (Hello World, Python tests, Node.js builds)
- Configuration as Code (JCasC)

## 🔧 Manual Step-by-Step Setup

If you prefer to understand each phase:

```bash
# Phase 1: Prepare your control machine
ansible-playbook ansible/playbooks/00-prepare-control-machine.yaml

# Phase 2: Set up Termux basics
ansible-playbook ansible/playbooks/01-setup-termux.yaml

# Phase 3: Install Jenkins controller
ansible-playbook ansible/playbooks/02-install-jenkins.yaml

# Phase 4: Configure Jenkins agent
ansible-playbook ansible/playbooks/03-configure-agent.yaml

# Phase 5: Apply JCasC configuration
ansible-playbook ansible/playbooks/04-configure-jcasc.yaml
```

## 💾 Backup & Restore

Backup your Jenkins configuration before wiping devices or testing new setups:

```bash
# Backup Jenkins configuration
ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/backup-jenkins.yaml
```

**What gets backed up:**
- ✅ **Job definitions** (all config.xml files)
- ✅ **Installed plugins** (95+ plugins with versions)
- ✅ **JCasC configuration** (if modified in Jenkins UI)
- ✅ **Metadata** (backup date, device info, Jenkins paths)

**Backup location:** `ansible/playbooks/backups/jenkins-<timestamp>.tar.gz`

**Customization:**
```bash
# Include build history (can be large)
ansible-playbook -i ansible/inventory/hosts.yaml \
  ansible/playbooks/backup-jenkins.yaml \
  -e backup_build_history=true
```

**Restore:**
1. Extract backup: `tar -xzf backups/jenkins-<timestamp>.tar.gz`
2. Copy job configs to `$JENKINS_HOME/jobs/`
3. Restart Jenkins

See `ansible/roles/jenkins-backup/README.md` for detailed documentation.

## 🎁 Demo Jobs Included

1. **hello-world-pipeline**: Simple pipeline showing phone specs
2. **python-test**: Clone repo and run Python tests
3. **node-build**: Build Node.js application
4. **termux-stats**: Display battery, CPU, storage info

## 🚀 Expanding to Multiple Phones

Add more phones to your Jenkins cluster:

```yaml
# ansible/inventory/hosts.yaml
[termux_agents]
phone1 ansible_host=192.168.1.50
phone2 ansible_host=192.168.1.51
phone3 ansible_host=192.168.1.52
```

Then run:
```bash
ansible-playbook ansible/playbooks/03-configure-agent.yaml --limit phone2,phone3
```

## 🛠️ Development

This repository itself uses:
- Ansible for automation
- Jenkins Configuration as Code (JCasC)
- GitHub Actions for validation
- Conventional Commits

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## 📊 Project Status

**Current Phase**: Initial implementation

See [GitHub Issues](https://github.com/gounthar/termux-jenkins-automation/issues) for:
- Implementation roadmap
- Progress tracking
- Known issues
- Feature requests

## 🤝 Contributing

This project welcomes contributions! Areas where help is needed:
- Testing on different Android devices
- Additional sample jobs
- Documentation improvements
- Ansible role enhancements
- JCasC configurations

## 📜 License

[Apache License 2.0](LICENSE)

## 🔗 Related Projects

- [terminal-recording-toolkit](https://github.com/gounthar/terminal-recording-toolkit) - Tools used to create the CloudNord presentation
- [jenkins-docs/quickstart-tutorials](https://github.com/jenkins-docs/quickstart-tutorials) - Official Jenkins Docker tutorials

## 📧 Support

- Open an [issue](https://github.com/gounthar/termux-jenkins-automation/issues) for bugs or questions
- Refer to CloudNord talk materials for context

---

**Created for the CloudNord talk**: "Repurposing Aging Android Smartphones for DevOps"

**Status**: 🚧 Under active development
