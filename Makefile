# Copyright 2023 ETH Zurich
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Alessandro Ottaviano <aottaviano@iis.ee.ethz.ch>

ETH_ROOT ?= $(shell pwd)

# Clean only simulation artifacts (keeps dependencies and Bender cache)
clean:
	@echo "Cleaning simulation artifacts..."
	rm -rf work
	rm -rf modelsim.ini
	rm -f transcript
	rm -f vsim.wlf
	rm -f *.wlf
	rm -f *.vstf
	rm -f wlft*
	rm -f *.log
	rm -rf .cr.mti
	@echo "✓ Simulation artifacts cleaned (dependencies preserved)"

# Deep clean: removes everything including Bender cache (keeps deps/ folder)
clean-deep:
	@echo "Deep cleaning (removes Bender cache but preserves deps/)..."
	rm -rf .bender
	rm -rf work
	rm -rf modelsim.ini
	rm -f transcript
	rm -f vsim.wlf
	rm -f *.wlf
	rm -f *.vstf
	rm -f wlft*
	rm -f *.log
	rm -rf .cr.mti
	@echo "✓ Deep clean complete (deps/ folder preserved)"

# Complete clean: removes EVERYTHING including downloaded dependencies
clean-all:
	@echo "⚠️  WARNING: This will remove ALL dependencies!"
	@echo "You will need to re-download 23MB of dependencies."
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		rm -rf .bender; \
		rm -rf deps; \
		rm -rf work; \
		rm -rf modelsim.ini; \
		rm -f transcript; \
		rm -f vsim.wlf; \
		rm -f *.wlf; \
		rm -f *.vstf; \
		rm -f wlft*; \
		rm -f *.log; \
		rm -rf .cr.mti; \
		rm -f Bender.lock; \
		echo "✓ Complete clean (all dependencies removed)"; \
	else \
		echo "✗ Clean cancelled"; \
	fi

include scripts/eth.mk
