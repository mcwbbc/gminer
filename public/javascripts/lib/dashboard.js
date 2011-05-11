// The Console handles all of the Admin interaction with the active workers
// and job queue.
//
// Think about pulling in the DCJS framework, instead of just raw jQuery here.
// Leaving it hacked together like this just cries out for templates, dunnit?
window.Console = {

  // Maximum number of data points to record and graph.
  MAX_DATA_POINTS : 100,

  // Milliseconds between polling the central server for updates to Job progress.
  POLL_INTERVAL : 3000,

  // Default speed for all animations.
  ANIMATION_SPEED : 300,

  // All options for drawing the system graphs.
  GRAPH_OPTIONS : {
    xaxis   : {mode : 'time', timeformat : '%M:%S'},
    yaxis   : {tickDecimals : 0},
    legend  : {show : false},
    grid    : {backgroundColor : '#7f7f7f', color : '#555', tickColor : '#666', borderWidth : 2}
  },
  PENDING_COLOR  : '#ffba14',
  ACTIVE_COLOR   : '#3adb0f',
  WORKERS_COLOR  : '#45a4e5',

  // Starting the console begins polling the server.
  initialize : function() {
    this._pendingHistory = [];
    this._activeHistory = [];
    this._workersHistory = [];
    this._histories = [this._pendingHistory, this._activeHistory, this._workersHistory];
    $(window).bind('resize', Console.renderGraphs);
    this.getStatus();
  },

  // Request the lastest status of all jobs and workers, re-render or update
  // the DOM to reflect.
  getStatus : function() {
    $.ajax({url : '/jobs/graph_status', dataType : 'json', success : function(resp) {
      Console._pendingCount = resp.pending;
      Console._activeCount  = resp.active;
      Console._workerCount  = resp.workers;
      Console.recordDataPoint();
      Console.renderGraphs();
      setTimeout(Console.getStatus, Console.POLL_INTERVAL);
    }, error : function(request, status, errorThrown) {
      if (!Console._disconnected.is(':visible')) { Console._disconnected.fadeIn(Console.ANIMATION_SPEED); }
      setTimeout(Console.getStatus, Console.POLL_INTERVAL);
    }});
  },

  // Record the current state and re-render all graphs.
  recordDataPoint : function() {
    var timestamp = (new Date()).getTime();
    this._pendingHistory.push([timestamp, this._pendingCount]);
    this._activeHistory.push([timestamp, this._activeCount]);
    this._workersHistory.push([timestamp, this._workerCount]);
    $.each(this._histories, function() {
      if (this.length > Console.MAX_DATA_POINTS) { this.shift(); }
    });
  },

  // Convert our recorded data points into a format Flot can understand.
  renderGraphs : function() {
    $.plot($('#pending_graph'), [
      {label : 'Pending Jobs ('+this._pendingCount+')', color : Console.PENDING_COLOR, data : Console._pendingHistory}
    ], Console.GRAPH_OPTIONS);
    $.plot($('#active_graph'), [
      {label : 'Active Jobs', color : Console.ACTIVE_COLOR, data : Console._activeHistory}
    ], Console.GRAPH_OPTIONS);
    $.plot($('#workers_graph'), [
      {label : 'Workers', color : Console.WORKERS_COLOR, data : Console._workersHistory}
    ], Console.GRAPH_OPTIONS);
  }
};

$(document).ready(function() {
  if ($('#pending_graph').length > 0) {
    Console.initialize();
  }
});