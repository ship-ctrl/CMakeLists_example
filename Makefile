# Default target
.PHONY: all
all: glog update-glog

# Directory for glog
GLOG_DIR = glog
GLOG_BUILD_DIR = $(GLOG_DIR)/build

# Add and initialize glog as a submodule
.PHONY: glog-submodule
glog-submodule:
	@if [ ! -d "$(GLOG_DIR)/.git" ]; then \
		echo "Adding glog submodule..."; \
		git submodule add https://github.com/google/glog.git $(GLOG_DIR); \
		git submodule update --init --recursive; \
	else \
		echo "Glog submodule already exists"; \
	fi

# Update the submodule
.PHONY: update-glog
update-glog:
	git submodule update --remote --merge $(GLOG_DIR)
	cd $(GLOG_DIR) && git checkout master

# Build and install glog
.PHONY: glog
glog: glog-submodule
	@echo "Building and installing glog..."
	@mkdir -p $(GLOG_BUILD_DIR)
	cd $(GLOG_BUILD_DIR) && \
	cmake .. \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=/usr/local \
		-DBUILD_SHARED_LIBS=ON \
		-DWITH_GFLAGS=OFF \
		-DWITH_UNWIND=ON
	cd $(GLOG_BUILD_DIR) && $(MAKE) -j$(shell nproc 2>/dev/null || echo 4)
	cd $(GLOG_BUILD_DIR) && sudo $(MAKE) install

# Install glog to a custom directory
.PHONY: glog-local
glog-local: glog-submodule
	@echo "Building and installing glog to local directory..."
	@mkdir -p $(GLOG_BUILD_DIR)
	cd $(GLOG_BUILD_DIR) && \
	cmake .. \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX=$$(pwd)/install \
		-DBUILD_SHARED_LIBS=ON \
		-DWITH_GFLAGS=OFF \
		-DWITH_UNWIND=ON
	cd $(GLOG_BUILD_DIR) && $(MAKE) -j$(shell nproc 2>/dev/null || echo 4)
	cd $(GLOG_BUILD_DIR) && $(MAKE) install
	@echo "Glog installed to: $(GLOG_BUILD_DIR)/install"

# Clean build files
.PHONY: clean
clean:
	rm -rf $(GLOG_BUILD_DIR)

# Completely remove glog (including submodule)
.PHONY: distclean
distclean: clean
	-git submodule deinit -f $(GLOG_DIR)
	-git rm -f $(GLOG_DIR)
	rm -rf .git/modules/$(GLOG_DIR)
	rm -rf $(GLOG_DIR)

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all           - Default target, builds and installs glog (requires sudo)"
	@echo "  glog          - Build and install glog system-wide (requires sudo)"
	@echo "  glog-local    - Build and install glog to local directory (no sudo needed)"
	@echo "  glog-submodule - Only add glog as a git submodule"
	@echo "  update-glog   - Update glog to latest version"
	@echo "  clean         - Remove build files"
	@echo "  distclean     - Completely remove glog including submodule"
	@echo "  help          - Show this help message"