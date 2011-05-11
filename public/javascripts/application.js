// Common JavaScript code across your application goes here.

/**
*
*  UTF-8 data encode / decode
*  http://www.webtoolkit.info/
*
**/
 
var Utf8 = {
 
  // public method for url encoding
  encode : function (string) {
    string = string.replace(/\r\n/g,"\n");
    var utftext = "";
    var n;
    for (n = 0; n < string.length; n++) {
 
      var c = string.charCodeAt(n);
 
      if (c < 128) {
        utftext += String.fromCharCode(c);
      }
      else if((c > 127) && (c < 2048)) {
        utftext += String.fromCharCode((c >> 6) | 192);
        utftext += String.fromCharCode((c & 63) | 128);
      }
      else {
        utftext += String.fromCharCode((c >> 12) | 224);
        utftext += String.fromCharCode(((c >> 6) & 63) | 128);
        utftext += String.fromCharCode((c & 63) | 128);
      }
 
    }
 
    return utftext;
  },
 
  // public method for url decoding
  decode : function (utftext) {
    var string = "";
    var i = 0;
    var c, c1, c2;
    c = c1 = c2 = 0;
 
    while ( i < utftext.length ) {
 
      c = utftext.charCodeAt(i);
 
      if (c < 128) {
        string += String.fromCharCode(c);
        i++;
      }
      else if((c > 191) && (c < 224)) {
        c2 = utftext.charCodeAt(i+1);
        string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
        i += 2;
      }
      else {
        c2 = utftext.charCodeAt(i+1);
        c3 = utftext.charCodeAt(i+2);
        string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
        i += 3;
      }
 
    }
 
    return string;
  }
 
};

// for cytoscape

var vis = new org.cytoscapeweb.Visualization('cytoscapeweb', {swfPath: "/swf/CytoscapeWeb", flashInstallerPath: "/swf/playerProductInstall"});

var item_data;
var draw_options;

var layout_style = {'name': 'ForceDirected', 'options': { mass: 10, gravitation: -400, autoStabilize: true, minDistance: 50, restLength: 100 }};

var data_schema = {
  all: [
    { name: "label", type: "string" }
  ],
  nodes: [
    { name: "label", type: "string" },
    { name: "format", type: "string" },
    { name: "node_type", type: "string" },
    { name: "weight", type: "double" }
  ],
  edges: [
    { name: "weight", type: "double" },
    { name: "edge_format", type: "string" }
  ]
};

// visual style we will use
var visual_style = {
    global: {
        backgroundColor: "#fff"
    },
    nodes: {
        shape: "ELLIPSE",
        borderWidth: 2,
        size: {
            defaultValue: 50,
            continuousMapper: {
                attrName: "weight",
                minValue: 30,
                maxValue: 125,
                minAttrValue: 1,
                maxAttrValue: 200
            }
        },
        color: {
            defaultValue: "#fff", 
            discreteMapper: {
                attrName: "format",
                entries: [
                    { attrValue: 'geo_record', value: "#fff" },
                    { attrValue: 'field', value: "#ffc" },
                    { attrValue: 'ontology', value: "#fcc" },
                    { attrValue: 'unaudited', value: "#ee4" },
                    { attrValue: 'valid', value: "#2b2" },
                    { attrValue: 'invalid', value: "#b22" },
                    { attrValue: 'human', value: "#2b2" },
                    { attrValue: 'resource', value: "#ddd" },
                    { attrValue: 'SMD', value: "#d61c13" },
                    { attrValue: 'GAP', value: "#d66715" },
                    { attrValue: 'MICAD', value: "#f3ebc0" },
                    { attrValue: 'AE', value: "#b9d618" },
                    { attrValue: 'AERS', value: "#7ad618" },
                    { attrValue: 'WP', value: "#18d691" },
                    { attrValue: 'PGGE', value: "#19d6c6" },
                    { attrValue: 'GEO', value: "#19b5d6" },
                    { attrValue: 'OMIM', value: "#1d85d6" },
                    { attrValue: 'DBK', value: "#8722d6" },
                    { attrValue: 'PGDR', value: "#d022d6" },
                    { attrValue: 'PC', value: "#ff8871" },
                    { attrValue: 'CDD', value: "#ffd373" },
                    { attrValue: 'PCM', value: "#f1ff7b" },
                    { attrValue: 'UPKB', value: "#aaff76" },
                    { attrValue: 'CT', value: "#91ffcd" },
                    { attrValue: 'CANANO', value: "#b0c6ff" },
                    { attrValue: 'REAC', value: "#e0b4ff" },
                    { attrValue: 'PGDI', value: "#ffadbc" },
                    { attrValue: 'GM', value: "#009787" },
                    { attrValue: 'RXRD', value: "#c95954" },
                    { attrValue: 'BSM', value: "#c88b00" }
                ]
            }
        },
        borderColor: {
            defaultValue: "#000", 
            discreteMapper: {
                attrName: "format",
                entries: [
                    { attrValue: 'geo_record', value: "#000" },
                    { attrValue: 'field', value: "#000" },
                    { attrValue: 'ontology', value: "#000" },
                    { attrValue: 'unaudited', value: "#000" },
                    { attrValue: 'valid', value: "#00f" },
                    { attrValue: 'invalid', value: "#00f" },
                    { attrValue: 'human', value: "#f0f" },
                    { attrValue: 'resource', value: "#000" }
                ]
            }
        },
        labelHorizontalAnchor: "center"
    },
    edges: {
        width: {
            defaultValue: 3, 
            discreteMapper: {
                attrName: "edge_format",
                entries: [
                    { attrValue: 'resource', value: 2 },
                    { attrValue: 'detailed_resource', value: 5 }
                ]
            }
        },
        color: {
            defaultValue: "#000", 
            discreteMapper: {
                attrName: "edge_format",
                entries: [
                    { attrValue: 'resource', value: "#777" },
                    { attrValue: 'detailed_resource', value: "#d77" }
                ]
            }
        },
        style: {
            defaultValue: "SOLID", 
            discreteMapper: {
                attrName: "edge_format",
                entries: [
                    { attrValue: 'resource', value: "LONG_DASH" },
                    { attrValue: 'detailed_resource', value: "DOT" }
                ]
            }
        }
    }
};

var count = 0;

$.fn.allMatchTallestHeight = function() {
  var max_height = 0;
  var elements = $(this);
  elements.each( function() {
    if ($(this).height() > max_height) {
      max_height = $(this).height();
    }
  });

  elements.each( function() {
    $(this).height(max_height);
  });
};


function filter_submit() {
  var m = {};
  m._method = "get";

  if ($("#ddown").length > 0) {
    m.ddown = $("#ddown").val();
  }

  if ($("#status").length > 0) {
    m.status = $("#status").val();
  }

  if ($("#exclude").length > 0) {
    m.exclude = $("#exclude").val();
  }

  if ($("#query").length > 0) {
    m.query = $("#query").val();
  }

  if ($("#geotype").length > 0) {
    m.geotype = $("#geotype").val();
  }

  if ($("#has_predicate").length > 0) {
    m.has_predicate = $("#has_predicate").val();
  }

  $(".dataTable").load(window.location.pathname+'.js', m, function() {
    if(typeof set_bindings === 'function') {
      set_bindings();
    }
  });

  return false;
}

function update_filter_text() {
  var term_array = [];
  $("#term-parameters :hidden").each( function() {
    var term_name = $(this).attr("term_name");
    var term_id = $(this).attr("id");
    var link = "<a href='#' class='delete-result' term_id='"+term_id+"'><img src='/images/icons/error.png' border='0' class='delete-icon' /></a><span class='result-filter'>"+term_name+"</span>";
    term_array.push(link);
  });

  var term_string = term_array.join(" AND ");
  $("#filters").html(term_string);
}

function update_results() {
  $.get("/annotations/cloud", $("#term-parameters>:input").serialize(), function(data){}, "script");
}

function add_parameter_field(term_id, term_name) {
  var element = document.createElement("input");
  element.setAttribute("type", "hidden");
  element.setAttribute("value", term_id);
  element.setAttribute("id", term_id);
  element.setAttribute("name", "term_array[]");
  element.setAttribute("term_name", term_name);
  $(element).appendTo("#term-parameters");
}

function attach_term_hook() {
  $("a.result-term").live("click", function(){
    var term_id = $(this).attr("term_id");
    var term_name = $(this).html();
    try {
      pageTracker._trackPageview("/annotations/cloud/add/term/"+term_id);
    } catch(err) {}
    add_parameter_field(term_id, term_name);
    update_filter_text();
    update_results();
    return false;
  });
}

function remove_parameter_field(term_id) {
  $("#term-parameters :hidden").each( function() {
    if ($(this).attr("id") === term_id) {
      $(this).remove();
    }
  });
}

function attach_filter_hook () {
  $("a.delete-result").live("click", function(){
    var term_id = $(this).attr("term_id");
    remove_parameter_field(term_id);
    try {
      pageTracker._trackPageview("/annotations/cloud/remove/term/"+term_id);
    } catch(err) {}
    update_filter_text();
    update_results();
    return false;
  });
}

function delayKey() {
  count = count + 1;
  setTimeout("fireSubmit("+count+")", 750);
}

function fireSubmit(currCount) {
  if(currCount === count) {
    count = 0;
    filter_submit();
  }
}

function draw_cytoscape(passed_item_data) {
  // init and draw
  var item_data = passed_item_data;
  var draw_options = {
    network: { dataSchema: data_schema, data: item_data },
    visualStyle: visual_style,
    layout: layout_style
  };
  vis.draw(draw_options);
}

function draw_cytoscape_node (hash) {
  var node_id = hash.node_id;
  var node_data = { id: node_id, label: hash.label, format : hash.format, weight: Number(hash.weight), node_type: hash.node_type};
  var node = vis.addNode(0, 0, node_data, true);  

  var edge1_data = { source: hash.term1, target: node_id, edge_format: hash.edge_format, format : hash.format };
  var edge1 = vis.addEdge(edge1_data, true);

  var edge2_data = { source: hash.term2, target: node_id, edge_format: hash.edge_format, format : hash.format };
  var edge2 = vis.addEdge(edge2_data, true);
  vis.layout(layout_style);
}

function get_resource_term_ids(geo_accession) {
  $.getJSON('/cytoscapes/'+geo_accession+'/resource_term_ids/', {}, function(resource_ids) {
    var node_count = resource_ids.length;
    $('#resource-counts').text(node_count+' left');
    $.each(resource_ids, function(index, term_ids) {
      $.post('/cytoscapes/resource_count', {term_ids: term_ids}, function(data) {
        var terms = term_ids.split(',');
        var hash = {term1: terms[0], term2: terms[1], node_id: term_ids, label: data.resource_count, weight: data.resource_count, edge_format: 'resource', node_type: 'resource', format: 'resource'};
        draw_cytoscape_node(hash);
        node_count--;
        if (node_count > 0) {
          $('#resource-counts').text(node_count+' left');
        } else {
          $('#resource-counts').text('Complete');
        }
      }, "json");
    });
  });
}

function activate_resource_count_action() {
  $('#resource-counts').text('Get resource counts');
  $("#resource-counts").click(function() {
    get_resource_term_ids($("#cytoscapeweb").attr('geo_accession'));
    $('#resource-counts').unbind('click');
  });
}

function get_geo_item_cytoscape_data(geo_accession) {
  $.getJSON('/cytoscapes/'+geo_accession+'/item_json/', {}, function(json) {
    if (json.valid_annotation_count < 1) {
      $('#resource-counts').hide();
    } else {
      activate_resource_count_action();
    }
    draw_cytoscape(json.item_data);
    $(".annotation-table:has(a)").show();
  });
}

function get_resource_count_hash(clicked_node) {
  var term_ids = clicked_node.data.id;
  $.post('/cytoscapes/resource_count_hash', {term_ids: term_ids}, function(data) {
    var terms = term_ids.split(',');
    _.each(data.resource_count_hash, function(v, key) { 
      var node_id = v.concept_ids+'-'+key;
      var label = v.name+' - '+v.count;
      var hash = {term1: terms[0], term2: terms[1], node_id: node_id, label: label, weight: count, edge_format: 'detailed_resource', node_type: 'detailed_resource', format: key};
      draw_cytoscape_node(hash);
    });
    vis.removeNode(clicked_node);
  }, "json");
}

function add_listeners() {
  vis.addListener("click", "nodes", function(evt) {
    var node = evt.target;
    if (node.data.format === 'resource') {
      get_resource_count_hash(node);
    } else if (node.data.node_type === 'detailed_resource') {
      alert("Detailed Node " + node.data.id + " was clicked");
    }
  });

  $(".cyto").mouseover( function() {
    var ontology_term_id = $(this).attr('ontology_term_id');
    var bypass = { nodes: { } };
    var props = { size: 100, labelFontSize: 24 };
    vis.deselect("nodes");
    vis.select("nodes", [ontology_term_id]);
    var obj = vis.selected()[0];
    if (obj) {
      bypass[obj.group][obj.data.id] = props;
      vis.visualStyleBypass(bypass);
    }
  }).mouseout( function() {
    var ontology_term_id = $(this).attr('ontology_term_id');
    vis.deselect("nodes", [ontology_term_id]);
    vis.visualStyleBypass(null);
  });

}

// set for merb/rails to get that we're using JS
$(function() {

  // display the loading graphic during ajax requests
  $("#loading").ajaxStart(function(){
     $(this).show();
   }).ajaxStop(function(){
     $(this).hide();
   });

   // make sure we accept javascript for ajax requests
  jQuery.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");}});


  $(".cloud_pagination a").live("click", function(){
    var href = $(this).attr('href');
    $.get(href, {}, function(data){}, "script");
    return false;
  });

  $(".data_pagination a").live("click", function(){
    var href = $(this).attr('href');
    var dtable = $(this).closest('.dataTable');
    var atype = dtable.attr('atype');
    $.get(href, {'annotation_type' : atype}, function(data) { dtable.html(data); }, 'script');
    return false;
  });

  $(".cloud-box-content").allMatchTallestHeight();

  $(".view-graph").live("click", function(){
    $(".bar-graph").toggle();
  });

  $("div.tooltip").hover( function() {
      $(this).find('.popup').show();
    },
    function() {
      $(this).find('.popup').hide();
  });

  $("a.annotation-term").mouseover( function() {
    $(this).addClass("inset");
    if ($('#'+$(this).attr("field_name")).length > 0) {
      var from = $(this).attr('from')-1;
      var to = $(this).attr('to');
      var text = $.trim(Utf8.encode($('#'+$(this).attr("field_name")).html())).slice(from, to);
      $('#'+$(this).attr("field_name")).highlight(text);
    }
  }).mouseout( function() {
    $(this).removeClass("inset");
    if ($('#'+$(this).attr("field_name")).length > 0) {
      $('#'+$(this).attr("field_name")).removeHighlight();
    }
  });

  $("#loading").ajaxStart(function(){
     $(this).show();
   }).ajaxStop(function(){
     $(this).hide();
   });

// dynamically load the items based on query filter

  $("#ddown").bind("change", filter_submit);
  $("#status").bind("change", filter_submit);
  $("#geotype").bind("change", filter_submit);
  $("#exclude").bind("change", filter_submit);
  $("#has_predicate").bind("change", filter_submit);
  $("#query").keypress(function(e) {
    if (e.which !== 0 && e.charCode !== 0) {
      delayKey();
    }
  });

  $("#query").keyup(function(e) {
    if (e.keyCode === 8 || e.keyCode === 46) {
      delayKey();
    }
  });
  
  $("#refresh").bind("click", filter_submit);

  attach_term_hook();
  attach_filter_hook();

  $("#toggle-cytoscape").click(function(){
    var cywin = $("#cytoscapeweb");
    if( cywin.height() === 0 ) {
      cywin.height(500);
      cywin.css("border", "1px solid #000");
      $('#toggle-cytoscape').html("Hide cytoscape");
    } else {
      cywin.height(0);
      cywin.css("border", "none");
      $('#toggle-cytoscape').html("Show cytoscape");
    }
  });

  $(".annotation-table:has(a)").show();

  if ($("#cytoscapeweb").length > 0) {
    get_geo_item_cytoscape_data($("#cytoscapeweb").attr('geo_accession'));
    add_listeners();
  }

});

