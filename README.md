# STM32 UI Library

[![Build Status](https://img.shields.io/jenkins/s/http/jenkins.vacs.fr/stm32-ui.svg)](http://jenkins.vacs.fr/job/stm32-ui/)
[![License](http://img.shields.io/badge/license-APACHE2-blue.svg)](LICENSE)
![Commits](https://img.shields.io/github/commits-since/stcarrez/stm32-ui/1.0.0.svg)

STM32 UI provides a set of Ada packages to help in writing graphical
application on STM32F746, STM32F769 boards.  Several packages have
been created from two other projects: [EtherScope](https://github.com/stcarrez/etherscope.git)
and then [Hestia](https://github.com/stcarrez/hestia.git).
Since then, the UI part of these two projects has been integrated in this separate
project with the hope that it could be more easily re-used.

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

```shell
  make
```

## Building the tools

The `tools` directory contains two tools that can help in some projects.
These tools are written in Ada and must be built by using the host GNAT Ada compiler
as follows

```shell
  cd tools && gprbuild -Ptools -p
```

The `cosin` tool is a sinus/cosinus table generation that generated the
`src/cosin_table.ads` package.

The `gif2ada` tool is the tool that reads a GIF image and generates an Ada
package specification which can be used in programs together with the
`UI.Images.Draw_Image` procedure.

# Gallery demo

The gallery demo displays a set of GIF pictures on the screen.
You can install it with the command:

```shell
  make flash-gallery
```

You can put your own images by using the `make-gallery-pics.sh` script
and the `gif2ada` tool.  You can put up to 9 pictures.  The input images
can be of any format and any size.  They are resized to a 480x272 form
and converted to GIF.  The converted image is then used to generate
Ada package specifications that contains selected parts of the GIF file.

```shell
  sh make-gallery-pics.sh img1.png img2.jpg img3.jpg
```

After updating the pictures, you have to re-build the demos and flash
the new binary:

```shell
 make
 make flash-gallery
```

![](https://github.com/stcarrez/stm32-ui/wiki/images/stm32-ui-ada-lovelace.jpg)
![](https://github.com/stcarrez/stm32-ui/wiki/images/stm32-ui-makewithada.jpg)

# Graphs demo

The graphs demo illustrates how the `UI.Graphs` generic package can be used
to display various graphs on the screen.
You can install it with the command:

```shell
  make flash-graphs
```

The `UI.Graphs` package must be instantiated with the integer data type you want to graph.
It then provides a `Data_Type` protected object that holds the data values and a
`Graph_Type` object that allows to display them on the screen.  Data samples must be added
at a periodic rate through the `Add_Sample` procedure.  The graph itself is displayed
by using the `Draw` procedure.  Adding new samples and displaying them may be performed
from different tasks.

![](https://github.com/stcarrez/stm32-ui/wiki/images/stm32-ui-graphs.jpg)

# Clock demo

The clock demo shows a 12 hour clock to demonstrate the use of `UI.Clock` package
operations.  It uses the RTC clock provided by the STM32 board.
You can install it with the command:

```shell
  make flash-clock
```

![](https://github.com/stcarrez/stm32-ui/wiki/images/stm32-ui-clock.jpg)
