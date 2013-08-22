# install

## virtualbox

    https://www.virtualbox.org/

## vagrant

    http://docs.vagrantup.com/v2/installation/index.html

# setup

## vagrant

    % vagrant init precise64 http://files.vagrantup.com/precise64.box
    % vagrant up
    % vagrant ssh-config --host petatube >> ~/.ssh/config

## chef

    % bundle install --path=vendor/bundle

    % cd chef && bundle exec knife solo prepare vagrant@192.168.10.2

