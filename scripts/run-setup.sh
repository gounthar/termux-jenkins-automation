#!/bin/bash

# Interactive wrapper script for Termux Jenkins Automation
# This script collects all necessary information and runs the complete setup playbook

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    local missing_deps=()

    if ! command -v ansible-playbook &> /dev/null; then
        missing_deps+=("ansible")
    fi

    if ! command -v sshpass &> /dev/null; then
        print_warning "sshpass not found - you'll need SSH key authentication or install sshpass for password auth"
        print_info "To install on Debian/Ubuntu: sudo apt-get install sshpass"
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Install them first before running this script"
        exit 1
    fi

    print_success "All prerequisites satisfied"
}

# Function to display banner
display_banner() {
    cat << "EOF"
╔════════════════════════════════════════════════════════╗
║   Termux Jenkins Automation - Interactive Setup       ║
║   CloudNord Talk Demonstration                         ║
╚════════════════════════════════════════════════════════╝

This script will help you set up Jenkins on your Android device
using Termux. It will collect all necessary information and run
the automated setup playbook.

EOF
}

# Main script
main() {
    display_banner
    check_prerequisites

    echo ""
    print_info "Please provide the following information about your Termux device:"
    echo ""

    # Get device IP address
    read -p "📱 Device IP address (e.g., 192.168.1.53): " device_ip
    if [[ -z "$device_ip" ]]; then
        print_error "IP address is required"
        exit 1
    fi

    # Get SSH port (default 8022)
    read -p "🔌 SSH port [8022]: " ssh_port
    ssh_port=${ssh_port:-8022}

    # Get Termux username
    print_info "To get your Termux username, run 'whoami' on your device"
    read -p "👤 Termux username (e.g., u0_a557): " termux_user
    if [[ -z "$termux_user" ]]; then
        print_error "Username is required"
        exit 1
    fi

    # Get Jenkins admin password
    read -p "🔐 Jenkins admin password [admin]: " jenkins_password
    jenkins_password=${jenkins_password:-admin}

    # Authentication method
    echo ""
    print_info "Choose authentication method:"
    echo "  1) SSH key (recommended)"
    echo "  2) Password"
    read -p "Choice [1]: " auth_choice
    auth_choice=${auth_choice:-1}

    ssh_password=""
    ssh_key_file=""

    if [[ "$auth_choice" == "1" ]]; then
        # SSH key authentication
        read -p "🔑 SSH private key file [~/.ssh/termux_ed25519]: " ssh_key_file
        ssh_key_file=${ssh_key_file:-~/.ssh/termux_ed25519}
        ssh_key_file="${ssh_key_file/#\~/$HOME}"

        if [[ ! -f "$ssh_key_file" ]]; then
            print_warning "SSH key not found at $ssh_key_file"
            print_info "Make sure your public key is in ~/.ssh/authorized_keys on the device"
            read -p "Continue anyway? (y/N): " continue_choice
            if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
                print_info "Exiting"
                exit 0
            fi
        fi
    else
        # Password authentication
        read -sp "🔒 SSH password for $termux_user: " ssh_password
        echo ""
        if [[ -z "$ssh_password" ]]; then
            print_error "Password is required for password authentication"
            exit 1
        fi
    fi

    # Confirm settings
    echo ""
    print_info "Configuration summary:"
    echo "  Device IP:       $device_ip"
    echo "  SSH Port:        $ssh_port"
    echo "  Username:        $termux_user"
    echo "  Jenkins Admin:   admin"
    echo "  Jenkins Pass:    [hidden]"
    if [[ "$auth_choice" == "1" ]]; then
        echo "  Auth Method:     SSH Key ($ssh_key_file)"
    else
        echo "  Auth Method:     Password"
    fi
    echo ""

    read -p "Proceed with setup? (y/N): " proceed
    if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
        print_info "Setup cancelled"
        exit 0
    fi

    # Update inventory file
    print_info "Updating inventory file..."

    inventory_file="ansible/inventory/hosts.yaml"
    if [[ ! -f "$inventory_file" ]]; then
        print_error "Inventory file not found: $inventory_file"
        exit 1
    fi

    # Create backup
    cp "$inventory_file" "${inventory_file}.backup"

    # Update inventory using sed
    sed -i "s/ansible_host: .*/ansible_host: $device_ip  # Configured by run-setup.sh/" "$inventory_file"
    sed -i "s/ansible_port: .*/ansible_port: $ssh_port/" "$inventory_file"
    sed -i "s/ansible_user: .*/ansible_user: $termux_user  # From whoami command/" "$inventory_file"

    if [[ "$auth_choice" == "1" ]]; then
        sed -i "s|ansible_ssh_private_key_file: .*|ansible_ssh_private_key_file: $ssh_key_file|" "$inventory_file"
    fi

    print_success "Inventory file updated"

    # Run the playbook
    echo ""
    print_info "Starting Jenkins setup (this may take 10-15 minutes)..."
    echo ""

    # Build ansible command
    ansible_cmd="ANSIBLE_ROLES_PATH=ansible/roles ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i $inventory_file ansible/playbooks/99-complete-setup.yaml"

    # Add authentication options
    if [[ "$auth_choice" == "2" ]]; then
        # Password authentication
        ansible_cmd="$ansible_cmd --extra-vars ansible_ssh_pass='$ssh_password'"
    fi

    # Add Jenkins admin password
    ansible_cmd="$ansible_cmd --extra-vars jenkins_admin_password='$jenkins_password'"

    # Execute the playbook
    if eval "$ansible_cmd"; then
        echo ""
        print_success "Jenkins setup completed successfully!"
        echo ""
        print_info "Next steps:"
        echo "  1. Access Jenkins at: http://$device_ip:8080"
        echo "  2. Login with username: admin"
        echo "  3. Password: [the one you provided]"
        echo ""
        print_info "SSH access configured at: ssh -p $ssh_port $termux_user@$device_ip"
    else
        echo ""
        print_error "Setup failed. Check the output above for errors."
        print_info "Inventory backup saved at: ${inventory_file}.backup"
        exit 1
    fi
}

# Check if script is run from project root
if [[ ! -d "ansible/playbooks" ]]; then
    print_error "This script must be run from the project root directory"
    exit 1
fi

# Run main function
main
