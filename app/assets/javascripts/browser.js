(function($) {

  var list = "#navigation li";

  /*
   *  navigation
   */
  var slide = function (index) {

    if (index === undefined || index === NaN || index < 0) {
      index = 0;
    }
    current_slide = slide.deck[index];

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

    $("#view a.title").text(current_slide.title);
    $("#view a.title").attr("href", old_url);
    $("#view a.title").attr("title", old_url);

    $("#view #status").text(current_slide.status);
    $("#view input[name=old_url]").val(current_slide.old_url);
    $("#view input[name=new_url]").val(current_slide.new_url);
    $("#view textarea[name=notes]").val(current_slide.notes);
    $("#view input[name=tags]").val(current_slide.tags);

    $("#old").attr("src", old_url);
    $("#new").attr("src", new_url);

    window.location.hash = index;
  }

  slide.deck = [];

  slide.current = function () {
    var s = window.location.hash;
    s = s.replace(/^#*/, "");
    return parseInt(s, 10) || 0;
  };

  slide.current.save = function() {
    var data = slide.deck[slide.current()];
    var endpoint = '/mappings/' + data.id + '.json';

    var attributes = {
      'new_url' : $("#view input[name=new_url]").val(),
      'notes'     : $("#view textarea[name=notes]").val(),
      'tags_list' : $("#view input[name=tags]").val()
    }

    $.ajax({
      type: "PUT",
      url: endpoint,
      data: { 'mapping' : attributes },
      dataType: 'json',
      success: function(data) {
        $('<div class="saved">Saved.</div>').hide().appendTo('#view .status').fadeIn('fast', function() {
          setTimeout(function() { $('.saved').fadeOut('slow', function() { $(this).remove(); }) },750)
        });
      }
    })
  }

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
      }

      if ($('input, textarea').is(":focus") == false) {
        switch (event.keyCode) {
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
          var new_url = this.new_url ? this.new_url : "/browser_resources/" + this.status + ".html";
          s = s + '<li class="status' + this.status + '">' +
            '<a class="old_url" href="' + this.old_url + '">' + this.title + '</a>' +
            ' <a class="new_url" href="' + new_url + '">' + this.status + '</a>' +
            '</li>';
        });
        slide.deck = data.mappings;
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

    $('#view input, #view textarea').change(function() {
      slide.current.save();
    });

    $('.floop').click(slide.floop);
  });

})(jQuery);
