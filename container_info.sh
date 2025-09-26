#!/bin/sh
# busybox - ash

# Container information is only output if no command line parameters are passed.
echo ""
# CONTAINER_INFORMATION will export by Dockerfile
echo "${CONTAINER_INFORMATION}"
echo ""
