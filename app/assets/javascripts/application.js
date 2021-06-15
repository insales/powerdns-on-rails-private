//= require jquery3
//= require rails-ujs
//= require 'jquery.tipTip'
//= require 'humane'

// TODO: bootstrap may need Popper
//= require bootstrap-global-this-define
//= require bootstrap/dom/data
//= require bootstrap/dom/event-handler
//= require bootstrap/base-component
//= require bootstrap/dom/manipulator
//= require bootstrap/dom/selector-engine
// require bootstrap/dropdown
// require bootstrap/scrollspy
//= require bootstrap/alert
//= require bootstrap/collapse
// require bootstrap/toast
// require bootstrap/tooltip
// require bootstrap/offcanvas
// require bootstrap/popover
// require bootstrap/button
// require bootstrap/modal
// require bootstrap/tab
// require bootstrap/carousel
//= require bootstrap-global-this-undefine

$(document).ready(function() {
  // AJAX activity indicator
  $('body').append('<div id="ajaxBusy"><img src="/images/loading.gif"> Processing</div>');

  // Setup tooltips where required
  $('.help-icn').each(function(i, icon){
    $(icon).tipTip({
      content: $( "#" + $(icon).data("help") ).text()
    });
  });

  // Used by the new record form
  $('#record-form #record_type').change(function() {
    toggleRecordFields( $(this).val() );
  });

  // Used by the new domain form
  $('#domain_type').change(function() {
    if ( $(this).val() == 'SLAVE' ) {
      $('#master-address').show();
      $('#zone-templates').hide();
      $('#no-template-input').hide();
    } else {
      $('#master-address').hide();
      $('#zone-templates').show();
      $('#no-template-input').show();
    }
  });

  // Used by the new domain form
  $('#domain_zone_template_id').change(function() {
    if ( $(this).val() == '' ) {
      $('#no-template-input').show();
    } else {
      $('#no-template-input').hide();
    }
  });

  // Used by the new record template form
  $('#record-form #record_template_record_type').change(function() {
    toggleRecordFields( $(this).val() );
  });

  // Used by the new macro step form
  $('#record-form #macro_step_record_type').change(function() {
    toggleRecordFields( $(this).val() );
  });

});

$(document).on('click', '[data-form-submit]', function(e) {
  e.preventDefault();
  var form;
  if(e.target.getAttribute('form')) {
    form = document.findElementById(e.target.getAttribute('form'));
  } else {
    form = $(this).closest('form')[0];
  }
  Rails.fire(form, 'submit');
  // .trigger('submit.rails');
});

// Ajax activity indicator bound to ajax start/stop document events
$(document).ajaxStart(function(){
  $('#ajaxBusy').show();
}).ajaxStop(function(){
  $('#ajaxBusy').hide();
});
