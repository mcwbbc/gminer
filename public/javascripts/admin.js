function markValid(object) {
  object.removeClass("unaudited unverified predicate-text predicate-tissue predicate-").addClass("verified");
}

function markInvalid(object) {
  object.removeClass("unaudited verified predicate-text predicate-tissue predicate-").addClass("unverified");
}

function updateCSS(data, object) {
  if (data.result) {
    markValid(object);
    set_annotation_css(object, data.css_class);
  } else {
    markInvalid(object);
  }
  set_bindings();
}

function load_curators() {
  $("#top-curators").load('/annotations/top_curators');
}

function set_annotation_css(element, css_class) {
  element.removeClass('predicate-text predicate-tissue predicate-').addClass(css_class);
}

function bindCurate() {
  // updates the clicked link's curation status
  $("a.curate").unbind('click.curate').bind('click.curate', function() {
    var link = $(this);
    var href = link.attr("href");
    if (link.hasClass('automatic-annotation')) {
      $.post(href, {}, function(data) {
        updateCSS(data, link);
        load_curators();
        if ($("#cytoscapeweb").length > 0) {
          get_geo_item_cytoscape_data($("#cytoscapeweb").attr('geo_accession'));
        }
      }, "json");
    }
    return false;
  });
}

function bindRightClicks() {
  $("a.curate.manual-annotation").contextMenu({
    menu: 'delete-menu'
  },
  function(action, el, pos) {
    var id = $(el).attr("id").split('-')[1];
    if (action === 'delete') {
      var row;
      var href = "/annotations/"+id;
      $(el).next().remove();
      if ($(el).siblings().size() === 0) {
        row = $(el).parent().parent().parent();
      }
      $(el).remove();
      if (row) {
        $(row).remove();
      }
      $.post(href, "_method=delete", function(data){
        displayResult(data);
        load_curators();
      }, "json");
    } else {
      set_bindings();
    }
    return false;
  });
  
  $("a.curate.automatic-annotation.verified").contextMenu({
    menu: 'annotation-type-menu'
  },
  function(action, el, pos) {
    if ($(el).hasClass('verified')) {
      var id = $(el).attr("id").split('-')[1];
      $.post("/annotations/"+id+'/predicate', {predicate: action, format: 'js'}, function(data){
        updateCSS(data, $(el));
        load_curators();
      }, "json");
    }
    return false;
  });
}

function set_bindings() {
  bindCurate();
  bindRightClicks();
}

function setBoxes(status) {
  var boxes = $(":checkbox[name='selected_annotations[]']");
  boxes.each(function() {
    $(this).attr('checked', status);
  });
}

function processChecked(isValid) {
  var boxes = $(":checkbox[name='selected_annotations[]']:checked");
  boxes.each(function() {
    var link = $("#link-"+$(this).val());
    if (isValid) {
      markValid(link);
    } else {
      markInvalid(link);
    }
    $(this).remove();
  });
  return boxes;
}

function scroll_curators() {
  var menuYloc = parseInt($('#top-curators').css("top").substring(0,$('#top-curators').css("top").indexOf("px")), 10);
  $(window).scroll(function () {
    var offset = menuYloc+$(document).scrollTop()+"px";
    $('#top-curators').animate({top:offset},{duration:500,queue:false});
  });
}

$(function() {

  $(".annotation-status").live("click", function(e){
    var geo_accession = $(this).closest('.box').attr("geo_accession");
    var status = $(this).attr("status");
    $.post('/platforms/skip_annotations', { status: status, geo_accession: geo_accession }, function(data){}, "script");
    return false;
  });

  $("a.geo-audit-link").live("click", function(e){
    var id = $(this).attr("id");
    var row = $(this).closest('tr');
    row.siblings('tr').removeClass('highlight');
    row.addClass('highlight');
    var top = ($('#container').position().top+50);
    $('#right').load('/annotations/'+id+'/geo_item', function() {
      $('#right').css('top', (e.pageY-top));
    });
    return false;
  });

  if ($('#tag_list').length > 0) {
    $('#tag_list').autocompleteArray(tags_json, { autoFill:true });
  }

  $("a.delete-tag").live("click", function(){
    var tag_name = $(this).attr("tag_name");
    var geo_accession = $(this).closest('#tags').attr("geo_accession");
    $.post('/tags/delete_for', { tag_list: tag_name, geo_accession: geo_accession, format: 'js' }, function(data){}, "script");
    return false;
  });

  $("a.add-tag").live("click", function(){
    var tag_name = $(this).attr("tag_name");
    var geo_accession = $(this).closest('#tags').attr("geo_accession");
    $.post('/tags/create_for', { tag_list: tag_name, geo_accession: geo_accession, format: 'js' }, function(data){}, "script");
    return false;
  });

  $("#tag-form").submit(function(){
    $.post('/tags/create_for', $(this).serialize(), function(data){}, "script");
    $(this)[0].reset();
    return false;
  });


  $("#show").live("click", function(){
    $(this).hide();
    $(this).next().show();
    return false;
  });

  $("#hide").live("click", function(){
    $(this).parent().hide();
    $(this).parent().prev().show();
    return false;
  });

  $("input.cancel").live("click", function(){
    $("#new-annotation").hide();
    return false;
  });

// marks all the checked boxes as valid, and removes the checkboxes from the form
  $("span.validate-all").live("click", function(){
    var boxes = processChecked(true);
    $.post('/annotations/mass_curate', boxes.serialize()+"&verified=1", function(data){
      filter_submit();
      load_curators();
    }, "json");
    return false;
  });

  $("span.invalidate-all").live("click", function(){
    var boxes = processChecked(false);
    $.post('/annotations/mass_curate', boxes.serialize()+"&verified=0", function(data){
      filter_submit();
      load_curators();
    }, "json");
    return false;
  });

  $("a.check-all").live("click", function(){
    setBoxes(true);
    return false;
  });

  $("a.uncheck-all").live("click", function(){
    setBoxes(false);
    return false;
  });

  $(".context").live("click", function(){
    $(this).children("div").toggle();
    return false;
  });

  $("#new_job select#job_ontology_id").change(function(){
    $.post("/jobs/update_job_form", $("#new_job").serialize(), function(html) {
      $(".fields").html(html);
    });
  });

  $("#new_job select#job_geo_type").change(function(){
    $.post("/jobs/update_job_form", $("#new_job").serialize(), function(html) {
      $(".fields").html(html);
    });
  });

  bindCurate();
  bindRightClicks();

  if ($('#top-curators').length > 0) {
    load_curators();
    scroll_curators();
  }

});

