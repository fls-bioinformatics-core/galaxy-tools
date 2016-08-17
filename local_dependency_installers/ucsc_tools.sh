#!/bin/bash -e
#
# Install UCSC tools and subsets
#
function install_ucsc_fetchChromSizes_1_0() {
    echo Installing UCSC fetchChromSizes 
    local install_dir=$1/ucsc_fetchChromSizes/1.0
    mkdir -p $install_dir/bin
    echo Moving to $install_dir/bin
    pushd $install_dir/bin
    wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/fetchChromSizes
    chmod 755 fetchChromSizes
    popd
    # Make setup file
    cat > $1/ucsc_fetchChromSizes/1.0/env.sh <<EOF
#!/bin/sh
# Source this to setup fetchChromSizes/1.0
echo Setting up fetchChromSizes 1.0
export PATH=$install_dir/bin:\$PATH
#
EOF
}
#
function install_ucsc_tools_for_macs21_1_0() {
    echo Installing UCSC tools for MACS2
    local install_dir=$1/ucsc_tools_for_macs21/1.0
    mkdir -p $install_dir/bin
    echo Moving to $install_dir/bin
    pushd $install_dir/bin
    wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/fetchChromSizes
    wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bedClip
    wget -q http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig
    for x in "fetchChromSizes bedClip bedGraphToBigWig" ; do
	chmod 755 $x
    done
    popd
    # Make setup file
    cat > $1/ucsc_tools_for_macs21/1.0/env.sh <<EOF
#!/bin/sh
# Source this to setup ucsc_tools_for_macs21/1.0
echo Setting up UCSC Tools for MACS21 1.0
export PATH=$install_dir/bin:\$PATH
#
EOF
}
