function getSelectedInformation(txt, element) {
  txt = txt.toString();
  text = jQuery.trim(txt);
  len = text.length;
  full = jQuery.trim($(element).text());
  field_name = $(element).attr("id");
  start = full.indexOf(text)+1;
  end = start+len-1;
  return {'from':start, 'to':end, 'text':text, 'field_name':field_name};
}

function displayResult(data) {
  $("#annotation-result").removeClass();
  $("#annotation-result").addClass(data.status);
  $("#annotation-result").text(data.message);
  $("#annotation-result").fadeIn("slow").fadeTo(2000, 1).fadeOut("slow");
  $(".annotation-table:not(:has(a))").hide();
  $(".annotation-table:has(a)").show();
  bindCurate();
  bindRightClicks();
}

function getSelectedText() {
  var txt = '';
  if (window.getSelection) {
    txt = window.getSelection();
  // FireFox
  } else if (document.getSelection) {
    txt = document.getSelection();
  // IE 6/7
  } else if (document.selection) {
    txt = document.selection.createRange().text;
  }
  return txt;
}

function unbindEvents() {
  $("input[class*='bp_form_complete']").each(function(){
    $(this).unbind();
  });
}

function submit_annotation() {
  $.post("/annotations", $("#new_annotation input").serialize(), function() {
    load_curators();
  }, "script");
  return false;
}

$(function() {
//  rightClickMenu();

  $("#new_annotation").bind("submit", submit_annotation);

  $("input#annotation_cancel").bind("click", function(){
    $("#new-annotation").hide();
    return false;
  });

  $(".dataTable span").contextMenu({
      menu: 'annotation-menu'
    },
    function(ontology, el, pos) {
      var txt = getSelectedText();
      if (txt != '') {
        hash = getSelectedInformation(txt, el);
        $('#new-annotation').css({top: (pos.docY-125), left: (pos.docX-250)});
        ontology_class = "bp_form_complete-"+ontology+"-shortid";
        $("input#annotation_ncbo_term_id").removeClass();
        $("input#annotation_ncbo_term_id").addClass(ontology_class);
        unbindEvents();
        setup_functions();
        $("input#annotation_ncbo_term_id").val(hash.text);
        $("input#annotation_ncbo_id").val(ontology);
        $("input#annotation_from").val(hash.from);
        $("input#annotation_to").val(hash.to);
        $("input#annotation_field_name").val(hash.field_name);
        $("#new-annotation").show();
        $("input#annotation_ncbo_term_id").focus();
        $("input#annotation_ncbo_term_id").keydown();
      }
      return false;
    });
});