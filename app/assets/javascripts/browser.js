(function($) {

  var list = "#navigation li";

  /*
   *  navigation
   */
  var slide = function (index) {

    if (index === undefined || index === NaN || index < 0) {
      index = 0;
    }

    // rollover
    var max = $(list).index($(list+":last"));
    if (index > max) {
      index = max;
    }

    $(list).removeClass("selected");

    var item = $(list+":eq("+index+")");
    item.addClass("selected");
    item.addClass("visited");

    var old_link = $(list+":eq("+index+") a.old_url");
    var old_url = $(old_link).attr("href");

    var new_link = $(list+":eq("+index+") a.new_url");
    var new_url = $(new_link).attr("href");

    $("#index").text(index);

    $("#view a.title").text($(old_link).text());
    $("#view a.title").attr("href", old_url);
    $("#view a.title").attr("title", old_url);

    $("#old").attr("src", old_url);
    $("#new").attr("src", new_url);

    window.location.hash = index;
  }

  slide.current = function () {
    var s = window.location.hash;
    s = s.replace(/^#*/, "");
    return parseInt(s, 10) || 0;
  };

  slide.prev = function () {
    slide(parseInt(slide.current(), 10)-1);
  };

  slide.next = function () {
    slide(parseInt(slide.current(), 10)+1);
  };

  slide.floop = function () {
    $('.floop').toggleClass("open");
    $('#view').slideToggle("fast");
  };

  slide.floop_open = function () {
    $('.floop').addClass("open");
    $('#view').slideDown("fast");
  };

  slide.floop_close = function () {
    $('.floop').removeClass("open");
    $('#view').slideUp("fast");
  };


  /*
   * keys and clicks
   */
  slide.keys = function() {

    $(list).click(function() {
      slide($(list).index(this));
    });

    $(document).bind("keydown","nav",function(event) {
      switch (event.keyCode) {
      case 13:
        slide.floop_open();
        break;

      case 27:
        slide.floop_close();
        break;

      case 8:
      case 37:
        slide.prev();
        break;
      case 14:
      case 32:
      case 39:
        slide.next();
        break;
      }
    });

    $("#navigation .next").click(slide.next);
    $("#navigation .prev").click(slide.prev);
  };

  /*
   *  load slide deck from JSON
   */
  slide.load = function(url, callback) {
    $.getJSON(url, function (data, ret, xhr) {

      var s = "";

      if (data) {
        $(data.mappings).each(function () {
          if (!this.status || this.status === 302) {
            this.status = 410;
          }
          var new_url = this.new_url ? this.new_url : this.status + ".html";
          s = s + '<li class="status' + this.status + '">' +
            '<a class="old_url" href="' + this.old_url + '">' + this.title + '</a>' +
            ' <a class="new_url" href="' + new_url + '">' + this.status + '</a>' +
            '</li>';
        });
      }
      $('#navigation .presentation').append(s);

      callback();
    });
  };

  $(document).ready(function() {

    slide.load(mappings_json_endpoint, function() {

      /*
       *  set initial slide from fragment identifier
       */
      slide(window.location.hash ?  parseInt(window.location.hash.match(/\d+/g)[0]): 0);
      slide.keys();
    });

    $('.floop').click(slide.floop);
  });

})(jQuery);
