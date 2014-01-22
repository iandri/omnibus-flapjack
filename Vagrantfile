# -*- mode: ruby -*-
# vi: set ft=ruby :

require "vagrant"

if Vagrant::VERSION < "1.2.1"
  raise "The Omnibus Build Lab is only compatible with Vagrant 1.2.1+"
end

host_project_path  = File.expand_path("..", __FILE__)
project_name       = "flapjack"

aws_access_key_id        = ENV['AWS_ACCESS_KEY_ID']
aws_secret_access_key    = ENV['AWS_SECRET_ACCESS_KEY']
aws_ssh_private_key_path = ENV['AWS_SSH_PRIVATE_KEY_PATH']
remote_user              = ENV['VAGRANT_REMOTE_USER'] || 'vagrant'

Vagrant.configure("2") do |config|

  config.vm.hostname = "#{project_name}-omnibus-build-lab"

  config.vm.define 'aws-ubuntu-precise64' do |c|
    c.berkshelf.berksfile_path = "./Berksfile"
    c.vm.box = "aws-dummy"
    c.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  end

  config.vm.define 'ubuntu-10.04' do |c|
    c.berkshelf.berksfile_path = "./Berksfile"
    c.vm.box = "opscode-ubuntu-10.04"
    c.vm.box_url = "http://opscode-vm.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_chef-11.2.0.box"
  end

  config.vm.define 'ubuntu-11.04' do |c|
    c.berkshelf.berksfile_path = "./Berksfile"
    c.vm.box = "opscode-ubuntu-11.04"
    c.vm.box_url = "http://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-11.04.box"
  end

  config.vm.define 'ubuntu-precise64', primary: true do |c|
    c.berkshelf.berksfile_path = "./Berksfile"
    c.vm.box = "precise64"
    c.vm.box_url = "http://files.vagrantup.com/precise64.box"
  end

  config.vm.define 'ubuntu-12.04' do |c|
    c.berkshelf.berksfile_path = "./Berksfile"
    c.vm.box = "canonical-ubuntu-12.04"
    c.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"
  end

  config.vm.define 'centos-5' do |c|
    c.berkshelf.berksfile_path = "./Berksfile"
    c.vm.box = "opscode-centos-5.8"
    c.vm.box_url = "http://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-5.8_chef-11.2.0.box"
  end

  config.vm.define 'centos-6' do |c|
    c.berkshelf.berksfile_path = "./Berksfile"
    c.vm.box = "opscode-centos-6.3"
    c.vm.box_url = "http://opscode-vm.s3.amazonaws.com/vagrant/opscode_centos-6.3_chef-11.2.0.box"
  end

  config.vm.define 'centos-6.5' do |c|
    c.berkshelf.berksfile_path = "./Berksfile"
    c.vm.box = "opscode-centos-6.5"
    c.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box"
  end

  config.vm.provider :virtualbox do |vb|
    vb.customize [
      "modifyvm", :id,
      "--memory", "1536",
      "--cpus", "2"
    ]
  end

  config.vm.provider "vmware_fusion" do |v|
    v.vmx["memsize"] = "1536"
    v.vmx["numvcpus"] = "2"
  end

  config.vm.provider :aws do |aws, override|
    raise "AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SSH_PRIVATE_KEY_PATH env vars must be set" unless
      aws_access_key_id && aws_secret_access_key && aws_ssh_private_key_path

    aws.access_key_id     = aws_access_key_id
    aws.secret_access_key = aws_secret_access_key

    aws.instance_type = "c3.large"
    #aws.instance_type = "m3.medium"
    #aws.instance_type = "m1.small"

    #aws.region = "us-east-1"
    #aws.ami = "ami-7747d01e"

    aws.region = "ap-southeast-2"
    aws.ami = "ami-978916ad"

    # Virginia
    aws.region_config "us-east-1" do |region|
      region.keypair_name = "jesse-us-east-1"
    end

    # Sydney
    aws.region_config "ap-southeast-2" do |region|
      region.keypair_name = "jesse-ap-southeast-2"
    end

    override.ssh.username = remote_user
    override.ssh.private_key_path = aws_ssh_private_key_path
  end

  # Ensure a recent version of the Chef Omnibus packages are installed
  config.omnibus.chef_version = :latest

  # Enable the berkshelf-vagrant plugin
  config.berkshelf.enabled = true

  # The path to the Berksfile to use with Vagrant Berkshelf
  config.berkshelf.berksfile_path = "./Berksfile"

  if Vagrant::VERSION < "1.3.0"
    config.ssh.max_tries = 40
    config.ssh.timeout   = 120
  end
  config.ssh.forward_agent = true

  host_project_path = File.expand_path("..", __FILE__)
  guest_project_path = "/home/#{remote_user}/#{File.basename(host_project_path)}"

  config.vm.synced_folder host_project_path, guest_project_path

  # prepare VM to be an Omnibus builder
  config.vm.provision :chef_solo do |chef|
    chef.json = {
      "omnibus" => {
        "build_user"  => remote_user,
        "build_dir"   => guest_project_path,
        "install_dir" => "/opt/#{project_name}"
      }
    }

    chef.run_list = [
      "recipe[omnibus::default]"
    ]
  end

  config.vm.provision :shell, :inline => <<-OMNIBUS_BUILD
    export PATH=/usr/local/bin:$PATH
    cd #{guest_project_path}
    su #{remote_user} -c "bundle install --binstubs"
    su #{remote_user} -c "bin/omnibus build project #{project_name}"
  OMNIBUS_BUILD

  # to speed up subsequent rebuilds install vagrant-cachier
  # to cache packages in your ~/.vagrant.d/cache directory
  # https://github.com/fgrehm/vagrant-cachier
  #   `vagrant plugin install vagrant-cachier`
  if ENV['VAGRANT_CACHE']
    config.cache.auto_detect = true
    config.cache.enable_nfs  = true
  end

end

