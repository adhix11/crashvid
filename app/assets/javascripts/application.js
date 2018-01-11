// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require datetimepicker
//= require twitter/bootstrap
//= require tag-it
//= require_tree
/*
$("#sign_in").click(function(){
	var requestURL = "/users/sign_in";
	var request_data = {"user":{"email":$("#sign_in_user").val(),"password":$("#sign_in_pass").val(),"remember_me":1}}
    $.ajax({
    	url: requestURL,
    	data: request_data,
    	type: "POST",
    	dataType: 'json',
    	beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
     	success: function(result){
     		$(".user-dropdown").html( 'Welcome <span>'+result.email+'</span><span class="caret"></span>' );
     		$(".user > div").toggleClass("hidden");
     		$('meta[name="csrf-token"]').attr('content', result.csrf);
    }});
});*/

// For Cart
function toggle_panel_visibility ($lateral_panel, $background_layer, $body) {
  if( $lateral_panel.hasClass('speed-in') ) {
    // firefox transitions break when parent overflow is changed, so we need to wait for the end of the trasition to give the body an overflow hidden
    $lateral_panel.removeClass('speed-in').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function(){
      $body.removeClass('overflow-hidden');
    });
    $background_layer.removeClass('is-visible');

  } else {
    $lateral_panel.addClass('speed-in').one('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function(){
      $body.addClass('overflow-hidden');
    });
    $background_layer.addClass('is-visible');
  }
}

$(document).ready(function(){

  /* cart page */
  var $L = 1200,
  $menu_navigation = $('.cv-navbar'),
  $cart_trigger = $('#cd-cart-trigger'),
  $hamburger_icon = $('#cd-hamburger-menu'),
  $lateral_cart = $('#cd-cart'),
  $shadow_layer = $('#cd-shadow-layer'); 


  //open cart
  $cart_trigger.on('click', function(event){
    event.preventDefault();
    //close lateral menu (if it's open)
    toggle_panel_visibility($lateral_cart, $shadow_layer, $('body'));
  });
  
  //close lateral cart or lateral menu
  $shadow_layer.on('click', function(){
    $shadow_layer.removeClass('is-visible');
    // firefox transitions break when parent overflow is changed, so we need to wait for the end of the trasition to give the body an overflow hidden
    if( $lateral_cart.hasClass('speed-in') ) {
      $lateral_cart.removeClass('speed-in').on('webkitTransitionEnd otransitionend oTransitionEnd msTransitionEnd transitionend', function(){
        $('body').removeClass('overflow-hidden');
      });
    } else {
      $lateral_cart.removeClass('speed-in');
    }
  });
  
});

