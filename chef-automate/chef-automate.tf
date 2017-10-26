resource "oci_core_instance" "chefVM-2" {
    availability_domain = "${data.oci_identity_availability_domains.chefAD.availability_domains.0.name}"
    compartment_id = "${var.compId}"
    display_name = "${var.vcnDisplayName}-automate${random_id.unq.hex}"
    image = "${lookup(data.oci_core_images.OLImageOCID.images[0], "id")}"
    shape = "${var.InstanceShape}"
    subnet_id = "${oci_core_subnet.chefsubnet1.id}"

create_vnic_details {
    subnet_id = "${oci_core_subnet.chefsubnet1.id}"
    display_name = "${var.nicName}"
    assign_public_ip = true
    private_ip = "10.0.0.4"
    hostname_label = "chef2${random_id.unq.hex}"
}
metadata {
   ssh_authorized_keys = "${var.sshKey}"
}
}
resource "null_resource" "remote-exec2" {
  depends_on = ["null_resource.remote-exec"]
   provisioner "remote-exec" {
     connection {
        agent = false
       timeout = "15m"
       host = "${data.oci_core_vnic.InstanceVnic-2.public_ip_address}"
       user = "ubuntu"
       private_key = "${(file(var.ssh_private_key))}"
     }
     inline = [
       "curl https://raw.githubusercontent.com/sysgain/oci-terraform-templates/oci-chef-automate/chef-automate/user-data/chefautomate.sh > chefautomate.sh",
       "chmod 777 chefautomate.sh",
       "cat chefautomate.sh | tr -d '\r' > newchef.sh",
       "chmod +x newchef.sh",
       "./newchef.sh"
    ]
   }
}
