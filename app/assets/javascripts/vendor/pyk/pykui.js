$(document).ready(function () {
	
	// Attention
    var original_color = $(".flash_attention").css("background-color");
    $(".flash_attention").css("background-color", "yellow").delay(3300).fadeTo(1200, 0.50, function() {
        $(this).css("background-color", original_color);
    });    
    
    //textarea increase / decrease
    $(".text_area_animate").focus(function () {

        var val_length = $(this).val().length;
        var size = $(this).attr("expand-height");

        if (val_length <= 0) {
            $(this).animate({
                "height": size
            }, "fast");
        }
    });

    $(".text_area_animate").focusout(function () {

        var val_length = $(this).val().length;
        var row = $(this).attr("row"); // 1 row = 16px
        var size = $(this).attr("expand-height");

        if (val_length <= 0) {

            $(this).animate({
                "height": "30px"
            }, "fast");
        }

    });

    //form hint

    $(".form-control").focus(function () {
        var text_hint = $(this).attr("hint");
        if (text_hint.length > 0) {
            var text_id = $(this).attr("id");
            var text_hint = $(this).attr("hint");
            $("#" + text_id).after("<span class='input-error-hint'>" + text_hint + "</span>");
            $(".input-error-hint").css("font-size", "11px").css("color", "grey");
        }
    });

    Tinycon.setOptions({
        width: 7,
        height: 9,
        font: '10px arial',
        colour: '#ffffff',
        background: '#549A2F',
        fallback: true
    });

    // scroll to top
    $("#scroll-topper").hide();
    $("#scroll-topper").click(function () {
        $("html, body").animate({
            scrollTop: 0
        }, 600);
    });

    // header collapser
    $("#collapse-header").click(function () {
        $("#main-nav").toggle();
        $(".breadcrumb-holder").toggle();
        $("#collapse-header span").toggleClass("glyphicon-chevron-up");
        $("#collapse-header span").toggleClass("glyphicon-chevron-down");
        if ($("#collapse-header span").hasClass("glyphicon-chevron-down")) {
            $(this).attr("title", "Show the menu");
            $("body").animate({
                "padding-top": "50px"
            });
        } else {
            $(this).attr("title", "Hide the menu");
            $("body").animate({
                "padding-top": "124px"
            });
        }
    });

    // If the toolbar is not present then there should't be extra
    // padding on the body top
    $("body").css("padding-top", $("#main-header").height());


    // load all the sparklines
    $(".sparkline-holder").each(function (i, e) {
        var data = $(e).attr("data-csv").split(",");
        var graph = $(e).attr("data-graph");
        var color = $(e).attr("data-color");

        if (color === "false") {
            $(e).sparkline(data, {
                type: graph,
                barColor: '#2d2d2d',
                negBarColor: '#2d2d2d',
                zeroColor: '#2d2d2d',

                lineColor: '#2d2d2d',
                fillColor: '#eee',
                spotColor: '#2d2d2d',
                minSpotColor: '#2d2d2d',
                maxSpotColor: '#2d2d2d',
                highlightSpotColor: '#2d2d2d',
                highlightLineColor: '#2d2d2d',

                sliceColors: ["#000", "#222", "#444", "#666", "#888", "#aaa"],

                tooltipOffsetX: 10,
                tooltipOffsetY: 10,
            });
        } else {
            $(e).sparkline(data, {
                type: graph,
                tooltipOffsetX: 10,
                tooltipOffsetY: 10,
            });
        }
    });

    // remove flashed after a while
    var removeFlashes = setTimeout(function () {
        $(".alert-success").fadeOut();
        $(".alert-info").fadeOut();
        $(".alert-warning").fadeOut();
    }, 3000);

  $('#transpose_hands_grid').on('click', function() {
    selector = $("#grid");
    var data = selector.handsontable("getData");

    var transposed = transpose(data);
    var handsontable = selector.data('handsontable');
    handsontable.loadData(transposed);

    function transpose(a) {
          return Object.keys(a[0]).map(function (c) {
              return a.map(function (r) {
                  return r[c];
              });
          });
      }

      return false;

  });

  $('#search_in_hands_grid').keyup(function (event) {

    var value = ('' + this.value).toLowerCase(), row, col, r_len, c_len, td;

    if (value) {
      
      $("#grid table td").filter(function(){

        if ($(this).text().toLowerCase().indexOf(value) >-1) {
          $(this).css("background-color", "#FFFF00")
          
        }else{
          $(this).css("background-color", "")
        }
            
      });

    }else {
      $("#grid table td").css("background-color", "");
    }

  });

  $("#grid > th:first div.relative").html("he its hack")

});


// show scroller
$(window).scroll(function () {
    if ($(this).scrollTop() > 100) {
        $("#scroll-topper").fadeIn();
    } else {
        $("#scroll-topper").fadeOut();
    }
});

function handsontable_with_filter(selector, data, readonly) {

    var columns = [];
    var spare_row = 15;
    
    for (var i = 10 - 1; i >= 0; i--) {
      columns.push([{type: 'checkbox'}])
    };

    
    if (data.length > 0) {
      spare_row = 1;
      
      columns = [];

      for (var i = data[1].length - 1; i >= 0; i--) { 
        var value = data[1][i];
        var type = "checkbox"
        
        if (typeof(value) == "number") {
          type = 'numeric'
        }

        if (typeof(value) !== "object" || value) {

          columns.push([{type: type, data: data[0][i]}]);  
        }        
        
      }
      
    }

    if (readonly) {
     spare_row = 0; 
    }

    $(selector).handsontable({
      data: data,
      colHeaders: true,
      rowHeaders: true,
      minSpareRows: spare_row,
      minSpareCols: 1,
      type: 'numeric',
      stretchH: 'all',      
      readOnly: readonly,
      manualColumnResize: true,
      manualColumnMove: true,
      persistentState: true,
      columnSorting: true,      
      fixedRowsTop: 1,
      fixedColumnsLeft: 1,
      overflow: scroll,
      autoWrapRow: true,
      contextMenu: true,
      outsideClickDeselects: false,
      cells: function (row, col, prop) {
          if (row === 0) {
            var cellProperties = {
              type: 'text' //force text type for first row
            }
            return cellProperties;
          }
        },

      afterGetColHeader: function (col, TH) {

          columns = $(selector).handsontable('getColHeader');
          var instance = this;
          var menu = buildMenu(columns[col].type);

          var $button = buildButton();
          $button.click(function (e) {

            e.preventDefault();
            e.stopImmediatePropagation();

            $('.changeTypeMenu').hide();

            menu.show();

            menu.position({
               my: 'left top',
               at: 'left bottom',
               of: $button,
               within: instance.rootElement
            });

            $(document).off('click.changeTypeMenu.hide');

            $(document).one('click.changeTypeMenu.hide', function () {
               menu.hide();
            });


          });

          menu.on('click', 'li', function () {
             setColumnType(col, $(this).data('colType'), instance);
          });

          TH.firstChild.appendChild($button[0]);
          TH.appendChild(menu[0]);
        }        
      

    });

    function firstRowRenderer(instance, td, row, col, prop, value, cellProperties) {
      Handsontable.TextCell.renderer.apply(this, arguments);
      td.style.fontWeight = 'bold';
      td.style.color = 'black';
      td.style.background = '#f0f0f0';
    }
    function buildMenu(activeCellType) {
      var menu = $('<ul></ul>').addClass('changeTypeMenu');

      $.each(['text', 'numeric', 'date', 'checkbox'], function(i, type) {
        var item = $('<li></li>').data('colType', type).text(type);

        if (activeCellType == type) {
          item.addClass('active');
        }

        menu.append(item);

      });

      return menu;

    }

    function buildButton() {
      return $('<button></button>').addClass('changeType').html('\u25BC');
    }

    function setColumnType(i, type, instance) {
      columns = $(selector).handsontable('getColHeader');
      columns[i].type = type;
      instance.updateSettings({columns: columns});
      instance.validateCells(function() {
        instance.render();
      });
    }        
    

  $("#addRow").click(function() {
    columns.push({});
    $("#grid").handsontable("render");
    return false;
  });

  $(selector+' table').addClass('table-hover table-condensed');
  $(selector+' table tbody tr:first').css("background-color", "blue").css('font-weight', 'bold');  

  function ConvertToCSV(objArray) {
    var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
    var str = '';

    for (var i = 0; i < array.length; i++) {
        var line = '';
        for (var index in array[i]) {
            if (line != '') line += ','

            line += array[i][index];
        }

        str += line + '\r\n';
    }

    return str;
  }

  console.log(ConvertToCSV(data));



}