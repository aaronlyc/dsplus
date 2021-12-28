PACKAGE=github.com/aaronlyc/dsplus
CURRENT_DIR=$(shell pwd)
DIST_DIR=${CURRENT_DIR}/dist
PATH := $(DIST_DIR):$(PATH)
TEST_TARGET ?= ./...

BUILD_DATE=$(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
GIT_COMMIT=$(shell git rev-parse HEAD)
GIT_TAG=$(shell if [ -z "`git status --porcelain`" ]; then git describe --exact-match --tags HEAD 2>/dev/null; fi)
GIT_TREE_STATE=$(shell if [ -z "`git status --porcelain`" ]; then echo "clean" ; else echo "dirty"; fi)
GIT_REMOTE_REPO=upstream
VERSION=$(shell if [ ! -z "${GIT_TAG}" ] ; then echo "${GIT_TAG}" | sed -e "s/^v//"  ; else cat VERSION ; fi)

override LDFLAGS += \
  -X ${PACKAGE}/utils/version.version=${VERSION} \
  -X ${PACKAGE}/utils/version.buildDate=${BUILD_DATE} \
  -X ${PACKAGE}/utils/version.gitCommit=${GIT_COMMIT} \
  -X ${PACKAGE}/utils/version.gitTreeState=${GIT_TREE_STATE}

ifneq (${GIT_TAG},)
IMAGE_TAG=${GIT_TAG}
override LDFLAGS += -X ${PACKAGE}.gitTag=${GIT_TAG}
endif

.PHONY: all
all: help

HELP_FUN = \
    %help; \
    while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
    print "usage: make [target]\n\n"; \
    for (sort keys %help) { \
    print "${WHITE}$$_:${RESET}\n"; \
    for (@{$$help{$$_}}) { \
    $$sep = " " x (32 - length $$_->[0]); \
    print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
    }; \
    print "\n"; }

help: ##@other Show this help.
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

.PHONY: controller
controller: ## build the controller.
	CGO_ENABLED=0 go build -v -ldflags '${LDFLAGS}' -o ${DIST_DIR}/dsplus-controller ./cmd/dsplus-controller