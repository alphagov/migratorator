(function($) {

  var list = "#navigation li";

  /*
   *  navigation
   */
  var slide = function (index) {

    if (index === undefined || index === NaN || index < -1) {
      index = 0;
    }

    if (index >= slide.deck.length && slide.current_page < slide.total_pages ) {
      window.location = '?page=' + (slide.current_page + 1);
    } else if ( index < 0 && slide.current_page > 1 ) {
      window.location = '?page=' + (slide.current_page - 1) + '#' + (slide.page_limit - 1);
    } else if ( index >= slide.deck.length ) {
      index = (slide.deck.length - 1);
    }

    $(list).removeClass("selected");

    $("#index").text(index);
    window.location.hash = index;

    slide.load(index);
  }

  slide.deck = [];
  slide.page_limit = 80;
  slide.current_page = 1;
  slide.total_pages = 1;

  slide.current = function () {
    var s = window.location.hash;
    s = s.replace(/^#*/, "");
    return parseInt(s, 10) || 0;
  };

  slide.current.save = function() {
    var data = slide.deck[slide.current()];
    var endpoint = '/mappings/' + data.id + '.json';

    data.new_url = $("#view input[name=new_url]").val();
    data.notes = $("#view textarea[name=notes]").val();
    data.status = $("#view select[name=status]").val();
    data.tags_list = $("#view input[name=tags]").val();

    var attributes = {
      'new_url' : data.new_url,
      'notes'     : data.notes,
      'status'     : data.status,
      'tags_list' : data.tags_list
    }

    $.ajax({
      type: "PUT",
      url: endpoint,
      data: { 'mapping' : attributes },
      dataType: 'json',
      success: function(data) {
        $('<div class="ajax-update saved">Saved.</div>').hide().appendTo('#view .status').fadeIn('fast', function() {
          setTimeout(function() { $('.ajax-update.saved').fadeOut('slow', function() { $(this).remove(); }) },750)
        });
        slide.load(slide.current());
      },
      error: function(data) {
        $('<div class="ajax-update error">Could not save.</div>').hide().appendTo('#view .status').fadeIn('fast', function() {
          setTimeout(function() { $('.ajax-update.error').fadeOut('slow', function() { $(this).remove(); }) },750)
        });
      }
    })
  }

  slide.load = function(index) {
    var current_slide = slide.deck[index];

    $('#navigation #slide-'+index).attr('class','selected visited status'+ (current_slide.status ? current_slide.status : "-none") );

    $("#view a.old_url").text(current_slide.old_url.replace('http://www.direct.gov.uk',''));
    $("#view a.old_url").attr("href", current_slide.old_url);
    $("#view a.old_url").attr("title", current_slide.old_url);

    $("#view input[name=title]").val(current_slide.title);
    $("#view input[name=new_url]").val(current_slide.new_url);
    $("#view select[name=status]").val(current_slide.status);
    $("#view textarea[name=notes]").val(current_slide.notes);
    $("#view input[name=tags]").val(current_slide.tags);

    $("#old").attr("src", current_slide.old_url);
    $("#new").attr("src", slide.display_new_url(current_slide) );
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
      index = (slide.current_page > 1) ? $(list).index(this) - 1 : $(list).index(this);
      slide(index);
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

  slide.display_new_url = function(mapping) {
    switch (mapping.status) {
    case '410':
    case 410:
      return "/browser_resources/410.html";
      break;
    case null:
      return "/browser_resources/no_status.html";
      break;
    default:
      return mapping.new_url;
      break;
    }
  }

  /*
   *  load slide deck from JSON
   */
  slide.load_collection = function(url, callback) {
    $.getJSON(url, function (data, ret, xhr) {

      var s = "";

      if (data) {
        if (data.pages.current_page > 1) {
          s = s + '<li id="prev-page" class="prev_link" title="Previous page"></li>';
        }
        $(data.mappings).each(function (i) {
          if (this.status === 302) {
            this.status = 410;
          }
          s = s + '<li id="slide-'+ i +'" class="status' + this.status + '"></li>';
        });
        if (data.pages.current_page < data.pages.total_pages) {
          s = s + '<li id="next-page" class="next_link" title="Next page"></li>';
        }
        slide.deck = data.mappings;

        slide.page_limit = data.pages.per_page;
        slide.current_page = data.pages.current_page;
        slide.total_pages = data.pages.total_pages;
      }
      $('#navigation .presentation').append(s);

      callback();
    });
  };

  $(document).ready(function() {

    slide.load_collection(mappings_json_endpoint, function() {

      /*
       *  set initial slide from fragment identifier
       */
      slide(window.location.hash ?  parseInt(window.location.hash.match(/\d+/g)[0]): 0);
      slide.keys();
    });

    $('#view input, #view textarea, #view select').change(function() {
      slide.current.save();
    });

    $('.floop').click(slide.floop);
  });

})(jQuery);
