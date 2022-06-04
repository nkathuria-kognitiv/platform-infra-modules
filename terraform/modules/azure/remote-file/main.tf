locals {
  remote_script_location = "/tmp/${var.executor_role}-deployment/deployment-script"

}

#################################################
# Copy and Execute file remotely
#################################################
resource "null_resource" "copy_and_execute_file" {

  depends_on = [var.wait_handle]

  count = var.execute_file == true ? 1 : 0

  # define ssh connection detail
  connection {
    type        = "ssh"
    host        = var.remote_host
    user        = var.ssh_user
    private_key = var.private_key
  }

  # trigger only if there is a change
  triggers = {
    always_run = timestamp()
  }

  # copy script to the remote server
  provisioner "file" {
    source      = var.file_path
    destination = local.remote_script_location
  }

  # change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.remote_script_location}",
      "${local.remote_script_location} ${var.file_args} 2>&1 | tee ${local.remote_script_location}.out",
    ]
  }
}

#################################################
# Copy file to Remote
#################################################
resource "null_resource" "copy_file" {

  depends_on = [var.wait_handle]

  count = var.execute_file == false ? 1 : 0

  # define ssh connection detail
  connection {
    type        = "ssh"
    host        = var.remote_host
    user        = var.ssh_user
    private_key = var.private_key
  }

  # trigger only if there is a change
  triggers = {
    always_run = timestamp()
  }

  # copy script to the remote server
  provisioner "file" {
    source      = var.file_path
    destination = local.remote_script_location
  }
}
