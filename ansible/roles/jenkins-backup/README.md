# Ansible Role: jenkins-backup

Backup Jenkins configuration, job definitions, and optionally build history for disaster recovery and migration purposes.

## Description

This role provides comprehensive backup capabilities for Jenkins instances running on Termux (or any Linux system). It backs up job definitions, JCasC configuration, installed plugins list, and optionally build history and artifacts.

## Requirements

- Ansible 2.10 or higher
- Access to Jenkins instance via SSH
- Sufficient local disk space for backup

## Role Variables

### Jenkins Configuration

```yaml
jenkins_home: /data/data/com.termux/files/home/.jenkins  # Jenkins home directory
jenkins_port: 8080                                         # Jenkins web port
jenkins_url: "http://localhost:{{ jenkins_port }}"        # Jenkins URL
```

### Backup Destination

```yaml
backup_destination: "./backups/jenkins-{{ ansible_date_time.iso8601_basic_short }}"
# Default: ./backups/jenkins-YYYYMMDD_HHMMSS
```

### What to Backup

```yaml
backup_job_definitions: true   # Job config.xml files
backup_jcasc_config: true      # JCasC configuration
backup_plugins_list: true      # List of installed plugins
backup_build_history: false    # Build logs and artifacts (can be large!)
backup_credentials: false      # Credentials (security risk if not encrypted)
```

### Archive Options

```yaml
create_tarball: true           # Create compressed backup archive
tarball_compression: gz         # gz, bz2, or xz
keep_uncompressed: false       # Keep uncompressed files after creating tarball
```

### Jenkins Credentials (for API access)

```yaml
jenkins_admin_user: admin
jenkins_admin_password: "{{ lookup('env', 'JENKINS_ADMIN_PASSWORD') | default('admin') }}"
```

## Dependencies

**Optional but recommended:**
- **rsync** on target system - Significantly improves backup performance with efficient file synchronization
  - Automatically used if available
  - Falls back to standard Ansible fetch if not installed
  - Installed by default when using `termux-complete-setup` role

## Example Playbook

### Basic Usage

```yaml
---
- name: Backup Jenkins Configuration
  hosts: termux_controller
  roles:
    - role: jenkins-backup
```

### Custom Configuration

```yaml
---
- name: Backup Jenkins with Build History
  hosts: termux_controller
  roles:
    - role: jenkins-backup
      vars:
        backup_destination: /backup/jenkins-{{ ansible_date_time.date }}
        backup_build_history: true
        create_tarball: true
        tarball_compression: xz
```

### Quick Backup Script

Use the provided playbook:

```bash
ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/backup-jenkins.yaml
```

## Backup Contents

After running the backup, you'll have:

```
backups/jenkins-YYYYMMDD_HHMMSS/
├── jobs/                          # Job definitions
│   └── <job-name>/
│       └── config.xml
├── jenkins.yaml                   # JCasC configuration
├── plugins.txt                    # List of installed plugins
├── BACKUP_INFO.txt                # Backup metadata
└── JOB_LIST.txt                   # List of backed up jobs
```

If `create_tarball: true`, the directory is compressed to:
```
backups/jenkins-YYYYMMDD_HHMMSS.tar.gz
```

## Restoring from Backup

### Manual Restore

1. **Extract backup** (if compressed):
   ```bash
   tar -xzf backups/jenkins-YYYYMMDD_HHMMSS.tar.gz
   ```

2. **Copy job configurations**:
   ```bash
   cp -r backups/jenkins-*/jobs/* $JENKINS_HOME/jobs/
   ```

3. **Copy JCasC configuration**:
   ```bash
   cp backups/jenkins-*/jenkins.yaml $JENKINS_HOME/
   ```

4. **Restart Jenkins**:
   ```bash
   # On Termux
   pkill -f jenkins.war
   java -jar ~/jenkins.war &
   ```

### Automated Restore (Future Enhancement)

A companion `jenkins-restore` role is planned for automated restoration.

## Use Cases

### Before System Wipe

```bash
# Backup before wiping phone for fresh installation testing
ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/backup-jenkins.yaml
```

### Regular Backups

Add to cron or scheduled task:

```bash
0 2 * * * cd /path/to/automation && ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/backup-jenkins.yaml
```

### Migration to New Device

1. Backup on old device
2. Transfer backup file to control machine
3. Install Jenkins on new device
4. Restore backup to new device

## Troubleshooting

### Backup Directory Already Exists

Each backup is timestamped, so this shouldn't happen. If it does, backups are organized by date/time automatically.

### Large Backup Size

If backups are too large:
- Set `backup_build_history: false` (build logs can be very large)
- Set `backup_credentials: false` (not backed up by default)
- Use `tarball_compression: xz` for better compression

### JCasC Not Found

The role tries two methods:
1. Direct file copy from `$JENKINS_HOME/jenkins.yaml`
2. API export from `/configuration-as-code/export`

If both fail, you'll need to manually backup your JCasC configuration from the repository's `jcasc/jenkins.yaml` file.

### Permissions Issues

Ensure:
- SSH user has read access to `$JENKINS_HOME`
- Local user has write access to backup destination
- Use `become: false` in playbook (Termux doesn't use sudo)

## Security Considerations

### Credentials

By default, `backup_credentials: false` for security. Jenkins credentials contain sensitive data and should only be backed up to encrypted storage.

If you must backup credentials:
```yaml
backup_credentials: true
```

Then encrypt the backup:
```bash
gpg --encrypt --recipient your-email@example.com backups/jenkins-*.tar.gz
```

### Sensitive Data

Job configurations may contain:
- API keys
- Passwords
- Private repository URLs

Store backups securely and limit access.

## Performance

### Backup Duration

- **Job definitions only**: 10-30 seconds
- **With JCasC and plugins list**: 30-60 seconds
- **With build history**: Several minutes (depends on history size)

### Storage Requirements

| Content | Typical Size |
|---------|--------------|
| Job definitions | 1-10 MB |
| JCasC config | < 1 MB |
| Plugins list | < 1 MB |
| Build history | 100+ MB (varies widely) |

## Related Roles

- `jenkins-controller` - Install Jenkins
- `jenkins-jcasc` - Configure Jenkins with JCasC
- `jenkins-agent` - Configure Jenkins agents

## Author

CloudNord Jenkins Automation Project

## License

Apache License 2.0

## See Also

- [Issue #13](https://github.com/gounthar/termux-jenkins-automation/issues/13) - Original feature request
- [Jenkins Backup Best Practices](https://www.jenkins.io/doc/book/system-administration/backing-up/)
