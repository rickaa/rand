# https://tech.davis-hansson.com/p/make/
# ask make to use > as the block character instead of tabs
ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

# bash as default shell
SHELL := bash

#  bash strict mode
.SHELLFLAGS := -eu -o pipefail -c

# ensures each Make recipe is ran as one single shell session, rather than one new shell per line
.ONESHELL:

# if a Make rule fails, it's target file is deleted
.DELETE_ON_ERROR:

# if you are referring to Make variables that don't exist, that's probably wrong and it's good to get a warning
MAKEFLAGS += --warn-undefined-variables

# disables the bewildering array of built in rules to automatically build Yacc grammars out of your data
# if you accidentally add the wrong file suffix. Remove magic, don't do things unless I tell you to
MAKEFLAGS += --no-builtin-rules

.DEFAULT_GOAL := build

build:
> bash local_build.sh
.PHONY: build
