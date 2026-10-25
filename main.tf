terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
}



resource "libvirt_volume" "example" {
  name     = "example.qcow2"
  pool     = "default"
  capacity = 10737418240 # 10 GB
  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Basic VM configuration
resource "libvirt_domain" "example" {
  name        = "example-vm"
  memory      = 2048
  memory_unit = "MiB"
  vcpu        = 2
  type        = "kvm"
  depends_on  = [libvirt_volume.example]
  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"

    boot_devices = [
      {
        dev = "cdrom"
      },
      {
        dev = "hd"
      }
    ]
  }

  devices = {
    graphics = [
      {
        vnc = {
          auto_port = true
        }
      }
    ]
    disks = [
      {
        source = {
          file = {
            file = libvirt_volume.example.target.path
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      },

      {
        source = {
          file = {
            file = var.os_images_path
          }
        }
        device = "cdrom"
        target = {
          dev = "sda"
          bus = "sata"
        }
        readonly = true
      }
    ]
    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "default"
          }
        }
      }
    ]
  }
}


