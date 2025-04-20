.PHONY: setup run clean help all

# Default Python executable
PYTHON := python3
OUTPUT_DIR := kindercare_media
DATE_RANGE := 
CHILD_ID :=
MEDIA_TYPE := all
COOKIES := ./cookies.txt
CHILD_ID := 589168

help:
	@echo "KinderCare Media Downloader Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make setup         Install required dependencies"
	@echo "  make run           Run the downloader with default settings"
	@echo "  make help          Show this help message"
	@echo ""
setup:
	brew install wget jq exiftool imagemagick ffmpeg

run:
	bash kindercare_downloader.sh -k ${CHILD_ID}

all: setup run