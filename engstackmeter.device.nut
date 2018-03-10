#require "WS2812.class.nut:3.0.0"

// Select the SPI bus
spi <- hardware.spiEBCA;
btn_up <- hardware.pinD;
btn_dn <- hardware.pinC;

function up_event() {
    if (btn_up.read()) {
        server.log("Up Released");
    } else {
        server.log("Up Pressed");
    }
}

function dn_event() {
    if (btn_dn.read()) {
        server.log("Down Released");
    } else {
        server.log("Down Pressed");
    }
}

// Instantiate LED array with 5 pixels
pixels <- WS2812(spi, 8);

btn_up.configure(DIGITAL_IN_PULLUP, up_event);
btn_dn.configure(DIGITAL_IN_PULLUP, dn_event);

server.log("Running.");
pixels.fill([0,255,255]);
pixels.draw();