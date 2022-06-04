#################################################
# Script execution Output
#################################################
output "script_execution_output" {
  value = "${path.module}/${var.executor_role}-deployment-script.out"
}
