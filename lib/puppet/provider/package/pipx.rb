# frozen_string_literal: true

require 'json'
require 'open3'

Puppet::Type.type(:package).provide :pipx, :parent => :pip do

  desc "Python packages via `pipx`.

  This provider supports the `install_options` attribute, which allows command-line flags to be passed to pipx.
  These options should be specified as an array where each element is either a string or a hash."

  has_feature :installable, :uninstallable, :upgradeable, :versionable, :install_options, :targetable

  def self.cmd
    ["pipx"]
  end

  def self.pip_version(command)
    version = nil
    execpipe [quote(command), '--version'] do |process|
      process.collect do |line|
        md = line.strip.match(/^(\d+\.\d+\.?\d*).*$/)
        if md
          version = md[1]
          break
        end
      end
    end

    raise Puppet::Error, _("Cannot resolve pipx version") unless version

    version
  end

  # Return an array of structured information about every installed package
  # that's managed by `pip` or an empty array if `pip` is not available.
  def self.instances(target_command = nil)
    if target_command
      command = target_command
      self.validate_command(command)
    else
      command = provider_command
    end

    packages = []
    return packages unless command

    stdout, stderr, status = Open3.capture3(quote(command), 'list', '--json')
    content = JSON.parse(stdout)
    content['venvs'].each do |venv_name, venv|
      package = venv['metadata']['main_package']['package']
      version = venv['metadata']['main_package']['package_version']
      pkg = {:ensure => version, :name => package, :provider => name, :command => command}
      packages << new(pkg)
    end

    packages
  end

  def get_install_command_options()
    should = @resource[:ensure]
    command_options = %w{install}
    command_options += install_options if @resource[:install_options]

    if @resource[:source]
      if String === should
        command_options << "#{@resource[:source]}@#{should}#egg=#{@resource[:name]}"
      else
        command_options << "#{@resource[:source]}#egg=#{@resource[:name]}"
      end

      return command_options
    end

    if should == :latest
      command_options << "--upgrade" << @resource[:name]

      return command_options
    end

    unless String === should
      command_options << @resource[:name]

      return command_options
    end

    begin
      should_range = PIP_VERSION_RANGE.parse(should, PIP_VERSION)
    rescue PIP_VERSION_RANGE::ValidationFailure, PIP_VERSION::ValidationFailure
      Puppet.debug("Cannot parse #{should} as a pip version range, falling through.")
      command_options << "#{@resource[:name]}==#{should}"

      return command_options
    end

    if should_range.is_a?(PIP_VERSION_RANGE::Eq)
      command_options << "#{@resource[:name]}==#{should}"

      return command_options
    end

    should = best_version(should_range)

    if should == should_range
      # when no suitable version for the given range was found, let pip handle
      if should.is_a?(PIP_VERSION_RANGE::MinMax)
        command_options << "#{@resource[:name]} #{should.split.join(',')}"
      else
        command_options << "#{@resource[:name]} #{should}"
      end
    else
      command_options << "#{@resource[:name]}==#{should}"
    end

    command_options
  end

end
