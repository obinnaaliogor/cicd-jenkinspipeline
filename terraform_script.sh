#!/bin/bash

# File to store the Terraform plan
PLAN_FILE="terraform.plan"

# Check the command-line argument to determine action
case "$1" in
    "apply")
        echo "Running Terraform apply..."
        # Run Terraform commands to generate a plan and apply changes
        terraform init
        terraform plan -out="$PLAN_FILE"
        terraform apply -auto-approve "$PLAN_FILE"

        # Check if apply was successful
        if [ $? -eq 0 ]; then
            echo "Terraform apply successful. Cleaning up..."
            # Delete Terraform directories
            rm -rf .terraform terraform.tfstate* terraform.log
            # Delete the plan file
            rm -f "$PLAN_FILE"
            echo "Clean up complete."
        else
            echo "Terraform apply failed. No clean up performed."
        fi
        ;;

    "destroy")
        echo "Running Terraform destroy..."
        # Run Terraform commands to destroy the infrastructure
        terraform destroy -auto-approve
        # Delete Terraform directories
        rm -rf .terraform terraform.tfstate* terraform.log
        echo "Terraform destroy complete. Clean up done."
        ;;

    *)
        echo "Invalid command. Usage: $0 [apply|destroy]"
        exit 1
        ;;
esac
