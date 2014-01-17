---
layout: post
category : "first vagrant post"
tagline: "Hello World part 2!"
tags : [intro, beginner, jekyll, vagrant]
---

{% include JB/setup %}

## This is my first post using Vagrant for Jekyll

Yes! I am one step closer to making my life easier for writing this blog! I tell thee, setting up Ruby on Windows 7/8 doesn't bode well with me.. But thankfully I came across a Vagrant tutorial <http://dwradcliffe.com/2013/04/12/vagrant-to-compile-jekyll.html> Unfortunately a little out of date with the reference to a couple of Jekyll commands, but Jekyll corrects you on that and for some reason it didn't install Jekyll from the Vagrantfile through no fault of the tutorial (I just had to run the commands from the Vagrantfile for Jekyll manually). So I can't moan at all!

    Vagrant::Config.run do |config|

     config.vm.box = "precise32"
     config.vm.box_url = "http://files.vagrantup.com/precise32.box"
     config.vm.forward_port 4000, 4000
     config.vm.provision :shell, :inline => "sudo apt-get -y install build-essential && sudo /opt/vagrant_ruby/bin/gem install jekyll rdiscount --no-ri --no-rdoc"

    end


