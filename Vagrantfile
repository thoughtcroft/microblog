Vagrant.configure("2") do |config|
  config.env.enable
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider "virtualbox" do |vb|
    vb.name = 'microblog'
    vb.memory = "1024"
  end

  config.vm.provision "file", source: "microblog_rsa.pub", destination: "/tmp/my_public_key"
  config.vm.provision "file", source: ".env", destination: "/tmp/.env"
  config.vm.provision "shell", path: "scripts/create_user.sh", args: ["/tmp/my_public_key"]
  config.vm.provision "shell", path: "scripts/install_deps.sh"
  config.vm.provision "shell", path: "scripts/install_db.sh"
  config.vm.provision "file", source: "scripts/install_app.sh", destination: "/tmp/install_app.sh"
  config.vm.provision "shell", inline: "sudo su - ubuntu -c '/bin/bash /tmp/install_app.sh'"
  config.vm.provision "shell", path: "scripts/secure_server.sh"
  config.vm.provision "shell", path: "scripts/run_bg_workers.sh"
  config.vm.provision "shell", path: "scripts/run_web_workers.sh"
  config.vm.provision "shell", path: "scripts/run_nginx.sh"
end
