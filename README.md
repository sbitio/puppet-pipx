# puppet-pipx

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with puppet-pipx](#setup)
    * [What puppet-pipx affects](#what-puppet_pipx-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet-pipx](#beginning-with-puppet_pipx)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module provides a puppet solution to overcome the implications of [PEP 668 – Marking Python base environments as “externally managed”](https://peps.python.org/pep-0668/)
by leveraging [pipx](https://github.com/pypa/pipx).

For such a thing, it provides a `pipx` package provider tweaked to
(optionally) install python dependencies system-wide.

Due to `pipx` doesn't provide an option to install packages system-wide ([ref](https://github.com/pypa/pipx/issues/754)),
this module also provides the `pipx-global` wrapper script installed to `/usr/local/bin`.
You can use this wrapper to directly manage pip packages system-wide.

## Usage

The most basic thing to do is to just include the main class and use the package provider:

```
include python_pipx

package { certbot:
  provider: pipx
}
```

It will perform:
 * Install `pipx` package via OS default provider
 * Install `/usr/local/bin/pipx-global` script
 * Install `certbot` via `pipx` to `/opt/pipx` and binaries symlinked from `/usr/local/bin`

You can tweak this default behaviour with the main class parameters. See [Code documentation](./doc/) for reference.


## Limitations

This module requires Puppet 4.x or above, and is compatible with the following OSes/versions:

 * Debian 10, 11, 12
 * Ubuntu 18.04, 20.04, 22.04

It may work for other versions and OSes. Please report us if you are using it on another envinment.

## Development

Development happens on [GitHub](https://github.com/sbitio/puppet-pipx).

Please log issues for any bug report, feature or support request.

Pull requests are welcome.


## License

MIT License, see LICENSE file


## Contact

Use contact form on http://sbit.io
