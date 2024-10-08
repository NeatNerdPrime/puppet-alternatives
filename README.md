# puppet-alternatives

[![Build Status](https://github.com/voxpupuli/puppet-alternatives/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-alternatives/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-alternatives/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-alternatives/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/alternatives.svg)](https://forge.puppetlabs.com/puppet/alternatives)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/alternatives.svg)](https://forge.puppetlabs.com/puppet/alternatives)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/alternatives.svg)](https://forge.puppetlabs.com/puppet/alternatives)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/alternatives.svg)](https://forge.puppetlabs.com/puppet/alternatives)
[![puppetmodule.info docs](https://www.puppetmodule.info/images/badge.svg)](https://www.puppetmodule.info/m/puppet-alternatives)
[![Apache-2.0 License](https://img.shields.io/github/license/voxpupuli/puppet-alternatives.svg)](LICENSE)
[![Donated by Camptocamp](https://img.shields.io/badge/donated%20by-camptocamp-fb7047.svg)](#transfer-notice)

Manage alternatives symlinks.

## Synopsis

Using `puppet resource` to inspect alternatives

    root@master:~# puppet resource alternatives
    alternatives { 'aptitude':
      path => '/usr/bin/aptitude-curses',
    }
    alternatives { 'awk':
      path => '/usr/bin/mawk',
    }
    alternatives { 'builtins.7.gz':
      path => '/usr/share/man/man7/bash-builtins.7.gz',
    }
    alternatives { 'c++':
      path => '/usr/bin/g++',
    }
    alternatives { 'c89':
      path => '/usr/bin/c89-gcc',
    }
    alternatives { 'c99':
      path => '/usr/bin/c99-gcc',
    }
    alternatives { 'cc':
      path => '/usr/bin/gcc',
    }

- - -

Using `puppet resource` to update an alternative

    root@master:~# puppet resource alternatives editor
    alternatives { 'editor':
      path => '/bin/nano',
    }
    root@master:~# puppet resource alternatives editor path=/usr/bin/vim.tiny
    notice: /Alternatives[editor]/path: path changed '/bin/nano' to '/usr/bin/vim.tiny'
    alternatives { 'editor':
      path => '/usr/bin/vim.tiny',
    }

- - -

Using the alternatives resource in a manifest:

```puppet
class ruby_193 {

  package { 'ruby1.9.3':
    ensure => present,
  }

  # Will also update gem, irb, rdoc, rake, etc.
  alternatives { 'ruby':
    path    => '/usr/bin/ruby1.9.3',
    require => Package['ruby1.9.3'],
  }
}

include ruby_193
```

- - -

Creating a new alternative entry:

```puppet
alternative_entry { '/usr/bin/gcc-4.4':
  ensure   => present,
  altlink  => '/usr/bin/gcc',
  altname  => 'gcc',
  priority => 10,
  require  => Package['gcc-4.4-multilib'],
}
```

- - -

On RedHat, configuring an alternative using a family instead of a full path:

```puppet
alternatives { 'java':
  path    => 'java-1.8.0-openjdk.x86_64',
  require => Package['java-1.8.0-openjdk'],
}
```

This module should work on any Debian and RHEL based distribution.

## Transfer notice

This module was formerly maintained by Adrien Thebo at [forge.puppet.com/adrien/alternatives/](https://forge.puppet.com/modules/adrien/alternatives/readme)

## Contact

* [Source code](https://github.com/voxpupuli/puppet-alternatives)
* [Issue tracker](https://github.com/voxpupuli/puppet-alternatives/issues)
