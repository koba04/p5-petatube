# install

## virtualbox

    https://www.virtualbox.org/

## vagrant

    http://docs.vagrantup.com/v2/installation/index.html

# setup

## vagrant

    % vagrant up
    % vagrant ssh-config --host petatube >> ~/.ssh/config

## chef

    % bundle install --path=vendor/bundle

    % cd chef
    % bundle exec knife solo prepare vagrant@petatube
    % bundle exec knife solo cook petatube

