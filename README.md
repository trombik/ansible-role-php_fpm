# php_fpm

`ansible` role for PHP `fpm`.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `php_version` | PHP version | `{{ __php_version }}` |
| `php_version_without_dot` | PHP version without `.` | `{{ php_version | regex_replace('\.', '') }}` |
| `php_package_map` | map table to lookup PHP package name | `{"FreeBSD"=>"lang/php{{ php_version_without_dot }}", "OpenBSD"=>"php%{{ php_version }}", "Debian"=>"php{{ php_version }}-fpm"}` |
| `php_package` | PHP package name | `{{ php_package_map[ansible_os_family] }}` |
| `php_conf_dir_map` | map table to lookup base directory of `php.ini` | `{"FreeBSD"=>"/usr/local/etc", "OpenBSD"=>"/etc", "Debian"=>"/etc/php/{{ php_version }}/fpm"}` |
| `php_conf_dir` | base directory of `php.ini` | `{{ php_conf_dir_map[ansible_os_family] }}` |
| `php_ini_file` | path to `php.ini` | `{{ php_conf_dir }}/php.ini` |
| `php_ini_config` | content of `php.ini` | `""` |
| `php_additional_packages` | list of extra packages to install | `[]` |
| `php_fpm_user` | user name of `fpm` | `{{ __php_fpm_user }}` |
| `php_fpm_group` | group name of `fpm` | `{{ __php_fpm_group }}` |
| `php_fpm_service_map` | map table to lookup `fpm` service | `{"FreeBSD"=>"php-fpm", "OpenBSD"=>"php{{ php_version_without_dot }}_fpm", "Debian"=>"php{{ php_version }}-fpm"}` |
| `php_fpm_service` | service name of `fpm` | `{{ php_fpm_service_map[ansible_os_family] }}` |
| `php_fpm_flags` | TBW | `""` |
| `php_fpm_pid_dir` | PID directory of `fpm` | `{{ __php_fpm_pid_dir }}` |
| `php_fpm_pid_file` | path to PID file of `fpm` | `{{ php_fpm_pid_dir }}/php-fpm.pid` |
| `php_fpm_conf_dir_map` | map table to lookup base directory of `php-fpm.conf` | `{"FreeBSD"=>"/usr/local/etc", "OpenBSD"=>"/etc", "Debian"=>"/etc/php/{{ php_version }}/fpm"}` |
| `php_fpm_conf_dir` | base directory of `php-fpm.conf` | `{{ php_fpm_conf_dir_map[ansible_os_family] }}` |
| `php_fpm_conf_file` | path to `php-fpm.conf` | `{{ php_fpm_conf_dir }}/php-fpm.conf` |
| `php_fpm_pool_dir_map` | base directory of configuration files for extensions | `{"FreeBSD"=>"/usr/local/etc/php-fpm.d", "OpenBSD"=>"/etc/php-fpm.d", "Debian"=>"/etc/php/{{ php_version }}/fpm/pool.d"}` |
| `php_fpm_pool_dir` | base directory of `fpm` pool | `{{ php_fpm_pool_dir_map[ansible_os_family] }}` |
| `php_fpm_bin_map` | map table to lookup path to `fpm` binary | `{"FreeBSD"=>"php-fpm", "Debian"=>"php-fpm{{ php_version }}", "OpenBSD"=>"php-fpm-{{ php_version }}"}` |
| `php_fpm_bin` | path to `fpm` binary | `{{ php_fpm_bin_map[ansible_os_family] }}` |
| `php_fpm_log_dir` | path to `fpm` log directory | `{{ __php_fpm_log_dir }}` |
| `php_fpm_config` | content of `php-fpm.conf` | `""` |

## Debian

| Variable | Default |
|----------|---------|
| `__php_version` | `7.4` |
| `__php_fpm_user` | `www-data` |
| `__php_fpm_group` | `www-data` |
| `__php_fpm_log_dir` | `/var/log/php-fpm` |
| `__php_fpm_pid_dir` | `/var/run/php` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__php_version` | `7.4` |
| `__php_fpm_user` | `www` |
| `__php_fpm_group` | `www` |
| `__php_fpm_log_dir` | `/var/log/php-fpm` |
| `__php_fpm_pid_dir` | `/var/run` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__php_version` | `7.4` |
| `__php_fpm_user` | `www` |
| `__php_fpm_group` | `www` |
| `__php_fpm_log_dir` | `/var/log/php-fpm` |
| `__php_fpm_pid_dir` | `/var/run` |

# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  pre_tasks:
    # XXX remove this when Ubutu VMs are updated
    - name: Update apt cache
      ansible.builtin.apt:
        update_cache: yes
      changed_when: false
      when: ansible_os_family == 'Debian'
  roles:
    - ansible-role-php_fpm
  vars:
    php_additional_packages_map:
      FreeBSD:
        - "archivers/php{{ php_version_without_dot }}-zip"
        - "textproc/php{{ php_version_without_dot }}-xsl"
      OpenBSD:
        - "php-zip%{{ php_version }}"
        - "php-xsl%{{ php_version }}"
      Debian:
        - "php{{ php_version }}-zip"
        - "php{{ php_version }}-xsl"
    php_additional_packages: "{{ php_additional_packages_map[ansible_os_family] }}"

    php_version: "{% if ansible_os_family == 'Debian' and ansible_distribution_version is version('20.04', '<') %}7.2{% else %}7.4{% endif %}"
    php_ini_config: |
      [PHP]
      engine = On
      short_open_tag = Off
      precision = 14
      output_buffering = 4096
      zlib.output_compression = Off
      implicit_flush = Off
      unserialize_callback_func =
      serialize_precision = -1
      disable_functions =
      disable_classes =
      zend.enable_gc = On
      expose_php = On
      max_execution_time = 30
      max_input_time = 60
      memory_limit = 128M
      error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
      display_errors = Off
      display_startup_errors = Off
      log_errors = On
      log_errors_max_len = 1024
      ignore_repeated_errors = Off
      ignore_repeated_source = Off
      report_memleaks = On
      html_errors = On
      variables_order = "GPCS"
      request_order = "GP"
      register_argc_argv = Off
      auto_globals_jit = On
      post_max_size = 8M
      auto_prepend_file =
      auto_append_file =
      default_mimetype = "text/html"
      default_charset = "UTF-8"
      doc_root =
      user_dir =
      enable_dl = Off
      file_uploads = On
      upload_max_filesize = 2M
      max_file_uploads = 20
      allow_url_fopen = On
      allow_url_include = Off
      default_socket_timeout = 60

      [CLI Server]
      cli_server.color = On

    php_fpm_config: |
      [global]
      pid = {{ php_fpm_pid_file }}
      error_log = {{ php_fpm_log_dir }}/php-fpm.log
      include = {{ php_fpm_pool_dir }}/*.conf
    php_fpm_pool_config:
      - name: www
        content: |
          [www]
          user = {{ php_fpm_user }}
          group = {{ php_fpm_group }}
          listen = 127.0.0.1:9000
          pm = dynamic
          pm.max_children = 5
          pm.start_servers = 2
          pm.min_spare_servers = 1
          pm.max_spare_servers = 3
          access.log = {{ php_fpm_log_dir }}/access.log
```

# License

```
Copyright (c) 2020 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
