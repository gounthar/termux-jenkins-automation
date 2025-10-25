# Ansible Role: termux-complete-setup

Complete Termux package installation role for reproducible Android development environments. Based on the comprehensive package documentation in `docs/TERMUX-SETUP.md`.

## Description

This role installs and configures a complete Termux environment with all packages documented in the CloudNord Jenkins automation project. It provides a reproducible way to set up identical Termux environments across multiple Android devices.

## Requirements

- Termux installed on Android device (from F-Droid recommended)
- At least 500MB free storage (2GB+ recommended for full setup)
- Ansible 2.10 or higher
- SSH access to Termux (port 8022)
- Target device accessible via SSH

## Role Variables

### Package Group Toggles

Enable or disable specific package groups:

```yaml
install_build_essentials: true    # Build tools (clang, gcc, cmake, make, etc.)
install_languages: true           # Programming languages (Java, Python, Go, Rust)
install_dev_tools: true           # Development tools (git, gh, maven, curl, wget)
install_network_tools: true       # Network utilities (openssh, nmap, lsof)
install_system_utilities: true    # System utilities (htop, nano, procps)
install_termux_api: true          # Termux API CLI tools
```

### Storage Management

```yaml
check_storage_space: true         # Check available storage before installation
minimum_storage_mb: 500           # Minimum storage required (installation fails if less)
recommended_storage_mb: 2048      # Recommended storage (warning if less)
```

### Package Management

```yaml
update_packages_before_install: true    # Run pkg update before installation
upgrade_packages_before_install: false  # Run pkg upgrade before installation (takes time)
```

### Python Packages

```yaml
install_python_packages: false    # Install additional Python pip packages
python_pip_packages:              # List of pip packages to install
  - pip
  - setuptools
  - wheel
```

### Verification

```yaml
verify_installations: true        # Verify tool installations after completion
```

## Package Lists

See `defaults/main.yaml` for complete package lists organized by category:

- **Build Essentials** (15 packages): build-essential, clang, gcc-8, cmake, make, etc.
- **Languages** (6 packages): openjdk-21, python, golang, rust, perl, tcl
- **Dev Tools** (14 packages): git, gh, maven, gnupg, curl, wget, etc.
- **Network Tools** (7 packages): openssh, nmap, inetutils, net-tools, etc.
- **System Utilities** (10 packages): htop, nano, termux-services, runit, etc.
- **Archive Tools** (7 packages): tar, gzip, bzip2, zip, unzip, etc.

## Dependencies

This role depends on variables from:
- `termux-base` role (for `termux_home` and `termux_bin` variables)

## Example Playbook

### Minimal Usage

```yaml
- hosts: termux_agents
  roles:
    - role: termux-base
    - role: termux-complete-setup
```

### Custom Configuration

```yaml
- hosts: termux_agents
  roles:
    - role: termux-base
    - role: termux-complete-setup
      vars:
        # Install only essential tools (skip languages and network tools)
        install_build_essentials: true
        install_languages: false
        install_dev_tools: true
        install_network_tools: false
        install_system_utilities: true

        # Enable Python packages
        install_python_packages: true
        python_pip_packages:
          - pip
          - setuptools
          - wheel
          - virtualenv
          - pytest
          - requests

        # Adjust storage requirements
        minimum_storage_mb: 1000
        recommended_storage_mb: 3000
```

### CloudNord Jenkins Setup

```yaml
- hosts: termux_controller
  roles:
    - role: termux-base
    - role: termux-complete-setup
      vars:
        # Install all packages for full Jenkins CI/CD environment
        install_build_essentials: true
        install_languages: true
        install_dev_tools: true
        install_network_tools: true
        install_system_utilities: true
        install_termux_api: true
```

## Usage in Existing Playbooks

To integrate this role into the existing setup workflow, update `ansible/playbooks/01-setup-termux.yaml`:

```yaml
---
- name: Set up Termux environment
  hosts: termux_agents
  gather_facts: false
  become: false

  roles:
    - termux-base
    - termux-complete-setup  # Add this role
    # - termux-buildtools    # Can replace this with termux-complete-setup
```

## Storage Requirements

| Configuration | Minimum | Recommended | Description |
|--------------|---------|-------------|-------------|
| Base only | 500MB | 1GB | Core packages only |
| Minimal Jenkins | 1GB | 2GB | Build tools + Java + Git |
| Complete setup | 2GB | 3GB | All packages |

## Package Installation Time

Approximate installation times (depends on device and network):

- Build essentials: 5-10 minutes
- Programming languages: 10-15 minutes
- Complete setup: 20-30 minutes

## Idempotency

This role is designed to be idempotent:
- Running it multiple times is safe
- Already installed packages are skipped
- Storage checks prevent failures
- Verification confirms successful installation

## Error Handling

The role includes:
- **Storage validation**: Fails if insufficient storage
- **Package installation checks**: Continues if package already installed
- **Termux:API validation**: Warns if Android app not installed
- **Verification tests**: Confirms tools are working

## Verification

After installation, the role verifies:
- Java (openjdk-21)
- Python
- Go
- Git
- Maven

## Termux:API Notes

For Termux:API to work, both components are required:

1. **Android App**: Install from F-Droid
   ```
   https://f-droid.org/packages/com.termux.api/
   ```

2. **CLI Package**: Installed automatically by this role
   ```bash
   pkg install termux-api
   ```

The role will warn if the Android app is not installed but will continue.

## Troubleshooting

### Insufficient Storage

```
Error: Insufficient storage space. Available: 400 MB, Required: 500 MB
```

**Solution**: Free up storage on the device or disable package groups:
```yaml
install_languages: false  # Saves ~500MB
```

### Package Installation Fails

```
Error: Could not install package xyz
```

**Solutions**:
1. Update package lists: `pkg update`
2. Check network connectivity
3. Verify package name in Termux repositories

### Termux:API Not Working

```
Warning: Termux:API Android app is not installed
```

**Solution**: Install Termux:API app from F-Droid, then re-run the playbook.

## Author

CloudNord Jenkins Automation Project

## License

Apache License 2.0

## See Also

- [TERMUX-SETUP.md](../../../docs/TERMUX-SETUP.md) - Complete package documentation
- [termux-base role](../termux-base/) - Base Termux configuration
- [jenkins-controller role](../jenkins-controller/) - Jenkins installation
