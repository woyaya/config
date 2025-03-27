
OS:=$(shell uname)
NODE:=$(shell uname -n)
USER:=$(shell whoami)
IGNORE_LIST="Scripts"

_USER=
ifneq ($(ROOT),1)
  ifneq ($(SUDO_USER),)
    HOME:=$(shell sudo su $(SUDO_USER) sh -c 'echo $$HOME')
    export HOME
    _USER=$(SUDO_USER)
  endif
endif
ifeq ($(_USER),)
  _USER=$(USER)
endif

-include Scripts/$(OS).mk
ifeq ($(ROOT_DIR),)
  ROOT_DIR="/"
endif
export ROOT_DIR

MODULES:=$(shell ls */list 2>/dev/null | sed 's/\/.*//')

BACKUP=$(addprefix backup_,$(MODULES))
RESTORE=$(addprefix restore_,$(MODULES))

.PHONY: backup $(BACKUP)
backup : $(BACKUP)
$(BACKUP) : backup_% :
	@echo "Making $@"
	@export OS=$(OS);\
	set -a;\
	[ -f $*/config ] && . $*/config;\
	[ -f $*/config_$(OS) ] && . $*/config_$(OS);\
	set +a;\
	Scripts/Sync.sh \
		-H $(HOME) -l $*/list -b $* -r $(ROOT_DIR)\
		-P $*/pre_backup.sh  -P $*/pre_backup_$(OS).sh  -P $*/pre_backup_$(NODE).sh \
		-p $*/post_backup.sh -p $*/post_backup_$(OS).sh -p $*/post_backup_$(NODE).sh

.PHONY: restore $(RESTORE)
restore : $(RESTORE)
$(RESTORE) : restore_% :
	@echo "Making $@"
	@export OS=$(OS);\
	set -a;\
	[ -f $*/config ] && . $*/config;\
	[ -f $*/config_$(OS) ] && . $*/config_$(OS);\
	set +a;\
	Scripts/Sync.sh -R\
		-H $(HOME) -l $*/list -b $* -r $(ROOT_DIR)\
		-P $*/pre_restore.sh  -P $*/pre_restore_$(OS).sh  -P $*/pre_restore_$(NODE).sh \
		-p $*/post_restore.sh -p $*/post_restore_$(OS).sh -p $*/post_restore_$(NODE).sh

.PHONY: help
help:
	@echo "Usage:"
	@echo "  Run as normal user:"
	@echo "    [sudo] [LOG_LEVEL=N] make"
	@echo "  Run as root:"
	@echo "    sudo ROOT=1 [LOG_LEVEL=N] make"
	@echo ""
	@echo "Variables:"
	@echo "  OS: $(OS)"
	@echo "  NODE: $(NODE)"
	@echo "  ROOT: $(ROOT)"
	@echo "  User: $(_USER)"
	@echo "  Home: $(HOME)"
	@echo "  Root dir: $(ROOT_DIR)"
	@echo "  Modules: $(MODULES)"
	@echo "  Backup actions: backup $(BACKUP)"
	@echo "  Restore actions: restore $(RESTORE)"
