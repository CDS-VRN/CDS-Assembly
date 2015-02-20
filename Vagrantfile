# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	config.vm.define "docker", autostart: false do |docker|
		docker.vm.box = "ubuntu/precise64"
		
		# Provision using a shellscript:
		docker.vm.provision :shell, path: "docker-daemon.sh"
		
		# This line ensures Docker daemon will get installed on the VM.
		docker.vm.provision "docker" do |d|
		end

		# Forward the Docker daemon port:		
		docker.vm.network :forwarded_port, host: 2375, guest: 2375
		
		# Provision virtualbox:
		docker.vm.provider "virtualbox" do |vb|
			# Use VBoxManage to customize the VM. For example to change memory:
			vb.customize ["modifyvm", :id, "--memory", "2048"]
		end
	end

	config.vm.define "db", autostart: false do |db|
		db.vm.box = "ubuntu/precise64"
		
		# Provision using a shellscript:
		db.vm.provision :shell, path: "vagrant-db.sh"
		
		# Expose the PostgreSQL and LDAP ports:
		db.vm.network :forwarded_port, host: 5432, guest: 5432
		config.vm.network :forwarded_port, host: 1389, guest: 1389
		
		# Provision virtualbox:
		db.vm.provider "virtualbox" do |vb|
			vb.customize ["modifyvm", :id, "--memory", "1024"]
		end
	end
	
end
