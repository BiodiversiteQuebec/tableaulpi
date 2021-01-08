(function($) {
$(document).ready(function(){
  var openclosed="open"
  $("#closebtn").html('&#9664;');
  $('#closebtn').on('click',function(){
    var divs=$("#main-row").children();
    if(openclosed=="closed"){
      openclosed="open"
      $(divs[0]).animate({'margin-left':0});
      $(divs[1]).animate({'width':"80vw"});
      $("#map").width("80vw");
      $("#closebtn").html('&#9664;');
    }else{
      openclosed="closed"
      $(divs[0]).animate({'margin-left':"-23vw"});
      $(divs[1]).animate({'width':"96vw"});
      $("#map").width("96vw");
      $("#closebtn").html('&#9654;');
    }
  });
});
})(jQuery);