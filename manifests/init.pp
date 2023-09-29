# @summary
#   Install pipx and prepares environment to work with pipx package provider
#
# @param manage_package
#   Whether to install pipx package
#
# @param global
#   Whether to install pipx package in a global location instead of the running user's home directory
#
# @param pipx_home
#   Value for the PIPX_HOME environment variable when installing in a global location
#
# @param pipx_bin_dir
#   Value for the PIPX_BIN_DIR environment variable when installing in a global location
#
class puppet_pipx (
  Boolean $manage_package = true,
  Boolean $global = true,
  Stdlib::Absolutepath $pipx_home = '/opt/pipx',
  Stdlib::Absolutepath $pipx_bin_dir = '/usr/local/bin',
) {

  # Install pipx.
  if $manage_package {
    package {'pipx': }
  }

  # Ensure package pipx is present before processing pipx provided ones.
  Package['pipx'] -> Package<| provider == 'pipx' |>

  # Install pipx-global wrapper script.
  if $global {
    file {'/usr/local/bin/pipx-global':
      mode    => '0755',
      content => @("PIPX_GLOBAL"/L)
        #!/bin/bash

        PIPX_HOME=${pipx_home} PIPX_BIN_DIR=${pipx_bin_dir} pipx "$@"
        | PIPX_GLOBAL
    }

    # Tell Package resources with provider pip to use our pipx-global script.
    Package <| provider == 'pipx' |> {
      command => '/usr/local/bin/pipx-global',
      require => File['/usr/local/bin/pipx-global']
    }
  }

}
