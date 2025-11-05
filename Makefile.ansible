# Makefile.configs — WSL config management

ANSIBLE := uv run ansible-playbook
PLAYBOOK_DIR := playbooks
BACKUP_PLAYBOOK := $(PLAYBOOK_DIR)/backup-configs.yml
RESTORE_PLAYBOOK := $(PLAYBOOK_DIR)/restore-configs.yml

check_ansible:
	@uv run ansible --version >/dev/null 2>&1 || \
	( echo "Installing Ansible via uv..."; \
	uv tool install ansible )

backup: check_ansible
	@echo "🔹 Backing up existing config files into repo/files..."
	@$(ANSIBLE) $(BACKUP_PLAYBOOK)
	@echo "✅ Backup complete."

restore: check_ansible
	@echo "🔹 Restoring configs from repo to local filesystem..."
	@$(ANSIBLE) $(RESTORE_PLAYBOOK)
	@echo "✅ Restore complete."

.PHONY: backup restore check_ansible

