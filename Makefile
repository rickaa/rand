# https://tech.davis-hansson.com/p/make/
ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := build

build:
> bash local_build.sh
.PHONY: build

comp:
> find rand/static/img/social \
> \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' \) -print0 \
> | xargs -0 -P8 -n2 \
> mogrify -strip \
> -thumbnail '1000>' \
> -format jpg
.PHONY: comp
