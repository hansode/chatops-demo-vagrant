ChatOps Demo Vagrant
====================

Requirements
------------

+ Vagrant (>= 1.6.5)(http://www.vagrantup.com/downloads.html)
+ Platforms
  + Virtualbox (>= 4.3.24)(https://www.virtualbox.org/wiki/Downloads)
  + VMware Workstaion (>= 10)(https://www.vmware.com/go/downloadworkstation)
+ Vagrant VMware plugin if you're using vmware (http://www.vagrantup.com/vmware)

Getting Started
---------------

Create a VM.

```
$ make up
```

Connect to the VM.

```
$ vagrant ssh
```

Create `~/.hubotrc`.

```
$ vi ~/.hubotrc
```

```
export HUBOT_HIPCHAT_JID="********@chat.hipchat.com"
export HUBOT_HIPCHAT_PASSWORD="********"
export HUBOT_LOG_LEVEL="debug"
```

Run Hubot.

```
$ cd chatops-demo-hubot-hipchat/
$ ./bin/hubot-hipchat-jenkins
```

Access to http://localhost:8081/

References
----------

+ [wakameci/buildbook-rhel6](https://github.com/wakameci/buildbook-rhel6)
+ [hansode/chatops-demo-jenkins](https://github.com/hansode/chatops-demo-jenkins)
+ [hansode/chatops-demo-hubot-hipchat](https://github.com/hansode/chatops-demo-hubot-hipchat)

Contributing
------------

1. Fork it ( https://github.com/[my-github-username]/chatops-demo-vagrant/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

License
-------

[Beerware](http://en.wikipedia.org/wiki/Beerware) license.

If we meet some day, and you think this stuff is worth it, you can buy me a beer in return.
