include_module 'pyenv'
include_recipe 'helper'

install_python '3.6.4' do
  keep true
  env PYTHON_CONFIGURE_OPTS: '--enable-framework'
end

install_python '3.6.4' do
  prefix '3.6.4-o0'
  keep true
  env PYTHON_CONFIGURE_OPTS: '--enable-framework',
      OPT: '-g -O0 -Wall -Wstrict-prototypes'
end

execute 'pyenv global 3.6.4'
