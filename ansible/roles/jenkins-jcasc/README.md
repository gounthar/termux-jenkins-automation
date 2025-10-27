# jenkins-jcasc Role

Applies Jenkins Configuration as Code (JCasC) to configure Jenkins declaratively using YAML.

## What This Role Configures

- Security realm (admin user with password)
- Authorization strategy (logged-in users)
- Agent nodes (SSH connection to Termux agent)
- Credentials (SSH keys for agent authentication)
- Tool installations (Git, JDK paths)
- System settings (location URL, global libraries)

## What This Role Does NOT Configure

**Jobs are NOT managed via JCasC.** Jenkins Configuration as Code does not support job definitions in YAML format.

## Job Management Workflow

### Creating Jobs

Jobs should be created through one of these methods:

1. **Jenkins Web UI**: Manually create jobs through the UI
2. **Jenkins CLI**: Use `jenkins-cli.jar` to create jobs from XML
3. **Job DSL Plugin**: Use Groovy scripts to generate jobs (requires separate setup)

### Backing Up Jobs

After creating jobs, back them up using the `jenkins-backup` role:

```bash
ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/backup-jenkins.yaml
```

This creates a tarball in `ansible/playbooks/backups/` containing:
- Job configurations (`jobs/*/config.xml`)
- Build history (optional)
- Installed plugins list
- JCasC configuration

### Restoring Jobs

To restore jobs on a new Jenkins instance:

```bash
# Extract job configs from backup tarball
tar -xzf ansible/playbooks/backups/jenkins-TIMESTAMP.tar.gz \
    --strip-components=1 -C ~/.jenkins/jobs/ jenkins-TIMESTAMP/jobs/

# Reload Jenkins configuration
curl -X POST http://localhost:8080/reload
```

Or use the `jenkins-backup` role's restore functionality (if implemented).

## Role Variables

See `defaults/main.yaml` for configurable variables:

- `jenkins_admin_user`: Admin username (default: "admin")
- `jenkins_admin_password`: Admin password
- `agent_name`: Name of the Termux agent
- `agent_labels`: Labels for agent selection
- `agent_home`: Agent workspace directory
- `agent_ssh_key`: Path to SSH private key for agent auth

## Dependencies

Requires:
- `jenkins-controller` role (Jenkins installed and running)
- `jenkins-agent` role (SSH agent configured)
- `configuration-as-code` plugin (installed via Phase 4)

## Example Playbook

```yaml
- hosts: termux_controller
  roles:
    - role: jenkins-jcasc
      vars:
        jenkins_admin_password: "secure-password-here"
```

## Notes

- The JCasC configuration is deployed to `~/.jenkins/jenkins.yaml`
- Environment variable `CASC_JENKINS_CONFIG` must point to this file
- Configuration is applied on Jenkins startup
- To reload configuration without restart: `curl -X POST http://localhost:8080/reload`
- **Plugin installation requires manual Jenkins restart on Termux** (no libc support for safe-restart)

## Troubleshooting

**JCasC not applying on startup:**
- Check `CASC_JENKINS_CONFIG` environment variable is set in service script
- Verify `~/.jenkins/jenkins.yaml` exists and has correct permissions
- Check Jenkins logs for JCasC errors: `~/.jenkins/logs/jenkins.log`

**Agent not connecting:**
- Verify SSH key exists: `~/.jenkins/ssh/id_ed25519`
- Test SSH connection: `ssh -i ~/.jenkins/ssh/id_ed25519 -p 8022 u0_a504@localhost`
- Check agent is online in Jenkins UI: Manage Jenkins > Nodes

**Jobs missing after applying JCasC:**
- Jobs are not managed by JCasC - they must be created separately
- Restore jobs from backup tarball if needed
