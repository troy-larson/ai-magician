source "digitalocean" "docker_image" {
  api_token     = var.do_api_token
  image         = var.image
  region        = var.region
  size          = var.droplet_size
  ssh_username  = var.ssh_username
  snapshot_name = "build-your-ow-ai-assistant-{{timestamp}}"
}

build {
  name    = "docker-setup-image"
  sources = ["source.digitalocean.docker_image"]

  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "/root/setup.sh"
  }

  provisioner "file" {
    source      = "scripts/bootstrap.sh"
    destination = "/root/bootstrap.sh"
  }

  provisioner "shell" {
    inline = [
      "bash /root/bootstrap.sh"
    ]
  }
}