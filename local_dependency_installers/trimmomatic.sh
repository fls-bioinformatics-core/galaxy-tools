#!/bin/bash -e
#
# Install the tool dependencies for Trimmomatic
#
function install_trimmomatic_0_36() {
    echo Installing Trimmomatic 0.36
    local install_dir=$1/trimmomatic/0.36
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.36.zip
    unzip -qq Trimmomatic-0.36.zip
    mv Trimmomatic-0.36/trimmomatic-0.36.jar $install_dir/trimmomatic.jar
    mv Trimmomatic-0.36/adapters/ $install_dir/
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/trimmomatic/0.36/env.sh <<EOF
#!/bin/sh
# Source this to setup trimmomatic/0.36
echo Setting up Trimmomatic 0.36
export TRIMMOMATIC_JAR_PATH=$install_dir
export TRIMMOMATIC_ADAPTERS_PATH=$install_dir/adapters
#
EOF
}
