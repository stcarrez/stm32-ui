# STM32 UI Library

[![Build Status](https://img.shields.io/jenkins/s/http/jenkins.vacs.fr/etherscope.svg)](http://jenkins.vacs.fr/job/etherscope/)
[![License](http://img.shields.io/badge/license-APACHE2-blue.svg)](LICENSE)
![Commits](https://img.shields.io/github/commits-since/stcarrez/stm32-ui/1.0.0.svg)

STM32 UI provides a set of Ada packages to help in writing graphical
application on STM32F746, STM32F769 boards.  Several packages have
been created in two other projects: [EtherScope](https://github.com/stcarrez/etherscope.git)
and then [Hestia](https://github.com/stcarrez/hestia.git).
The UI part of these two projects has been integrated in this separate
project with the help that it could more easily re-used.

The UI packages provided by STM32 UI are intended to help in:

* Managing touch buttons on the touch screen,
* Display graphs (see [EtherScope](https://github.com/stcarrez/etherscope.git)),
* Display clocks,
* Display GIF images

The STM32 UI library uses the following GitHub projects:

* Ada_Drivers_Library   https://github.com/AdaCore/Ada_Drivers_Library.git

You will also need the GNAT Ada compiler for ARM available at http://libre.adacore.com/

# Build

## STM32F746

```shell
  configure --with-board=stm32f746
```

## STM32F769

```shell
  configure --with-board=stm32f769
```

## Build

Run the command:

  make

# Gallery demo

The gallery demo displays a set of GIF pictures on the screen.
You can install it with the command:

```shell
  make flash-gallery
```
