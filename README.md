raspberry-muni-ruby
==============

Muni (San Francisco public transportation) prediction powered by Raspberry Pi.

This app fetches bus stops from Nextbus and displays them in Adafruit 16x2 LCD.

Installation
-------

On Raspberry Pi

Enable i2c module to access GPIO

```
$ sudo modprobe i2c_dev
$ sudo vi /etc/modules
# Add following line:

i2c-dev
```

```
$ sudo vi /etc/modprobe.d/raspi-blacklist.conf

# Comment out following lines:

blacklist spi-bcm2708
blacklist i2c-bcm2708
```

```
$ sudo apt-get install i2c-tools
$ sudo usermod -a -G i2c USERNAME
```

Finally

```
bundle install
ruby main.rb
```

Demo
-------

- Up and down button for navigating through routes, sorted by route name
- Right and left button for switching between inbound and outbound

![raspberry pi](https://github.com/zocoi/raspberry-muni-ruby/raw/master/rasp.jpg)



