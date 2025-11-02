#!/usr/bin/env sh

#
# Copyright 2015 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# @author: Andres Almiray
#

#
# This script is a simple wrapper around the gradle executable.
#
# It looks for the gradle executable in the following places:
#
#   1. in the GRADLE_HOME environment variable
#   2. in the current path
#   3. in the user's home directory in the .gradle/wrapper/dists
#      directory, with a fallback to the global installation
#

# Set the GRADLE_HOME environment variable to the location of your Gradle installation
if [ -z "$GRADLE_HOME" ]; then
    # If not set, try to determine it
    if [ -d "$HOME/.gradle/wrapper/dists" ]; then
        # Look for the latest version in the dists directory
        GRADLE_HOME=$(find "$HOME/.gradle/wrapper/dists" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n 1)
    fi
fi

# If we still don't have a GRADLE_HOME, we can't continue
if [ -z "$GRADLE_HOME" ]; then
    echo "GRADLE_HOME is not set and could not be determined."
    exit 1
fi

# Add the gradle executable to the path
export PATH="$GRADLE_HOME/bin:$PATH"

# Execute gradle
exec gradle "$@"
