require "spec_helper"
require "serverspec"

php_version = "7.2"
package = "php#{php_version}-fpm"
service = "php#{php_version}-fpm"
ini_config = "/etc/php/#{php_version}/fpm/php.ini"
fpm_config = "/etc/php/#{php_version}/fpm/php-fpm.conf"
fpm_dir = "/etc/php/#{php_version}/fpm/pool.d"
default_user = "root"
default_group = "root"
user    = "www"
group   = "www"
ports   = [9000]
log_dir = "/var/log/php-fpm"
pid_file = "/var/run/php/php-fpm.pid"

case os[:family]
when "ubuntu"
  user = "www-data"
  group = "www-data"
when "openbsd"
  service = "php56_fpm"
  default_group = "wheel"
  package = "php"
  ini_config = "/etc/php.ini"
  fpm_config = "/etc/php-fpm.conf"
  fpm_dir = "/etc/php-fpm.d"
  pid_file = "/var/run/php-fpm.pid"
when "freebsd"
  service = "php-fpm"
  default_group = "wheel"
  package = "lang/php70"
  ini_config = "/usr/local/etc/php.ini"
  fpm_config = "/usr/local/etc/php-fpm.conf"
  fpm_dir = "/usr/local/etc/php-fpm.d"
  pid_file = "/var/run/php-fpm.pid"
end
pool_file = "#{fpm_dir}/www.conf"

describe package(package) do
  it { should be_installed }
end

describe file(fpm_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
end

describe file(ini_config) do
  it { should exist }
  it { should be_file }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/^; Managed by ansible$/) }
  its(:content) { should match(/^\[PHP\]$/) }
  its(:content) { should match(/^\[CLI Server\]\ncli_server\.color = On$/) }
end

describe file(fpm_config) do
  it { should exist }
  it { should be_file }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/^; Managed by ansible$/) }
  its(:content) { should match(/^\[global\]\npid = #{pid_file}$/) }
end

describe file(pool_file) do
  it { should exist }
  it { should be_file }
  it { should be_owned_by default_user }
  it { should be_grouped_into default_group }
  its(:content) { should match(/^; Managed by ansible$/) }
  its(:content) { should match(/^\[www\]\nuser = #{user}\ngroup = #{group}$/) }
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
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/^# Managed by ansible$/) }
    its(:content) { should match(/^php_fpm_flags=""$/) }
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
