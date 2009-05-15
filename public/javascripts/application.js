// Common JavaScript code across your application goes here.

// set for merb/rails to get that we're using JS
$(function() {
  jQuery.ajaxSetup({ 
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
  })
});

$(function() {
  $("a.annotation-term").mouseover( function() {
    $('#'+$(this).attr("field")).highlight($(this).html());
  }).mouseout( function() {
    $('#'+$(this).attr("field")).removeHighlight();
  });

  $("#loading").ajaxStart(function(){
     $(this).show();
   }).ajaxStop(function(){
     $(this).hide();
   });
});

$(function() {
  $("a.curate").live("click", function(){
    link = $(this);
    href = link.attr("href");
    $.post(href, {}, function(data){ updateCSS(data, link) }, "json");
    return false;
  });
});

function updateCSS(data, object) {
  if (data.result) {
    object.removeClass("unverified");
    object.addClass("verified");
  } else {
    object.removeClass("verified");
    object.addClass("unverified");
  }
}

function filter_submit() {
  var m = {};
  m._method = "get";
  
  if ($("#ddown").length > 0) {
    m.ddown = $("#ddown").val();
  }

  if ($("#query").length > 0) {
    m.query = $("#query").val();
  }

  $("#dataTable").load(window.location.pathname, m);
}

// dynamically load the items based on query filter
$(function() {
  $("#ddown").bind("change", filter_submit);
  $("#query").bind("keyup", filter_submit);
});

$(function() {
  attach_term_hook();
  attach_results_hook();
  attach_filter_hook();
});

function attach_results_hook() {
  $('table.paginated').each(function() {
      var $table = $(this);
      repaginate(0, $table);
      var numRows = $table.find('tbody tr').length;
      var $pager = $('<div class="digg_pagination"></div><br />')
      $pager.insertBefore($table)
      $pager.pagination(numRows, {
      	items_per_page: 10,
      	num_edge_entries: 2,
      	element: $table,
      	callback: repaginate
      });
  });
}

function repaginate(current_page, element) {
  var numPerPage = 10;
  var start = current_page * numPerPage;
  var end = (current_page + 1) * numPerPage;
  element.find('tbody tr')
  .slice(start, end).show().end()
  .slice(0, start).hide().end()
  .slice(end).hide().end()
  return false;
}

function attach_term_hook() {
  $("a.result-term").live("click", function(){
    term_id = $(this).attr("term_id");
    term_name = $(this).html();
    add_parameter_field(term_id, term_name);
    update_filter_text();
    update_results();
    return false;
  });
}

function attach_filter_hook () {
  $("a.delete-result").live("click", function(){
    remove_parameter_field($(this).attr("term_id"))
    update_filter_text();
    update_results();
    return false;
  });
}

function remove_parameter_field(term_id) {
  terms = $("#term-parameters :hidden")
  terms.each( function() { 
    if ($(this).attr("id") == term_id) {
      $(this).remove();
    }
  });
}

function update_filter_text() {
  terms = $("#term-parameters :hidden")
  var term_array = new Array();
  terms.each( function() { 
    term_name = $(this).attr("term_name");
    term_id = $(this).attr("id");
    link = "<a href='#' class='delete-result' term_id='"+term_id+"'><img src='/images/icons/error.png' border='0' class='delete-icon' /></a><span class='result-filter'>"+term_name+"</span>"
    term_array.push(link)
  });

  term_string = term_array.join(" AND ");
  $("#filters").html(term_string);
}

function add_parameter_field(term_id, term_name) {
  var element = document.createElement("input");  
  element.setAttribute("type", "hidden");  
  element.setAttribute("value", term_id);
  element.setAttribute("id", term_id);
  element.setAttribute("name", "term_array[]");
  element.setAttribute("term_name", term_name);
  $("#term-parameters").append(element);  
}

function update_results() {
  $.get("/annotations/cloud", $("#term-parameters>:input").serialize(), function(data){ attach_results_hook(); }, "script");
}