# Engineer Resource Available Gauge

If you've got an open-plan office and social officemates, you get interrupted. A lot. 

Sometimes that's fun and one of the things you really enjoy about your office. Sometimes it wrecks your productivity for hours. 

You've tried the "I'm wearing headphones" thing but people don't clock it and honestly sometimes you are ok with getting interrupted when you're listening to music anyway. 

You need something more clear and direct. 

This little bar graph can be stuck to the back of your monitor and show everyone who approaches your desk just how available you're feeling! 

![Finished](/images/finished.JPG)

## Building Your Own

### Supplies

1. Electric Imp dev kit of some kind. You need one SPI MOSI line, and two GPIOs capable of state change callbacks - any imp ever made will work! I used an [imp003 breakout board](https://www.digikey.com/product-detail/en/murata-electronics-north-america/IMP003-BREAKOUT/490-14054-ND/6205491). An [imp001 dev kit](https://developer.electricimp.com/gettingstarted/devkits/?q=gettingstarted%2Fdevkits%2F) would work fine too; you'll just need to change the pin assignments.

2. [WS2182 LED stick](https://www.adafruit.com/product/1426). My code assumes 8 LEDs; you can use something different if you want with minimal code and hardware changes. 

3. Level Translator - the imp signals at 3.3V and the WS2812 needs its signal at 5V. There are a million ways to deal with this. I bought a [TXB0104 4-channel bidirectional level translator breakout](https://www.adafruit.com/product/1875). You only need one channel and you only need unidirectional translation, but this works fine. 

4. Buttons - I found some in a bin, and they're big and clicky and awesome! Find your own! [Adafruit has some nice Arcade pushbuttons](https://www.adafruit.com/product/471) that'll probably work if you've already got a shopping cart going there. 

5. A piece of acrylic to hold your project - I used a 3" x 10" piece of 1/8" thick Acrylic in ["Transparent Smoke (57%)" from TAP Plastics](https://www.tapplastics.com/product/plastics/cut_to_size_plastic/acrylic_sheets_transparent_colors/519). I wish I'd gotten something a little more opaque for better light diffusion - see if there's anything you want to try! Their pricing is funny - the base price is ~$10, and you can buy about 7 of these before the cart price actually goes up. 

6. Mounting Hardware to hold your LED Bar off the acrylic. I used two [1/4" long 2-56 female-female hex standoffs](https://www.mcmaster.com/#91115A806), and four [2-56 x 3/16" pan-head phillips screws](https://www.mcmaster.com/#90272A076). You can get them at McMaster. I wish the mounting distance was a little shorter for better light diffusion - experiment if you want. 

You'll need 2.4 GHz WiFi wherever you plan to load the code on your meter, but it can go off the grid after that. 

### Assembly

Wire everything up with a couple inches of slack before sticking it all to the acrylic; it's easier. 

#### Imp Connections

| Imp Breakout Pin | Connect To | Notes |
| ---------------- | ---------- | ----- |
| 3V3 | Level Translator VDDA Pin, Level Translator OE Pin | Easiest to connect from imp breakout to level translator VDDA, then tie VDDA to OE on the level translator. |
| GND | LED Stick Ground, Level Translator Ground, Button "Common" Pins | The imp breakout has two ground pins and the LED stick does too. I tied one of the imp breakout GND pins to the LED stick GND, and the other to the buttons' common line. I grounded the level translator by connecting its ground to the other GND pad on the LED stick. |
| PinE | Level Translator A1 | SPI MOSI Line to signal to LEDs |
| PinD | "Up" Button Normally-Open Pin. | Configured as Digital Input with internal pullup. |
| PinC | "Down" Button Normally-Open Pin. | Configured as Digital Input wiht internal pullup. |
| GND | See above | See above |
| VIN | LED Stick 5VDC | Imp breakout will be powered via a USB cable. This wire brings 5V to the LED stick to power the LEDs. |

#### Level Translator Connections

Note that this table overlaps the imp connection table. 

| Level Translator Pin | Connect To | Notes |
| -------------------- | ---------- | ----- |
| VDDA | Imp Breakout 3V3 Pin | Already done if you've completed the above table. |
| A1 | Imp Breakout PinE | Already done if you've completed the above table. |
| OE | Level Translator VDDA | |
| VDDB | 5VDC on LED Stick | |
| B1 | LED Stick DIN Pin | Translated signal out to LED Stick |

![Button Wiring](/images/wiring_btns.JPG)

![Level Translator Wiring](/images/wiring_lvlxlt.JPG)

![LED Wiring](/images/wiring_ledbar.JPG)

### Load Software

Give the [Electric Imp Getting Started Guide](https://developer.electricimp.com/gettingstarted/?q=gettingstarted%2F) a read to learn how to connect an imp to the WiFi and set up your developer account. When you've got that done and your meter is connected to the Internet, you can just copy the contents of engstackmeter.device.nut into the device code window, hit build and run, and you're good to go. 

The code includes handlers for lost WiFi connection - the gauge will continue to work, and the connection status LED on the imp breakout will turn on and blink combinations of red and amber if disconnected to show you its current connection state. The imp will try to reconnect on its own for 1 minute every 15 minutes. If it manages to reconnect, the status LED will stop blinking after a little while. 

Hope this helps you defend your focus time! Please submit a pull request if you find a bug!