# install

## virtualbox

https://www.virtualbox.org/

## vagrant

### install

    http://docs.vagrantup.com/v2/installation/index.html

### setup

    vagrant init precise64 http://files.vagrantup.com/precise64.box
    vagrant up

## knife-solo

    bundle install --path=vendor/bundle

### setup

    cat ~/.ssh/config

    Host 192.168.33.10
        IdentityFile ~/.vagrant.d/insecure_private_key
