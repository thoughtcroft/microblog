Vagrant.configure("2") do |config|
  config.env.enable
  config.vm.box = "microblog/ubuntu"
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider "virtualbox" do |vb|
    vb.name = 'microblog'
    vb.memory = "1024"
  end

  $user = "ubuntu"

  config.vm.provision "file", source: "microblog_rsa.pub", destination: "/tmp/my_public_key"
  config.vm.provision "file", source: ".env", destination: "/tmp/.env"
  config.vm.provision "shell", path: "scripts/create_user.sh", args: [$user, "/tmp/my_public_key"]
  config.vm.provision "shell", path: "scripts/install_deps.sh"
  config.vm.provision "shell", path: "scripts/install_db.sh"
  config.vm.provision "file", source: "scripts/install_app.sh", destination: "/tmp/install_app.sh"
  config.vm.provision "shell", inline: "sudo su - #{$user} -c '/bin/bash /tmp/install_app.sh #{$user}'"
  config.vm.provision "shell", path: "scripts/secure_server.sh"
end
