default[:user] = {
  name: "vagrant",
  home: "/home/vagrant"
};

default[:anyenv] = {
  "perl"    => {
    versions:   %w{5.18.1},
    global:     "5.18.1"
  },

  "ruby"    => {
    versions:   %w{2.0.0-p247},
    global:     "2.0.0-p247"
  },

  "node"    => {
    versions:  %w{v0.10.17},
    global:    "v0.10.17"
  },
};

