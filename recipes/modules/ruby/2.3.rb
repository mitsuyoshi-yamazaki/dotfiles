optflags = '-O3 -mtune=native -march=native'
debugflags = '-g'
configure_args = [
  "--with-opt-dir=#{`brew --prefix`.chomp}",
  "--with-dbm-dir=#{`brew --prefix qdbm`.chomp}",
  "--with-dbm-type=qdbm",
  "--with-gdbm-dir=#{`brew --prefix gdbm`.chomp}",
  "--with-libyaml-dir=#{`brew --prefix libyaml`.chomp}",
  "--with-openssl-dir=#{`brew --prefix openssl`.chomp}",
  "--with-readline-dir=#{`brew --prefix readline`.chomp}",
  "--disable-install-doc",
  "--enable-shared",
  "--enable-dtrace",
  "optflags=#{optflags}",
  "debugflags=#{debugflags}"
]

install_ruby('2.3.4', configure_args: configure_args + ["optflags=#{optflags}"], make_jobs: 4)

install_ruby('2.3.4', configure_args: configure_args + ["optflags=-O0"], make_jobs: 4, prefix: '2.3.4-o0')

execute 'rbenv alias 2.3 2.3.4'
