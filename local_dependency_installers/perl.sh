#!/bin/bash -e
#
# Install Perl
#
function install_perl_5_16_3() {
    # Perl 5.16.3
    echo Installing Perl
    local install_dir=$1/perl/5.16.3
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz
    tar xzf perl-5.16.3.tar.gz
    cd perl-5.16.3
    ./Configure -des -Dprefix=$install_dir -D startperl='#!/usr/bin/env perl' >/dev/null 2>&1
    make install >/dev/null 2>&1
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/perl/5.16.3/env.sh <<EOF
#!/bin/sh
# Source this to setup perl/5.16.3
echo Setting up perl 5.16.3
export PATH=$install_dir/bin:\$PATH
#
EOF
}
