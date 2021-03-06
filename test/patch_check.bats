#!/usr/bin/bats -t
# Copyright (c) 2018 SUSE LLC. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load helpers

@test "zypper-docker patch-check" {
  zypperdocker pchk $TESTIMAGE:$TAG
  [ "$status" -eq 0 ]

  zypperdocker pchk alpine:latest
  [ "$status" -eq 127 ]
  [[ "${lines[0]}" =~ "/bin/sh: zypper: not found" ]]
}

@test "zypper-docker patch-check-container" {
  # run a container
  run_container
  zypperdocker pchkc --base $CONTAINER_ID
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Base image $IMAGE_ID of container $CONTAINER_ID will be analyzed. Manually installed packages won't be taken into account."+ ]]

  zypperdocker pchkc $CONTAINER_ID
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Checking running container"+ ]]

  # stop the container
  stop_container
  zypperdocker pchkc $CONTAINER_ID
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Checking stopped container"+ ]]

  zypperdocker pchkc blahblub
  [ "$status" -eq 1 ]
  [[ "$output" =~ "container blahblub does not exist"+ ]]

  # remove the container before exiting
  remove_container
}
