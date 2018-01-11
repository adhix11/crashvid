// Place all the behaviors and hooks related to the matching controller here.

// All this logic will automatically be available in application.js.

function stripeResponseHandler(status, response) {
  var $form = $('#payment-form');
  if (response.error) { // Problem!
    $form.find('.payment-errors').text(response.error.message);
    $form.find('.submit').prop('disabled', false);
  } else {
    var token = response.id;
    $form.append($('<input type="hidden" name="stripeToken">').val(token));
    $form.get(0).submit();
  }
};

$("#search_date_of_occurence").datetimepicker({
  maxDate: 0,
  step: 30,
  timepicker:false,
  format:'d M Y',
  defaultDate:new Date(),
  onClose:function(ct,$i){
    search_api();
  }
});

function formatDate(date) {
  var monthNames = [
    "Jan", "Feb", "Mar",
    "Apr", "May", "Jun", "Jul",
    "Aug", "Sep", "Oct",
    "Nov", "Dec"
  ];

  var day = date.getDate();
  var monthIndex = date.getMonth();
  var year = date.getFullYear();

  return day + ' ' + monthNames[monthIndex] + ' ' + year;
}
//Google maps Initialization

//Variable Initialization
var markersArray = [];
var map;
var infowindow; 
if(sessionStorage.zoomLevel){
  var zoom = parseInt(sessionStorage.zoomLevel);
}
else{
  var zoom = 10; 
}
var sliderFlag = false;

// $("#search_date_of_occurence,.fa-calendar").val(formatDate(new Date()))
function search_api() {
    
    //$("#search").submit();
    var requestUrl = "/search_api";
    var requestData = $("#search").serializeArray();
   
    //console.log(requestData);
        $.ajax({
            url: requestUrl,
            data: requestData,
            
            success:function(result){
             // console.log();
             //alert(result[2]);
             //result[0] - [lat, lng] | result[1] - [markers] | result[2] - [cameras]
              
              ajaxCallMapRequest(result[0], result[1], result[2], result[3][0]);
            }
          });
    
};

$('#search').keypress(function (e) {
 var key = e.which;
 if(key == 13)  // the enter key code
  {
    var requestUrl = "/search_api";
    var requestData = $("#search").serializeArray();

    //console.log(requestData);
        $.ajax({
            url: requestUrl,
            data: requestData,
            
            success:function(result){
             // console.log();
             //alert(result[2]);
             //result[0] - [lat, lng] | result[1] - [markers] | result[2] - [cameras]

              ajaxCallMapRequest(result[0], result[1], result[2], result[3][0]);
            }
          });
  }
}); 
// Google maps autocomple

location_id  = $("#location")
location_id_mobile = $("#location_mobile")

if (location_id.length > 0){
  location_id.autocomplete({
    source : '/places',
    minLength : 2,
    select: function( event, ui ) {
      $("#place_id").val(ui.item.place_id);
      $("#location").val(ui.item.description);
      search_api();
      return false;
    }
  }).autocomplete( "instance" )._renderItem = function( ul, item ) {
    return $( "<li>" )
      .append( "<div>" + item.description + "<br>" )
      .appendTo( ul );
  };
}
if (location_id_mobile.length > 0){
  location_id_mobile.autocomplete({
    source : '/places',
    minLength : 2,
    select: function( event, ui ) {
      $("#place_id").val(ui.item.place_id);
      $("#location_mobile").val(ui.item.description);
      $("#location").val(ui.item.description);
      search_api();
      return false;
    }
  }).autocomplete( "instance" )._renderItem = function( ul, item ) {
    return $( "<li>" )
      .append( "<div>" + item.description + "<br>" )
      .appendTo( ul );
  };
}

if(gon.markers_location && gon.camera_markers_location)
{
  var markers = gon.markers_location;
 
  var cameras = gon.camera_markers_location;

}
else
{
  var markers = null;
  var cameras = null;
  console.log("markers location and camera markers location is null");
}

function ajaxCallMapRequest(position, markers, cameras, flag)
{

  var markers = markers;
  var cameras = cameras;
  console.log("Ajaxcall");
  //console.log(flag[0]);
  if(flag == true)
  {
    console.log(position);
    var position = {latitude: position[0], longitude: position[1]};
    panMapTo(position);
  }
   
  setMarkers(map, markers);
}
// position = {latitude: value, longitude: value}
function panMapTo(position)
{
  var pos = new google.maps.LatLng(position.latitude, position.longitude);
  map.panTo(pos);
  //map.setZoom(zoom);
}


// position = {latitude: value, longitude: value}
function mapSetPosition(position)
{
    
    if(parseInt(sessionStorage.mapCenterlat)){
      var pos = new google.maps.LatLng(sessionStorage.mapCenterlat, sessionStorage.mapCenterlng); 
    }else{
      var pos = new google.maps.LatLng(position.latitude, position.longitude);
    }
    map.setCenter(pos);
    map.setZoom(zoom);
}

//set Markers. markers - list of all markers from database retrieved via gon variable. map - current map variable
function setMarkers(map, markers) {

    for (var i = 0; i < markersArray.length; i++) {
      markersArray[i].setMap(null);
    }
    markersArray = [];

    for (var i in markers) {
      var id = markers[i][0];
      var name = markers[i][1];
      var lat = markers[i][2];
      var lng = markers[i][3];
      var no_of_videos = markers[i][5];
      var latlngset;
      latlngset = new google.maps.LatLng(lat, lng);
      if (id!=0){
        if(no_of_videos!=0 ){
          var created_marker = new google.maps.Marker({
            map: map,
            position: latlngset,
            id: id,
            icon: 'assets/camera_icon_video.svg'
          });
        }
        else{
          var created_marker = new google.maps.Marker({
            map: map,
            position: latlngset,
            id: id,
            icon: 'assets/camera_icon_empty.png'
          });
        }
        
        markersArray.push(created_marker);

      google.maps.event.addListener(created_marker, 'click', (function(marker, i) {
        return function() {
        if (infoWindow) {
          infoWindow.close();
        }
        if(marker.id == 0){
          var position = new google.maps.LatLng(marker.position.lat(),marker.position.lng());
          var geocoder = new google.maps.Geocoder;
          geocoder.geocode({'location': position},function(result){
            place = result[0];
            var place_formatted_address = place.formatted_address
            var place_id = place.place_id
            var content;
            content='<p>'+place_formatted_address+'</p><div class="info-window"><span class=""><a href="/events/new" id="request_video" class="btn btn-default btn-block" data-remote=true>Request Video</a></span><span class=""><a href="/upload_video" id="upload_video" class="btn btn-default btn-block" data-remote=true>Upload Video</a></span></div><input type="hidden" id="hidden_lat" value='+marker.position.lat()+' /> <input type="hidden" id="hidden_lng" value='+marker.position.lng()+' /> <input type="hidden" id="hidden_address" value=" '+place_formatted_address+'" /><input type="hidden" id="hidden_place_id" value='+place_id+' /> ';
            infoWindow = new google.maps.InfoWindow({
              position: position,
              content: content      
            });
            infoWindow.open(map)

          });
        }
        else{
          sessionStorage.marker_id = marker.id;
          var $requestUrl;
          requestUrl = "/events/"+marker.id+"/videos";
          var subscribeUrl = "subscribe/"+marker.id ;
          var $hrefUrl;
          hrefUrl= "/event_videos/new/"+marker.id          
          

          $.ajax({
            url: requestUrl,
            dataType: 'script',
            async:false,
            success:function(result){
            
              $('.right-slider').hide();
              sliderFlag = true;
              $('.video-list-slider').show('slide', {direction: 'right'}, 500);
              $("#event_upload_video").attr('href',hrefUrl);
            

            }
          });
        }
        }
      })(created_marker, i));
      }
    }
    /*var options = {
            imagePath: 'assets/cluster'
        };

    var markerCluster = new MarkerClusterer(map, markersArray, options);*/

    var infoWindow = new google.maps.InfoWindow(), cam_marker, i;
    for(i in cameras ){
      var id = cameras[i][0];
      var name = cameras[i][1];
      var lat = cameras[i][2];
      var lng = cameras[i][3];
      var latlngset;
      latlngset = new google.maps.LatLng(lat, lng);
      cam_marker = new google.maps.Marker({
          map: map,
          position: latlngset,
          id: id,
          icon: 'assets/camera_icon_camera.svg',
        });

/*      google.maps.event.addListener(cam_marker, 'click', (function(cam_marker, i) {
        return function() {
              if (infoWindow) {
                infoWindow.close();
              }
              
              var position = new google.maps.LatLng(cam_marker.position.lat(),cam_marker.position.lng());
                var geocoder = new google.maps.Geocoder;
                geocoder.geocode({'location': position},function(result){
                  place = result[0];
                  var place_formatted_address = place.formatted_address;
                  var place_id = place.place_id;
                  var lat = position.lat;
                  var lng = position.lng ;
                  var id = cam_marker.id;
                  var content;
                  if(gon.user_signed_in)
                    content='<div class="info-window"><span class="col-md-12 col-sm-12"><a href="/upload_video" id="upload_video" class="btn btn-default btn-block" data-remote=true>Upload Video</a></span><br><span class="col-md-6 col-sm-12"><a href="/events/new" id="request_video" class="btn btn-outline btn-block" data-remote=true>Request Video</a></span><span class="col-md-6 col-sm-12"><a href="/delete_static_camera" id="static_camera" class="btn btn-outline btn-block" data-remote=true>Remove Camera</a></span></div><input type="hidden" id="hidden_lat" value='+lat+' /> <input type="hidden" id="hidden_lng" value='+lng+' /> <input type="hidden" id="hidden_address" value=" '+place_formatted_address+'" /><input type="hidden" id="hidden_place_id" value='+place_id+' /><input type="hidden" id="hidden_marker_id" value='+id+' /> ';
                  else
                    content='<div class="info-window"><span class="col-md-12 col-sm-12"><a data-toggle="modal" href="#login" id="upload_video" class="btn btn-default btn-block" >Upload Video</a></span><br><span class="col-md-6 col-sm-12"><a data-toggle="modal" href="#login" id="request_video" class="btn btn-outline btn-block" >Request Video</a></span><span class="col-md-6 col-sm-12"><a data-toggle="modal" href="#login" id="static_camera" class="btn btn-outline btn-block" >Remove Camera</a></span></div><input type="hidden" id="hidden_lat" value='+lat+' /> <input type="hidden" id="hidden_lng" value='+lng+' /> <input type="hidden" id="hidden_address" value=" '+place_formatted_address+'" /><input type="hidden" id="hidden_place_id" value='+place_id+' /> ';
                infoWindow.setContent(content);
                infoWindow.open(map, cam_marker);
                });
            }
        })(cam_marker, i));*/
    } 
  }

function initMap() {
//console.log("first");
  var myOptions = {
    zoom: zoom,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    disableDefaultUI: true,
    zoomControl: true,
    minZoom: 3
};
  

//console.log("initmap");
  map = new google.maps.Map(document.getElementById('map_canvas'), myOptions);

//console.log(map);
  google.maps.event.addListenerOnce(map, 'idle', function(){
    // do something only the first time the map is loaded
      //Auto set location if there is no search request. (gon.search_flag = true) in case of search request
      if(!gon.search_flag)
      {
        if (navigator.geolocation) {
         navigator.geolocation.getCurrentPosition(displayPosition, displayError, { enableHighAccuracy: true});
         console.log("navigator");
        } 
        else {

          //alert('Geolocation is not supported in your browser');
        }
      }
      
      //function for navigator
      function displayPosition(position) {
        if(parseInt(sessionStorage.mapCenterlat)){
          var pos = new google.maps.LatLng(sessionStorage.mapCenterlat, sessionStorage.mapCenterlng); 
        }else{
          var pos = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
        }
          map.setCenter(pos);
        if(sessionStorage.zoomLevel){
          map.setZoom(parseInt(sessionStorage.zoomLevel));
        }
        else{
          map.setZoom(15);
        }
      }
      function displayError(error) {
        var errors = { 
          1: 'Permission denied',
          2: 'Position unavailable',
          3: 'Request timeout'
        };
        console.log("Error: " + errors[error.code]);
        console.log("IP");
        var position = {latitude: gon.latitude, longitude: gon.longitude};
        console.log(position);
        mapSetPosition(position);
        
      }
      //navigatior function end
      infoWindow = new google.maps.InfoWindow();
      if(sessionStorage.infoWindow_content_signedin){
        var pos = new google.maps.LatLng(sessionStorage.infoWindow_position_lat, sessionStorage.infoWindow_position_lng);
        if(gon.user_signed_in)
          content=sessionStorage.infoWindow_content_signedin;
        else
          content=sessionStorage.infoWindow_content_signedout;

        infoWindow = new google.maps.InfoWindow({
          position: pos,
          content: content     
        });
        infoWindow.open(map);
        sessionStorage.removeItem("infoWindow_content");
        sessionStorage.removeItem("infoWindow_position");
        sessionStorage.removeItem("infoWindow_content_signedin");
        sessionStorage.removeItem("infoWindow_content_signedout");
      }
      if(sessionStorage.marker_id){
          var id = parseInt(sessionStorage.marker_id);
          var $requestUrl;
          requestUrl = "/events/"+id+"/videos";
          var subscribeUrl = "subscribe/"+id ;
          var $hrefUrl;
          hrefUrl= "/event_videos/new/"+id          
          

          $.ajax({
            url: requestUrl,
            dataType: 'script',
            async:false,
            success:function(result){
            
              $('.right-slider').hide();
              sliderFlag = true;
              $('.video-list-slider').show('slide', {direction: 'right'}, 500);
              $("#event_upload_video").attr('href',hrefUrl);
            }
          });
        sessionStorage.removeItem("marker_id");
      }
      setMarkers(map, markers);
  });

 
  //map event listener
  google.maps.event.addListener(map, "click", function(e) {

    // $('.alert-message').hide('slide',{direction:'up'},500);

    if(sliderFlag){
      sliderFlag = false;
      $('.video-list-slider').hide('slide', {direction: 'right'}, 500);
      if(sessionStorage.marker_id){
        sessionStorage.removeItem("marker_id");
      }
    }
    else{
      var location = e.latLng;
      //map.setZoom(8);
      //map.panTo(e.latLng);
      if (infoWindow) {
        infoWindow.close();
      }
      var position = {lat: location.lat(), lng: location.lng()};
      var geocoder = new google.maps.Geocoder;
      var place;
      geocoder.geocode({'location': position},function(result){
        place = result[0];
        var place_formatted_address = place.formatted_address
        var place_id = place.place_id
        var lat = position.lat
        var lng = position.lng 
        var content;
        if(gon.user_signed_in)
          content='<div class="info-window"><span class="col-md-12 col-sm-12"><a href="/upload_video" id="upload_video" class="btn btn-default btn-block" data-remote=true>Upload Video</a></span><br><span class="col-md-6 col-sm-12"><a href="/events/new" id="request_video" class="btn btn-outline btn-block" data-remote=true>Request Video</a></span><span class="col-md-6 col-sm-12"><a href="/save_static_camera" id="static_camera" class="btn btn-outline btn-block" data-remote=true>Add Camera</a></span></div><input type="hidden" id="hidden_lat" value='+lat+' /> <input type="hidden" id="hidden_lng" value='+lng+' /> <input type="hidden" id="hidden_address" value=" '+place_formatted_address+'" /><input type="hidden" id="hidden_place_id" value='+place_id+' /> ';
        else
          content='<div class="info-window"><span class="col-md-12 col-sm-12"><a data-toggle="modal" href="#login" id="upload_video" class="btn btn-default btn-block" >Upload Video</a></span><br><span class="col-md-6 col-sm-12"><a data-toggle="modal" href="#login" id="request_video" class="btn btn-outline btn-block" >Request Video</a></span><span class="col-md-6 col-sm-12"><a data-toggle="modal" href="#login" id="static_camera" class="btn btn-outline btn-block" >Add Camera</a></span></div><input type="hidden" id="hidden_lat" value='+lat+' /> <input type="hidden" id="hidden_lng" value='+lng+' /> <input type="hidden" id="hidden_address" value=" '+place_formatted_address+'" /><input type="hidden" id="hidden_place_id" value='+place_id+' /> ';
        infoWindow = new google.maps.InfoWindow({
          position: location,
          content: content      
        });
        infoWindow.open(map);
        sessionStorage.infoWindow_position_lat = location.lat();
        sessionStorage.infoWindow_position_lng = location.lng();
        sessionStorage.infoWindow_content_signedin = '<div class="info-window"><span class="col-md-12 col-sm-12"><a href="/upload_video" id="upload_video" class="btn btn-default btn-block" data-remote=true>Upload Video</a></span><br><span class="col-md-6 col-sm-12"><a href="/events/new" id="request_video" class="btn btn-outline btn-block" data-remote=true>Request Video</a></span><span class="col-md-6 col-sm-12"><a href="/save_static_camera" id="static_camera" class="btn btn-outline btn-block" data-remote=true>Add Camera</a></span></div><input type="hidden" id="hidden_lat" value='+lat+' /> <input type="hidden" id="hidden_lng" value='+lng+' /> <input type="hidden" id="hidden_address" value=" '+place_formatted_address+'" /><input type="hidden" id="hidden_place_id" value='+place_id+' /> ';
        sessionStorage.infoWindow_content_signedout = content='<div class="info-window"><span class="col-md-12 col-sm-12"><a data-toggle="modal" href="#login" id="upload_video" class="btn btn-default btn-block" >Upload Video</a></span><br><span class="col-md-6 col-sm-12"><a data-toggle="modal" href="#login" id="request_video" class="btn btn-outline btn-block" >Request Video</a></span><span class="col-md-6 col-sm-12"><a data-toggle="modal" href="#login" id="static_camera" class="btn btn-outline btn-block" >Add Camera</a></span></div><input type="hidden" id="hidden_lat" value='+lat+' /> <input type="hidden" id="hidden_lng" value='+lng+' /> <input type="hidden" id="hidden_address" value=" '+place_formatted_address+'" /><input type="hidden" id="hidden_place_id" value='+place_id+' /> ';
      });
    }
  });
  //Listener to save the zoom level in local storage
  google.maps.event.addListener(map, "zoom_changed", function() {
    sessionStorage.zoomLevel = map.getZoom();
  });

    //listener to store map location
  google.maps.event.addListener(map, "bounds_changed", function() {
      sessionStorage.mapCenterlat = map.getCenter().lat();
      //console.log(sessionStorage.mapCenterlat);
      sessionStorage.mapCenterlng = map.getCenter().lng();
      //console.log(sessionStorage.mapCenterlng);
  });
}


//google.maps.event.addDomListener(window,'load',initMap);
console.log("after initmap");
$(document).ready(function(){

  $('#location').click(function(){
     $(this).select();
  });

  Stripe.setPublishableKey('pk_test_mgotCtnX4wfBFJ5ZYA1nMLy0');
  var va_height = $(window).height() - 90;
  var slider_height = va_height;
  var submitBtn;
  var map_div = $("#map_canvas")
  initMap();
  //google.maps.event.addDomListener(window, 'load', test3);
  console.log(va_height);
  $('.map-view').css('min-height', va_height + 'px');
  $('.right-slider').css({
    'height': slider_height,
    'overflow-y': 'auto'
  });


  $(document).on('click', '.close-slider', function() {
    $('.video-list-slider').hide('slide', {direction: 'right'}, 500);
    sliderFlag = false;
    if(sessionStorage.marker_id){
      sessionStorage.removeItem("marker_id");
    }
  });
  $(document).on('click', '.back-btn', function() {
    sliderFlag = true;
    $('.right-slider').hide();
    $('.video-list-slider').show('slide', { direction: 'right' }, 500);
  });
  $(document).on('click', '.report-btn', function() {
    $('.right-slider').hide();
    $('.video-list-slider').hide('slide', {direction: 'right'}, 500);
  });
  $(document).on('click', '.buy-btn', function() {
    video_id = $(this).data('event-video-id');
    request_url = "event_videos/"+video_id
    $.ajax({
      url: request_url,
      dataType: 'script',
      async:false,
      success:function(result){
        $('.right-slider').hide();
        $('.video-slider').show('slide', {direction: 'right'}, 500);
      }
    });
  });
  
  var $form = $('#payment-form');
  if($form.length > 0){
    $form.submit(function(event) {
      $form.find('.submit').prop('disabled', true);
      Stripe.card.createToken($form, stripeResponseHandler);
      return false;
    });
  }
});
