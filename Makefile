SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

ANSIBLE_STRATEGY_PLUGINS := ../mitogen/ansible_mitogen/plugins/strategy
ANSIBLE_STRATEGY         := mitogen_linear

export

.PHONY: all apply

all: apply

apply: $(SELF)/main.yml
	cd $(SELF)/ && ansible-playbook -vv $<

.PHONY: equinix

equinix: $(SELF)/inventory/equinix.ini $(SELF)/main.yml
	cd $(SELF)/ && ansible-playbook -vv -i $^
