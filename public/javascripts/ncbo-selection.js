$(function() {
//  rightClickMenu();

  $("#new_annotation").bind("submit", submit_annotation);

  $("input#annotation_cancel").bind("click", function(){
    $("#new-annotation").hide();
    return false;
  });

  $("#dataTable span").contextMenu({
      menu: 'annotation-menu'
    },
    function(ontology, el, pos) {
      var txt = getSelectedText();
      if (txt != '') {
        hash = getSelectedInformation(txt, el);
        $('#new-annotation').css({top: 375, left: 350});
        ontology_class = "bp_form_complete-"+ontology+"-shortid"
        $("input#annotation_ncbo_term_id").removeClass();
        $("input#annotation_ncbo_term_id").addClass(ontology_class);
        unbindEvents();
        setup_functions();
        $("input#annotation_ncbo_term_id").val(hash['text']);
        $("input#annotation_ncbo_id").val(ontology);
        $("input#annotation_from").val(hash['from']);
        $("input#annotation_to").val(hash['to']);
        $("input#annotation_field").val(hash['field']);
        $("#new-annotation").show();
        $("input#annotation_ncbo_term_id").focus();
        $("input#annotation_ncbo_term_id").keydown();
      }
      return false;
    });
});

function unbindEvents() {
  $("input[class*='bp_form_complete']").each(function(){
    $(this).unbind();
  });
}

function submit_annotation() {
  $.post("/annotations", $("#new_annotation input").serialize(), function(data){ process_create(data) }, "json");
  $("#new-annotation").hide();
  return false;
}

function process_create(data) {
  $("#annotation-result").removeClass();
  $("#annotation-result").addClass(data['status']);
  $("#annotation-result").text(data['message']);
  $("#annotation-result").fadeIn("slow").fadeTo(2000, 1).fadeOut("slow");
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

function getSelectedInformation(txt, element) {
  txt = txt.toString()
  text = jQuery.trim(txt);
  length = text.length;
  full = jQuery.trim($(element).text());
  field = $(element).attr("id");
  start = full.indexOf(text)
  end = start+length;
	return {'from':start, 'to':end, 'text':text, 'field':field};
};

/* create sniffer */
$(document).ready(function() {
	var url = 'http://davidwalsh.name/?s={term}', selectionImage;
	$('#content-area').mouseup(function(e) {
		var selection = getSelected();
		if(selection && (selection = new String(selection).replace(/^\s+|\s+$/g,''))) {
			//ajax here { http://davidwalsh.name/text-selection-ajax }
			if(!selectionImage) {
				selectionImage = $('<a>').attr({
					href: url,
					title: 'Click here to learn more about this term',
					target: '_blank',
					id: 'selection-image'
				}).hide();
				$(document.body).append(selectionImage);
			}
			selectionImage.attr('href',url.replace('{term}',encodeURI(selection))).css({
				top: e.pageY - 30,	//offsets
				left: e.pageX - 13 //offsets
			}).fadeIn();
		}
	});
	$(document.body).mousedown(function() {
		if(selectionImage) { selectionImage.fadeOut(); }
	});
});