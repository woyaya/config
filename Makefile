
OS:=$(shell uname)
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

MODULES:=$(shell ls */.list 2>/dev/null | sed 's/\/.*//')

BACKUP=$(addprefix backup_,$(MODULES))
RESTORE=$(addprefix restore_,$(MODULES))

.PHONY: backup $(BACKUP)
backup : $(BACKUP)
$(BACKUP) : backup_% :
	@export OS=$(OS);\
	set -a;\
	[ -f Scripts/$(OS).mk ] && . Scripts/$(OS).mk;\
	[ -f $*/.config ] && . $*/.config;\
	[ -f $*/.config_$(OS) ] && . $*/.config_$(OS);\
	set +a;\
	Scripts/Sync.sh \
		-H $(HOME) -l $*/.list -b $* -r $(ROOT_DIR)\
		-P $*/.prebackup.sh -P $*/.prebackup_$(OS).sh \
		-p $*/.postbackup.sh -p $*/.postbackup_$(OS).sh

.PHONY: restore $(RESTORE)
restore : $(RESTORE)
$(RESTORE) : restore_% :
	@export OS=$(OS);\
	set -a;\
	[ -f $*/.config ] && . $*/.config;\
	[ -f $*/.config_$(OS) ] && . $*/.config_$(OS);\
	set +a;\
	Scripts/Sync.sh -R\
		-H $(HOME) -l $*/.list -b $* -r $(ROOT_DIR)\
		-P $*/.prerestore.sh -P $*/.prerestore_$(OS).sh \
		-p $*/.postrestore.sh -p $*/.postrestore_$(OS).sh

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
	@echo "  ROOT: $(ROOT)"
	@echo "  User: $(_USER)"
	@echo "  Home: $(HOME)"
	@echo "  Root dir: $(ROOT_DIR)"
	@echo "  Modules: $(MODULES)"
	@echo "  Backup actions: backup $(BACKUP)"
	@echo "  Restore actions: restore $(RESTORE)"
