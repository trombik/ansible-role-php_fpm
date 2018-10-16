require "spec_helper"
require "serverspec"

php_version = "7.2"
package = "php#{php_version}-fpm"
service = "php#{php_version}-fpm"
ini_config  = "/etc/php/#{php_version}/fpm/php.ini"
fpm_config = "/etc/php/#{php_version}/fpm/php-fpm.conf"
fpm_dir = "/etc/php/#{php_version}/fpm/pool.d"
pool_file = "/etc/php/#{php_version}/fpm//php-fpm.d/www.conf"
default_user = "root"
default_group = "root"
user    = "www"
group   = "www"
ports   = [9000]
log_dir = "/var/log/php-fpm"
pid_file = "/var/run/php/php-fpm.pid"

case os[:family]
when "freebsd"
  service = "php-fpm"
  package = "lang/php72"
  default_group = "wheel"
  package = "lang/php72"
  ini_config = "/usr/local/etc/php.ini"
  fpm_config = "/usr/local/etc/php-fpm.conf"
  fpm_dir = "/usr/local/etc/php-fpm.d"
  pool_file = "/usr/local/etc/php-fpm.d/www.conf"
  db_dir = "/var/db/php"
  pid_file = "/var/run/php-fpm.pid"
end

describe package(package) do
  it { should be_installed }
end

describe file(ini_config) do
  it { should be_file }
  its(:content) { should match(/^\[PHP\]$/) }
  its(:content) { should match(/^\[CLI Server\]\ncli_server\.color = On$/) }
end

describe file(fpm_config) do
  it { should be_file }
  its(:content) { should match(/^\[global\]\npid = #{pid_file}$/) }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe file("#{log_dir}/php-fpm.log") do
  it { should exist }
  it { should be_file }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  it { should be_mode 600 }
end

describe file("#{log_dir}/access.log") do
  it { should exist }
  it { should be_file }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  it { should be_mode 600 }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/php-fpm") do
    it { should be_file }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
