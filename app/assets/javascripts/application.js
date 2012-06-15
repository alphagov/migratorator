// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require jquery_nested_form
//= require chosen.jquery
//= require bootstrap.min

$( function() {
  $('.pagination a[data-remote="true"]').live( 'click', function(){
    var page_number = $(this).attr('href').match(/\/page\/(\d+)/);
    history.pushState({ page: page_number }, "", $(this).attr('href'));
    $(this).parents('.pagination').children('span.current').addClass('disabled');
    $(this).parent('span').addClass('current').html($(this).text());
    $('tbody#mappings').css('opacity','0.5');
  });
});
