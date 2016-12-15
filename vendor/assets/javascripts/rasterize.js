"use strict";
var page = require('webpage').create(),
    system = require('system'),
    address, cookie, domain, npages, size;

function next_page(index, npages) {
  if (index == npages + 1) {
    console.log('Done!');
    phantom.exit();
  }
  var file = "/Users/leviathan/Desktop/Projects/trade_reporting_tool/changes_history_" + index + ".pdf";
  page.evaluate(function() {
    document.getElementById('next_page').click();
  });
  window.setTimeout(function() {
    page.render(file);
    next_page(index + 1, npages);
  }, 1000);
}

function handle_page(index, npages) {
  var file = "/Users/leviathan/Desktop/Projects/trade_reporting_tool/changes_history_" + index + ".pdf";
  page.open(address, function(status) {
    if (status !== 'success') {
      console.log('Unable to load the address!');
      phantom.exit(1);
    }
    else {
      window.setTimeout(function() {
        page.render(file);
        next_page(index + 1, npages);
      }, 1000);
    }
  });
}

address = system.args[1];
cookie = system.args[2];
domain = system.args[3];
npages = parseInt(system.args[4]);

if (!cookie || !domain) {
  console.log("Wrong session arguments.");
}
else {
  phantom.addCookie({
    'name': '_trade_reporting_tool_session',
    'value': cookie,
    'domain': domain
  });
}

page.viewportSize = {
  width: 1530,
  height: 2000
};

page.paperSize = {
  width: page.viewportSize.width,
  height: page.viewportSize.height,
  margin: '1.5cm'
};

handle_page(1, npages);
