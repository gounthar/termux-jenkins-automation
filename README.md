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
- Termux installed from [F-Droid](https://f-droid.org/packages/com.termux/)
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

```bash
# 1. Clone this repository
git clone https://github.com/gounthar/termux-jenkins-automation.git
cd termux-jenkins-automation

# 2. Check prerequisites
./scripts/check-requirements.sh

# 3. Run complete setup (interactive)
ansible-playbook ansible/playbooks/99-complete-setup.yaml

# 4. Access Jenkins
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
- **Comprehensive package suite** (59+ packages via `termux-complete-setup` role):
  - **Build Essentials** (15): clang, gcc-8*, cmake, make, autoconf, automake, libtool, etc.
  - **Programming Languages** (6): openjdk-21, python, golang, rust, perl, tcl
  - **Development Tools** (14): git, gh, maven, gnupg, curl, wget, dos2unix, etc.
  - **Network Tools** (7): openssh, nmap, inetutils, iproute2, net-tools, lsof
  - **System Utilities** (10): htop, nano, termux-services, runit, procps, psmisc
  - **Archive Tools** (7): tar, gzip, bzip2, xz-utils, zip, unzip, zstd
- **Additional Repositories**: Automatically configured (pointless, root) for extended package availability*
- **Termux:API**: Optional Android device integration**
  - CLI tools (`termux-api` package) - installed automatically by this role
  - Companion app (from F-Droid) - must be installed manually for API functionality

*gcc-8 and some packages require additional repositories which are automatically configured

**Termux:API requires both components: the Android companion app (com.termux.api from F-Droid) AND the CLI package. The role installs the CLI package and checks for the app, but full functionality requires manual installation of the companion app.

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
