#require "WS2812.class.nut:3.0.0"

/* Consts and Globals --------------------------------------------------------*/
const NUMPIXELS = 8;

levels <- [
  {
    idx = 0,
    fill_lvl = 0.25,
    color = [0, 64, 0]
  },
  {
    idx = 1,
    fill_lvl = 0.5,
    color = [30, 30, 0]
  },
  {
    idx = 2,
    fill_lvl = 0.75,
    color = [60, 10, 0]
  },
  {
    idx = 3,
    fill_lvl = 1,
    color = [64, 0, 0]
  }
];
  
cur_lvl <- 0;

/* Global functions ----------------------------------------------------------*/

function log(msg) {
  if (server.isconnected()) {
    server.log(msg);
  }
}

function up_event() {
  // debounce: stop new interrupts, wait, then read state
  btn_up.configure(DIGITAL_IN_PULLUP);
  imp.sleep(0.05);
      
  if (btn_up.read()) {
        //log("Up Released");
    } else {
        
        // increment the current level
        cur_lvl++;
        
        if (cur_lvl > levels.len() - 1) {
          cur_lvl = levels.len() - 1;
        }
        
        // redraw the gauge
        update();
    }
  
  // re-enable interrupts
  btn_up.configure(DIGITAL_IN_PULLUP, up_event);
}

function dn_event() {
  // debounce: stop new interrupts, wait, then read state
  btn_dn.configure(DIGITAL_IN_PULLUP);
  imp.sleep(0.05);
  
  if (btn_dn.read()) {
        log("Down Released");
    } else {
        log("Down Pressed")
        
        // decrement the current level
        cur_lvl--;
        
        if (cur_lvl < 0) {
          cur_lvl = 0;
        }
        
        // redraw the gauge
        update();
    }
    
  // re-enable interrupts
  btn_dn.configure(DIGITAL_IN_PULLUP, dn_event);
}

// draw the gauge
function update() {
  // clear the frame
  pixels.fill([0,0,0], 0, NUMPIXELS - 1);
  
  // fill to the appropriate level
  pixels.fill(levels[cur_lvl].color, 0, (levels[cur_lvl].fill_lvl * NUMPIXELS) - 1);
  pixels.draw();
}

/* Hardware Assignments ------------------------------------------------------*/

// Select the SPI bus
spi <- hardware.spiEBCA;
btn_up <- hardware.pinD;
btn_dn <- hardware.pinC;

btn_up.configure(DIGITAL_IN_PULLUP, up_event);
btn_dn.configure(DIGITAL_IN_PULLUP, dn_event);

/* Initialize Device ---------------------------------------------------------*/

imp.enableblinkup(true);

// Instantiate LED array
pixels <- WS2812(spi, NUMPIXELS);

/* Runtime Start -------------------------------------------------------------*/

log("Running.");
update();
