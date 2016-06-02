require 'erb'

name "redis"
default_version "3.2.0"

source :url => "http://download.redis.io/releases/redis-#{version}.tar.gz",
       :md5 => "9ec99ff912f35946fdb56fe273140483"

relative_path "redis-#{version}"

etc_path = "#{install_dir}/embedded/etc"
omnibus_flapjack_path = Dir.pwd

make_args = ["PREFIX=#{install_dir}/embedded",
             "CFLAGS='-L#{install_dir}/embedded/lib -I#{install_dir}/embedded/include'",
             "LD_RUN_PATH=#{install_dir}/embedded/lib"].join(" ")

@install_dir = install_dir
bnd          = binding

init_deb_template = ERB.new(File.read("#{omnibus_flapjack_path}/dist/etc/init.d/redis-flapjack-deb.erb"), nil, '-')
init_deb          = init_deb_template.result(bnd)

init_rpm_template = ERB.new(File.read("#{omnibus_flapjack_path}/dist/etc/init.d/redis-flapjack-rpm.erb"), nil, '-')
init_rpm          = init_rpm_template.result(bnd)

build do
  command ["make -j #{workers}", make_args].join(" ")
  command ["make install", make_args].join(" ")

  command "mkdir -p '#{etc_path}/redis'"
  command "mkdir -p '#{etc_path}/init.d'"

  command "cp -a #{omnibus_flapjack_path}/dist/etc/redis #{etc_path}"
  command "cat >#{etc_path}/init.d/redis-flapjack-deb <<EOINIT\n#{init_deb.gsub(/\$/, '\\$')}EOINIT"
  command "cat >#{etc_path}/init.d/redis-flapjack-rpm <<EOINIT\n#{init_rpm.gsub(/\$/, '\\$')}EOINIT"
end

