#require "WS2812.class.nut:3.0.0"

/* Consts and Globals --------------------------------------------------------*/

// number LEDs in bar 
const NUMPIXELS = 8;

// interval to try and reconnect on a disconnect, in seconds
const RECONNECT_TIME = 900; // 15 min
const RECONNECT_TIMEOUT = 60;

// This table defines the fill levels and colors
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

// connection-safe logging
function log(msg) {
  if (server.isconnected()) {
    server.log(msg);
  }
}

// up-button handler
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

// down-button handler
function dn_event() {
  // debounce: stop new interrupts, wait, then read state
  btn_dn.configure(DIGITAL_IN_PULLUP);
  imp.sleep(0.05);
  
  if (btn_dn.read()) {
        //log("Down Released");
    } else {
        //log("Down Pressed")
        
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

/* Connection management functions -------------------------------------------*/
// mostly stock from https://developer.electricimp.com/examples/disconnection

function disconnectionHandler(reason) {
    if (reason != SERVER_CONNECTED) {
        // Try to reconnect in 'RECONNECT_TIME' seconds
        imp.wakeup(RECONNECT_TIME, reconnect);
        
        // Record time and reason of disconnection
        if (disData.len() == 0) {
            disData = format("Disconnected at %s. Reason code: %i\n", setTimeString(), reason);
        }
        
        disFlag = true;
        
        // enable blinkup as a visible sign that the connection is gone
        imp.enableblinkup(true);
    } else {
        // Device is connected again, so update the message string
        if (disData.len() != 0) {
            disData = disData + "Reconnected at: " + setTimeString();
            server.log(disData);
            disData = "";
        }
        
        disFlag = false;
        
        // disable blinkup as a visible sign that we're connected and ok
        imp.enableblinkup(false);
    }
}
 
function reconnect() {
    // server.connect calls disconnectHandler() on success or failure
    // with an appropriate reason parameter
    if (!server.isconnected()) {
        server.connect(disconnectionHandler, RECONNECT_TIMEOUT);
    } else {
        disconnectionHandler(SERVER_CONNECTED);
    }
}

// Format the disconnection time
function setTimeString() {
    local now = date();
    return (now.hour.tostring() + ":" + now.min.tostring() + ":" + now.sec.tostring);
}

/* Hardware Assignments ------------------------------------------------------*/

// Select the SPI bus
spi <- hardware.spiEBCA;
btn_up <- hardware.pinD;
btn_dn <- hardware.pinC;

btn_up.configure(DIGITAL_IN_PULLUP, up_event);
btn_dn.configure(DIGITAL_IN_PULLUP, dn_event);

/* Initialize Device ---------------------------------------------------------*/

// Set the disconnection policy to allow the device to keep running
server.setsendtimeoutpolicy(RETURN_ON_ERROR, WAIT_TIL_SENT, 10);

// Register the unexpected disconnect handler
server.onunexpecteddisconnect(disconnectionHandler);

// Instantiate LED array
pixels <- WS2812(spi, NUMPIXELS);

/* Runtime Start -------------------------------------------------------------*/

log("Running.");
update();
