
OS:=$(shell uname)
NODE:=$(shell uname -n)
USER:=$(shell whoami)
ifeq ($(OS),Linux)
  OS:=$(shell uname -o | sed 's/.*\///')
endif
ifeq ($(NODE),localhost)
  ifneq ($(HOSTNAME),)
    NODE:=$(HOSTNAME)
  else
    NODE:=$(shell getprop net.hostname 2>/dev/null)
  endif
endif
_USER=
ifneq ($(ROOT),1)
  ifneq ($(SUDO_USER),)
    HOME:=$(shell sudo su $(SUDO_USER) -c 'echo $$HOME')
    export HOME
    _USER=$(SUDO_USER)
  endif
endif
ifeq ($(_USER),)
  _USER=$(USER)
endif

MODULES_ALL:=$(sort $(shell ls */list* 2>/dev/null | sed 's/\/.*//'))
-include Scripts/$(OS).mk
-include Includes/$(NODE).mk
ifneq ($(IGNORES),)
  MODULES:=$(filter-out $(IGNORES),$(MODULES_ALL))
else
  MODULES=$(MODULES_ALL)
endif

$(foreach name,$(MODULES),$(eval $(name)_list=$(wildcard $(name)/list $(name)/list_$(OS) $(name)/list_$(NODE))))
$(foreach name,$(MODULES),$(eval $(name)_pre_backup=$(wildcard $(name)/pre_backup $(name)/pre_backup_$(OS) $(name)/pre_backup_$(NODE))))
$(foreach name,$(MODULES),$(eval $(name)_post_backup=$(wildcard $(name)/post_backup $(name)/post_backup_$(OS) $(name)/post_backup_$(NODE))))
$(foreach name,$(MODULES),$(eval $(name)_pre_restore=$(wildcard $(name)/pre_restore $(name)/pre_restore_$(OS) $(name)/pre_restore_$(NODE))))
$(foreach name,$(MODULES),$(eval $(name)_post_restore=$(wildcard $(name)/post_restore $(name)/post_restore_$(OS) $(name)/post_restore_$(NODE))))

BACKUP=$(addprefix backup_,$(MODULES))
RESTORE=$(addprefix restore_,$(MODULES))

ifeq ($(ROOT_DIR),)
  ROOT_DIR="/"
endif
export ROOT_DIR

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
		-H $(HOME) -b $* -r $(ROOT_DIR)\
		$(addprefix -l ,$($*_list)) \
		$(addprefix -P ,$($*_pre_backup)) \
		$(addprefix -p ,$($*_post_backup))

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
		-H $(HOME) -b $* -r $(ROOT_DIR)\
		$(addprefix -l ,$($*_list)) \
		$(addprefix -P ,$($*_pre_restore)) \
		$(addprefix -p ,$($*_post_restore))

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
	@echo "  Root: $(ROOT)"
	@echo "  User: $(_USER)"
	@echo "  Home: $(HOME)"
	@echo "  Root dir: $(ROOT_DIR)"
	@echo "  Modules(all): $(MODULES_ALL)"
	@echo "  Ignores: $(IGNORES)"
	@echo "  Modules: $(MODULES)"
	@echo "  Backup actions: backup $(BACKUP)"
	@echo "  Restore actions: restore $(RESTORE)"
