define :install_ruby, configure_args: nil, make_jobs: nil, variation_name: nil, keep: false, force: false do
  version = params[:name].to_s
  variation_name = params[:variation_name] || version
  rbenv_root = File.expand_path('~/.rbenv')
  source_dir = File.join(rbenv_root, 'sources', version)
  prefix_dir = File.join(rbenv_root, 'versions', variation_name)

  rebuild_flag_name = "REBUILD_RUBY_#{version.gsub('.', '_').upcase}"
  params[:force] ||= ENV[rebuild_flag_name]
  params[:configure_args] ||= []

  if version == 'trunk' || version == :trunk
    git source_dir do
      repository 'https://github.com/ruby/ruby.git'
    end
  else
    directory source_dir

    version_dir = version.split('.')[0, 2].join('.')
    tarball_url = "https://cache.ruby-lang.org/pub/ruby/#{version_dir}/ruby-#{version}.tar.gz"

    execute "curl -fsSL #{tarball_url} | /usr/bin/tar xz --strip 1 -C #{source_dir}" do
      not_if "test -f #{source_dir}/configure.in"
    end
  end

  local_ruby_block "Install ruby #{variation_name}" do
    only_if "test ! -x #{prefix_dir}/bin/ruby" unless params[:force]

    block do
      Dir.chdir source_dir do
        if version == 'trunk' && params[:force]
          run_command(['git', 'pull', '--rebase', 'origin', 'trunk'])
        elsif File.file?('Makefile') && params[:force]
          run_command(['make', 'distclean'])
        end

        run_command('autoconf')

        configure_cmdline = [
          './configure',
          "--prefix=#{prefix_dir}",
          *params[:configure_args],
        ]
        run_command(configure_cmdline)

        make_cmdline = ['make']
        make_cmdline << '-j' << params[:make_jobs].to_s if params[:make_jobs]
        run_command(make_cmdline)

        run_command(['make', 'install'])
      end

      run_command("RBENV_VERSION=#{version} rbenv exec gem update --system")
      run_command("yes | RBENV_VERSION=#{version} rbenv exec gem update")
      run_command("yes | RBENV_VERSION=#{version} rbenv exec gem install bundler pry pry-byebug || :")
    end
  end
end