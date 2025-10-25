# Termux Setup Documentation

This document provides a comprehensive list of all Termux packages and add-on applications used in the CloudNord Jenkins automation project.

## Device Information

**Test Device**: Xiaomi Redmi Note 7
- **Android Version**: 10
- **Architecture**: aarch64 (arm64-v8a)
- **Kernel**: Linux 4.4.192-perf+
- **Termux Version**: 0.118.0
- **Termux APK Source**: GitHub
- **Package Format**: Debian (apt)

## Termux Add-on Applications

Termux add-on applications extend the main Termux app with additional capabilities. These apps must be installed separately from F-Droid or the GitHub releases page.

### Installed Add-ons

#### Termux:API
- **Package**: com.termux.api
- **Version**: 0.50.1 (versionCode: 51)
- **Purpose**: Provides access to Android device APIs from the command line
- **CLI Package**: `termux-api` (version 0.59.1-1)
- **Key Features**:
  - Battery status and monitoring
  - Notifications
  - Location services
  - Camera access
  - Clipboard operations
  - Sensor data (accelerometer, gyroscope, etc.)
  - Toast messages
  - Vibration control
  - Volume control
  - WiFi information

**Installation**:
```bash
# 1. Install the Android app from F-Droid:
#    https://f-droid.org/packages/com.termux.api/

# 2. Install the CLI package in Termux:
pkg install termux-api

# 3. Test the installation:
termux-battery-status
```

### Recommended Add-ons (Not Currently Installed)

#### Termux:Boot
- **Purpose**: Auto-start scripts when device boots
- **Use Case**: Automatically start Jenkins and SSH daemon on device startup
- **Installation**: https://f-droid.org/packages/com.termux.boot/

**Setup for auto-starting Jenkins**:
```bash
# 1. Install Termux:Boot from F-Droid
# 2. Create boot script directory
mkdir -p ~/.termux/boot/

# 3. Create auto-start script
cat > ~/.termux/boot/start-services.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Start SSH daemon
sshd

# Start Jenkins
cd ~
nohup java -jar jenkins.war --httpPort=8080 > ~/.jenkins/logs/jenkins.log 2>&1 &
EOF

# 4. Make script executable
chmod +x ~/.termux/boot/start-services.sh

# 5. Reboot device to test
```

#### Other Available Add-ons

- **Termux:Float**: Run Termux in a floating window
- **Termux:Styling**: Customize colors and fonts
- **Termux:Tasker**: Integration with Tasker automation app
- **Termux:Widget**: Add Termux shortcuts to home screen

## Installed Packages

### Build Essentials

Critical packages for software development and compilation:

```bash
pkg install \
  build-essential \
  binutils \
  clang \
  gcc-8 \
  make \
  cmake \
  autoconf \
  automake \
  libtool \
  m4 \
  bison \
  flex \
  patch \
  gperf
```

**Key Versions**:
- clang: 21.1.3-1
- gcc-8: 8.3.0-3
- cmake: 4.1.2
- make: 4.4.1-1

### Programming Languages & Runtimes

```bash
pkg install \
  openjdk-21 \
  python \
  golang \
  rust \
  perl \
  tcl
```

**Versions**:
- OpenJDK: 21.0.8-2 (Jenkins requirement)
- Python: 3.12.12
- Go: 1.25.2
- Rust: 1.90.0

### Version Control & Development Tools

```bash
pkg install \
  git \
  gh \
  gnupg \
  curl \
  wget
```

**Versions**:
- git: 2.51.1
- gh (GitHub CLI): 2.82.0
- curl: 8.16.0
- wget: 1.25.0

### SSH & Network Tools

```bash
pkg install \
  openssh \
  openssh-sftp-server \
  inetutils \
  iproute2 \
  net-tools \
  nmap \
  lsof
```

**Versions**:
- openssh: 10.2p1
- nmap: 7.98

**SSH Configuration**:
- Default port: 8022 (not standard 22)
- Service management: `sshd` command
- Config file: `$PREFIX/etc/ssh/sshd_config`

### Build Tools & Utilities

```bash
pkg install \
  maven \
  dos2unix \
  file \
  findutils \
  grep \
  sed \
  gawk \
  diffutils \
  which \
  procps \
  psmisc \
  htop
```

**Versions**:
- maven: 3.9.11-1
- grep: 3.12-2
- sed: 4.9-2
- htop: 3.4.1-1

### System Services

```bash
pkg install \
  termux-services \
  runit \
  termux-tools \
  termux-exec
```

**Service Management**:
- Uses `runit` (not systemd)
- Commands: `sv-enable`, `sv-disable`, `sv up`, `sv down`
- Service directory: `$PREFIX/var/service/`

### Text Editors & Utilities

```bash
pkg install \
  nano \
  ed \
  less \
  dialog
```

**Versions**:
- nano: 8.6-1

### Compression & Archive Tools

```bash
pkg install \
  tar \
  gzip \
  bzip2 \
  xz-utils \
  zip \
  unzip \
  zstd
```

### Libraries (Automatically Installed)

Key libraries installed as dependencies:

**Core Libraries**:
- libc++ (28c) - C++ standard library
- libandroid-support (29-1) - Android compatibility
- ncurses (6.5.20240831-3) - Terminal handling
- readline (8.3.1-1) - Line editing
- openssl (1:3.5.2) - Cryptography
- libevent (2.1.12-3) - Event notification
- libssh2 (1.11.1-1) - SSH2 protocol

**Development Libraries**:
- libicu (77.1-2) - Unicode and internationalization
- libxml2 (2.15.0) - XML parser
- libcurl (8.16.0) - HTTP client
- libgit2 (via git) - Git implementation
- libsqlite (3.50.4-1) - Database

**Java Libraries**:
- ca-certificates-java (1:2025.09.09) - Java CA certificates
- libjansi (2.4.2-1) - ANSI console output for Java

### Package Repositories

Currently subscribed repositories:

```bash
# Main Termux repository
deb https://mirror.bouwhuis.network/termux/termux-main stable main

# Pointless repository (extra packages)
deb https://its-pointless.github.io/files/21 termux extras

# Root repository
deb https://mirror.bouwhuis.network/termux/termux-root root stable

# Jenkins official repository
deb [signed-by=/data/data/com.termux/files/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/
```

## Complete Package List

Total packages installed: **223**

<details>
<summary>Click to expand complete package list</summary>

```
abseil-cpp (20250814.0)
alsa-lib (1.2.14-1)
alsa-plugins (1.2.12-1)
apt (2.8.1-2)
autoconf (2.72)
automake (1.18.1)
bash (5.3.3-1)
bash-completion (2.16.0)
bc (1.08.2-1)
binutils (2.44-4)
binutils-bin (2.44-4)
binutils-libs (2.44-4)
bison (3.8.2-4)
brotli (1.1.0-3)
build-essential (4.1)
bzip2 (1.0.8-8)
ca-certificates (1:2025.09.09)
ca-certificates-java (1:2025.09.09)
clang (21.1.3-1)
cmake (4.1.2)
command-not-found (3.2)
coreutils (9.8-1)
curl (8.16.0)
dash (0.5.12-1)
dbus (1.16.2-2)
debianutils (5.23.2-1)
dialog (1.3-20240307-1)
diffutils (3.12-2)
dos2unix (7.5.2-1)
dpkg (1.22.6-4)
ed (1.22.2-1)
file (5.46-2)
findutils (4.10.0-1)
flex (2.6.4-4)
fontconfig (2.17.1-1)
freetype (2.14.1)
gawk (5.3.1-2)
gcc-8 (8.3.0-3)
gdbm (1.26-1)
gh (2.82.0)
giflib (5.2.2-1)
git (2.51.1)
glib (2.86.0)
gnupg (2.5.11)
golang (3:1.25.2)
gperf (3.3-1)
gpgv (2.5.11)
grep (3.12-2)
gzip (1.14-1)
htop (3.4.1-1)
inetutils (2.6-1)
iproute2 (6.17.0)
jsoncpp (1.9.6-2)
krb5 (1.22.1-1)
ldns (1.8.4-1)
less (685)
libandroid-execinfo (0.1-3)
libandroid-glob (0.6-3)
libandroid-posix-semaphore (0.1-4)
libandroid-selinux (14.0.0.11-1)
libandroid-shmem (0.5-1)
libandroid-spawn (0.3)
libandroid-support (29-1)
libandroid-sysv-semaphore (0.1-1)
libandroid-utimes (0.4)
libarchive (3.8.2)
libassuan (3.0.2-1)
libblkid (2.41.2)
libbz2 (1.0.8-8)
libc++ (28c)
libcap-ng (2:0.8.5-1)
libcompiler-rt (21.1.3-1)
libcrypt (0.2-6)
libcurl (8.16.0)
libdb (18.1.40-5)
libedit (20240517-3.1-1)
libevent (2.1.12-3)
libexpat (2.7.3)
libffi (3.4.7-1)
libflac (1.5.0-1)
libgcrypt (1.11.2-1)
libgmp (6.3.0-2)
libgnutls (3.8.10)
libgpg-error (1.55-1)
libiconv (1.18-1)
libicu (77.1-2)
libidn2 (2.3.8-1)
libisl (0.26-1)
libjansi (2.4.2-1)
libjpeg-turbo (3.1.2)
libksba (1.6.7-2)
libllvm (21.1.3-1)
libltdl (2.5.4-2)
liblua54 (5.4.8-3)
liblz4 (1.10.0-1)
liblzma (5.8.1-1)
libmd (1.1.0-1)
libmount (2.41.2)
libmp3lame (3.100-7)
libmpc (1.3.1-1)
libmpfr (4.2.1-1)
libnettle (3.10.2-1)
libnghttp2 (1.67.1)
libnghttp3 (1.12.0)
libnpth (1.6-3)
libogg (1.3.6-1)
libopus (1.5.2-1)
libpcap (1.10.5-1)
libpng (1.6.50-1)
libresolv-wrapper (1.1.7-6)
libsmartcols (2.41.2)
libsndfile (1.2.2-2)
libsoxr (0.1.3-8)
libsqlite (3.50.4-1)
libssh2 (1.11.1-1)
libtalloc (2.4.3)
libtirpc (1.3.7-1)
libtool (2.5.4-2)
libunbound (1.24.0)
libunistring (1.3-1)
libuuid (2.41.2)
libuv (1.51.0-1)
libvorbis (1.3.7-4)
libwebrtc-audio-processing (1.3-3)
libx11 (1.8.12-1)
libxau (1.0.12-2)
libxcb (1.17.0-1)
libxdmcp (1.1.5-2)
libxext (1.3.6-1)
libxi (1.8.2-1)
libxml2 (2.15.0)
libxrender (0.9.12-1)
libxtst (1.2.5-1)
littlecms (2.17-1)
lld (21.1.3-1)
llvm (21.1.3-1)
lsof (4.99.5-2)
m4 (1.4.19-5)
make (4.4.1-1)
maven (3.9.11-1)
mount-utils (2.41.2)
nano (8.6-1)
ncurses (6.5.20240831-3)
ncurses-ui-libs (6.5.20240831-3)
ndk-sysroot (28c)
net-tools (2.10.0-1)
nmap (7.98)
openjdk-21 (21.0.8-2)
openjdk-21-x (21.0.8-2)
openssh (10.2p1)
openssh-sftp-server (10.2p1)
openssl (1:3.5.2)
patch (2.8-1)
pcre (8.45-2)
pcre2 (10.46)
perl (5.40.3-1)
pinentry (1.3.2-1)
pkg-config (0.29.2-3)
procps (3.3.17-6)
proot (5.1.107-67)
psmisc (23.7-1)
pulseaudio (17.0-1)
python (3.12.12)
python-ensurepip-wheels (3.12.12)
python-pip (25.2)
readline (8.3.1-1)
resolv-conf (1.3)
rhash (1.4.6-1)
root-repo (2.4-2)
runit (2.1.2-4)
rust (1.90.0+really1.90.0-1)
rust-std-aarch64-linux-android (1.90.0+really1.90.0-1)
sed (4.9-2)
setup-scripts (2.6.6)
speexdsp (1.2.1-1)
tar (1.35-1)
tcl (8.6.14-1)
termux-am (0.8.0-2)
termux-am-socket (1.5.0-1)
termux-api (0.59.1-1)
termux-auth (1.5.0-1)
termux-core (0.4.0-1)
termux-elf-cleaner (3.0.1-1)
termux-exec (1:2.4.0-1)
termux-keyring (3.13)
termux-licenses (2.1)
termux-services (0.13-1)
termux-tools (1.46.0+really1.45.0-1)
texinfo (7.2-3)
tsu (8.6.0-1)
ttf-dejavu (2.37-8)
unbound (1.24.0)
unzip (6.0-10)
update-info-dir (7.2-3)
util-linux (2.41.2)
wget (1.25.0-1)
which (2.23-1)
xxhash (0.8.3-1)
xz-utils (5.8.1-1)
zip (3.0-6)
zlib (1.3.1-1)
zstd (1.5.7-1)
```

</details>

## Installation Commands

### Quick Start (Minimal Setup)

For a basic Termux Jenkins environment:

```bash
# Update package lists
pkg update && pkg upgrade -y

# Install essential packages
pkg install -y \
  openssh \
  git \
  openjdk-21 \
  wget \
  curl

# Start SSH daemon
sshd
```

### Complete Setup (All Packages)

To replicate the exact environment:

```bash
# Update system
pkg update && pkg upgrade -y

# Install build essentials
pkg install -y build-essential binutils clang gcc-8 cmake make

# Install programming languages
pkg install -y openjdk-21 python golang rust

# Install development tools
pkg install -y git gh maven

# Install network tools
pkg install -y openssh inetutils net-tools nmap

# Install utilities
pkg install -y htop nano wget curl dos2unix

# Install Termux services
pkg install -y termux-services runit

# Install Termux:API CLI tools
pkg install -y termux-api

# Enable SSH daemon
sv-enable sshd
```

## Package Management

### Common Commands

```bash
# Update package lists
pkg update

# Upgrade all packages
pkg upgrade

# Install a package
pkg install <package-name>

# Remove a package
pkg uninstall <package-name>

# Search for packages
pkg search <keyword>

# List installed packages
pkg list-installed

# Show package information
pkg show <package-name>

# Clean package cache
pkg clean
```

### Service Management

Termux uses `runit` for service management (not systemd):

```bash
# Enable a service (persistent across reboots)
sv-enable <service-name>

# Disable a service
sv-disable <service-name>

# Start a service
sv up <service-name>

# Stop a service
sv down <service-name>

# Check service status
sv status <service-name>

# View service logs
svlogtail <service-name>
```

## Environment Variables

Key Termux environment variables:

```bash
# Termux installation prefix
PREFIX=/data/data/com.termux/files/usr

# Termux home directory
HOME=/data/data/com.termux/files/home

# Python interpreter
PYTHON=/data/data/com.termux/files/usr/bin/python

# Java home (OpenJDK 21)
JAVA_HOME=/data/data/com.termux/files/usr/opt/openjdk
```

## Important Notes

1. **No Root Required**: Termux runs entirely in userspace without root access
2. **Package Manager**: Uses `pkg` (wrapper around `apt`) for package management
3. **No Systemd**: Uses `runit` for service management
4. **SSH Port**: Default SSH port is 8022 (not 22)
5. **Storage Access**: Run `termux-setup-storage` to access Android storage
6. **Wakelock**: Use `termux-wake-lock` to prevent device sleep during long operations

## Troubleshooting

### Package Installation Issues

```bash
# Clear package cache
pkg clean

# Update package lists
pkg update

# Try installation again
pkg install <package-name>
```

### SSH Connection Issues

```bash
# Check if SSH daemon is running
pgrep sshd

# Restart SSH daemon
pkill sshd
sshd

# Check SSH configuration
cat $PREFIX/etc/ssh/sshd_config
```

### Service Management Issues

```bash
# List all services
ls $PREFIX/var/service/

# Check service logs
svlogtail <service-name>

# Restart a service
sv restart <service-name>
```

## References

- [Termux Wiki](https://wiki.termux.com/)
- [Termux GitHub](https://github.com/termux/termux-app)
- [Termux Packages](https://github.com/termux/termux-packages)
- [Termux:API Documentation](https://wiki.termux.com/wiki/Termux:API)
- [F-Droid Termux Repository](https://f-droid.org/en/packages/com.termux/)

---

**Last Updated**: 2025-10-25
**Device**: Xiaomi Redmi Note 7 (Android 10, aarch64)
**Termux Version**: 0.118.0
