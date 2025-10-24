#!/bin/bash
#
# Script: check-requirements.sh
# Description: Pre-flight checks for Termux Jenkins automation
# Usage: ./scripts/check-requirements.sh

set -e

echo "=== Checking Prerequisites ==="
echo

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Check Ansible
echo -n "Checking Ansible... "
if command -v ansible >/dev/null 2>&1; then
    ANSIBLE_VERSION=$(ansible --version | head -n1 | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Found version $ANSIBLE_VERSION"

    # Check if version >= 2.10
    MAJOR=$(echo "$ANSIBLE_VERSION" | cut -d. -f1)
    MINOR=$(echo "$ANSIBLE_VERSION" | cut -d. -f2)
    if [ "$MAJOR" -lt 2 ] || ([ "$MAJOR" -eq 2 ] && [ "$MINOR" -lt 10 ]); then
        echo -e "${YELLOW}⚠${NC} Ansible 2.10+ recommended (you have $ANSIBLE_VERSION)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗${NC} Not found"
    echo "  Install: pip install ansible"
    ERRORS=$((ERRORS + 1))
fi

# Check SSH
echo -n "Checking SSH client... "
if command -v ssh >/dev/null 2>&1; then
    SSH_VERSION=$(ssh -V 2>&1 | awk '{print $1}')
    echo -e "${GREEN}✓${NC} Found $SSH_VERSION"
else
    echo -e "${RED}✗${NC} Not found"
    echo "  Install: apt-get install openssh-client (Debian/Ubuntu)"
    ERRORS=$((ERRORS + 1))
fi

# Check sshpass (optional but helpful)
echo -n "Checking sshpass... "
if command -v sshpass >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Found"
else
    echo -e "${YELLOW}⚠${NC} Not found (optional but recommended for initial setup)"
    echo "  Install: apt-get install sshpass"
    WARNINGS=$((WARNINGS + 1))
fi

# Check if inventory file exists
echo -n "Checking inventory file... "
if [ -f "ansible/inventory/hosts.yaml" ]; then
    echo -e "${GREEN}✓${NC} Found"

    # Check if IP is still default
    if grep -q "192.168.1.50" ansible/inventory/hosts.yaml; then
        echo -e "${YELLOW}⚠${NC} Using default IP (192.168.1.50) - update with your phone's IP"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗${NC} Not found"
    ERRORS=$((ERRORS + 1))
fi

# Check Python (for Ansible modules)
echo -n "Checking Python... "
if command -v python3 >/dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Found version $PYTHON_VERSION"
else
    echo -e "${RED}✗${NC} Python 3 not found"
    ERRORS=$((ERRORS + 1))
fi

echo
echo "=== Summary ==="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All required prerequisites met${NC}"
else
    echo -e "${RED}✗ $ERRORS required prerequisite(s) missing${NC}"
fi

if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s)${NC}"
fi

echo
echo "=== Next Steps ==="
echo "1. Update ansible/inventory/hosts.yaml with your phone's IP address"
echo "2. Ensure Termux is installed on your phone (from F-Droid)"
echo "3. In Termux, run: pkg install openssh && sshd"
echo "4. Set a password in Termux: passwd"
echo "5. Run: ansible-playbook ansible/playbooks/99-complete-setup.yaml"

exit $ERRORS
