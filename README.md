# PetaTube

This is web application named PetaTube.

## develop on vagrant

https://github.com/koba04/p5-petatube/blob/master/server/development/vagrant/README.md

## develop local

### install Redis

http://redis.io/download

### install Perl, Node, Ruby

TBA

### setup compass and grunt

```
cd p5-petatube/app

bundle install --path vendor/bundle

npm install -g grunt-cli
npm install
npm install -g bower
bower install

# watch
grunt watch:(all|cofee|scss)
  or
# manualy
grunt
```

### carton

````
cpanm Carton
cd p5-petatube/app
carton install
```

### plackup

```
cd p5-petatube/app
carton exec plackup (-r)
```

enjoy!
