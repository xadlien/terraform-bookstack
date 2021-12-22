terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "bookstack_network" {
    name = "bookstack_network"
}

resource "docker_image" "bookstack" {
    name = "linuxserver/bookstack:21.11.3"
    keep_locally = true
}

resource "docker_image" "mariadb" {
    name = "linuxserver/mariadb:10.5.13"
    keep_locally = true
}

resource "docker_container" "bookstack_mariadb" {
  image = docker_image.mariadb.latest
  name  = "bookstack_mariadb"
  networks_advanced {
    name = "bookstack_network"
  }
  volumes {
    volume_name = "bookstack_data"
    container_path = "/config"
  }
  env = [
      "PUID=1000",
      "PGID=1000",
      "MYSQL_ROOT_PASSWORD=myrootpassword",
      "TZ=AMERICA/NEW_YORK",
      "MYSQL_DATABASE=bookstackapp",
      "MYSQL_USER=bookstack",
      "MYSQL_PASSWORD=bookstackpass"
  ]
}

resource "docker_container" "bookstack" {
  image = docker_image.bookstack.latest
  name  = "bookstack"
  networks_advanced {
    name = "bookstack_network"
  }
  ports {
    internal = 80
    external = 8080
  }
  volumes {
    volume_name = "bookstack_data"
    container_path = "/config"
  }
  env = [
      "PUID=1000",
      "PGID=1000",
      "APP_URL=http://localhost:8080",
      "DB_HOST=bookstack_mariadb",
      "DB_USER=bookstack",
      "DB_DATABASE=bookstackapp",
      "DB_PASSWORD=bookstackpass"
  ]
}