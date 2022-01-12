data "template_file" "userdata" {
  template = file("templates/userdata.sh")

  vars = {
    wp_db_hostname      = aws_db_instance.rds.endpoint
    wp_db_name          = "${terraform.workspace}${local.rds_db_name}"
    wp_db_user          = var.rds_username
    wp_db_password      = var.rds_password
    playbook_repository = var.playbook_repository
  }
}