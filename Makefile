# Makefile

TEMP_DIR         = .tmp
PYTHON           = python3
PYTHON_VENV      = ${TEMP_DIR}/venv
BIN_DIR          = bin
ROLE_NAME        = $(shell sed -n 's/^ *role_name: *//p' meta/main.yml)
## Colors
PURPLE           = \033[1;35m
RESET            = \033[0m

.DEFAULT_GOAL := help

.PHONY: help
help:              ## Show this help
	@printf '%b\n' "Usage: make ${PURPLE}<target>${RESET}\n\nTargets:"
	@grep -hE '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) \
		| awk -v c='${PURPLE}' -v r='${RESET}' 'BEGIN {FS = ":.*## "} {printf "  %s%-10s%s %s\n", c, $$1, r, $$2}'

.PHONY: doc
doc: clean         ## Generate README.md from docs/ and defaults/vars comments
doc:
	## Manage defaults/main.yml Markdown content
	@printf '%b\n' "${PURPLE}Remove any previous file.${RESET}"
	@rm --force -- docs/10.defaults_main.md
	@printf '%b\n' "${PURPLE}Transform the file to Markdown.${RESET}"
	@"${BIN_DIR}/yaml2md.sh" --input defaults/main.yml --dest docs/
	@printf '%b\n' "${PURPLE}Add '10.' prefix to generated Markdown file.${RESET}"
	@mv -- docs/defaults_main.md docs/10.defaults_main.md

	## Manage vars/*.yml Markdown content if exists
	@printf '%b\n' "${PURPLE}Remove any previous file.${RESET}"
	@find docs/ -name "15.vars_*.md" -delete
	@printf '%b\n' "${PURPLE}Transform the file(s) to Markdown.${RESET}"
	@"${BIN_DIR}/yaml2md.sh" --input vars/ --ignore-empty-directory --dest docs/
	@printf '%b\n' "${PURPLE}Add '15.' prefix to vars_* md file(s).${RESET}"
	@cd docs && \
		find * -maxdepth 0 -type f -name "vars_*.md" -exec mv -- {} 15.{} \;

	## Manage the table of contents
	@$(MAKE) --no-print-directory toc

	## Manage README.md
	@printf '%b\n' "${PURPLE}Remove any previous file.${RESET}"
	@rm --force -- README.md
	@printf '%b\n' "${PURPLE}Build README.md from docs/*.md files.${RESET}"
	@cat -- docs/*.*.md > README.md

.PHONY: toc
toc:               ## Generate docs/00.toc.md from the headings of docs/*.md
	@printf '%b\n' "${PURPLE}Generate docs/00.toc.md.${RESET}"
	@"${BIN_DIR}/mdtoc.sh" --title "${ROLE_NAME}" --dest docs/00.toc.md docs/*.*.md

.PHONY: lint
lint:              ## Check files using linters (ansible-lint + yamllint), from Python venv
lint: test-ansible-lint
lint: test-yamllint

.PHONY: ansible
ansible:           ## Check files using ansible-lint only, from Python venv
ansible: test-ansible-lint

.PHONY: yaml

yaml:              ## Check files using yamllint only, from Python venv
yaml: test-yamllint

.PHONY: yml
yml:               ## Alias of yaml
yml: test-yamllint

.PHONY: clean
clean:             ## Remove temp directory (.tmp)
	@rm --force --recursive -- "${TEMP_DIR}"

.PHONY: test-ansible-lint
test-ansible-lint: venv
test-ansible-lint:
	@printf "%b\n" "${PURPLE}Checking Ansible content using ansible-lint...${RESET}"
	@${PYTHON_VENV}/bin/ansible-lint -v

.PHONY: test-yamllint
test-yamllint: venv
test-yamllint:
	@printf "%b\n" "${PURPLE}Checking YAML syntax using yamllint...${RESET}"
	@${PYTHON_VENV}/bin/yamllint .

.PHONY: venv
venv:
	## Manage Python VirtualEnv and required tools
	@mkdir --parents "${TEMP_DIR}"
	${PYTHON} -m venv "${PYTHON_VENV}"
	. "${PYTHON_VENV}/bin/activate" && \
	${PYTHON} -m pip install --quiet ansible-lint yamllint
