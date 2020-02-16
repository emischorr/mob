// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import "./dashboard"
import "./slider"
import Chartist from "chartist"
// import "./chart"

let Hooks = {}

Hooks.Chart = {
  mounted(){
    var data = {
      labels: ['0:00'],
      series: [[0]]
    };
    var options = {
      showPoint: false,
      axisX: {
        showGrid: false, // We can disable the grid for this axis
        showLabel: false // and also don't show the label
      },
      axisY: {
        labelInterpolationFnc: function(value) {
          return value + 'ms';
        },
        referenceValue: 200,
        low: 0
      }
    };
    new Chartist.Line("#"+this.el.id, data, options);
  },

  updated(){

    var data = {
      labels: ['0:00', '0:01', '0:02', '0:03', '0:04'],
      series: [
        [5, 2, 4, 2, 0],
        [0, 0, 1, 2, 0]
      ]
    };

    var data2 = JSON.parse(this.el.getAttribute("data-chart-data"));

    document.getElementById(this.el.id).__chartist__.update(data2)
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {hooks: Hooks, params: {_csrf_token: csrfToken}})
liveSocket.connect()
