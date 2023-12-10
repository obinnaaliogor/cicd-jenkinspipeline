#!/bin/bash
set -x
# packer init
packer init .
# Validate Packer Template
packer validate template.pkr.hcl

# Build Image
#packer build -var-file=variables.json template.pkr.hcl

# Inspect Image Configuration
packer inspect template.pkr.hcl

# List Builders
packer inspect template.pkr.hcl

# Fix Template Formatting
packer fmt template.pkr.hcl

# Display Packer Version
packer version
packer build .