function handsontable_with_filter(selector, data, readonly) {

    $(selector).handsontable({      
      startRows: 5,
      startCols: 5,
      minRows: 5,
      minCols: 5,
      rowHeaders: true,
      colHeaders: true,
      minSpareRows: 1,      
      stretchH: 'all',
      readOnly: readonly,
      fixedRowsTop: 2,
      fixedColumnsLeft: 2,
      autoWrapRow: true,
      columnSorting: true,
      manualColumnResize: true,
      manualColumnMove: true,
      contextMenu: true,
      autoWrapRow: true,      
      outsideClickDeselects: false,
      cells: function (row, col, prop) {
          if (row <= 0) {
            var cellProperties = {
              renderer: firstRowRenderer
            }
            return cellProperties;
          }
        }
      
      
    });

    if (data.length > 0) {
      var handsontable = $(selector).data('handsontable');
      handsontable.loadData(data);
    }



    function firstRowRenderer(instance, td, row, col, prop, value, cellProperties) {
      Handsontable.TextCell.renderer.apply(this, arguments);
      td.style.fontWeight = 'bold';
      td.style.color = '#1B668B';
      td.style.background = '#f0f0f0';
    }
    

  $(selector+' table').addClass('table-hover table-condensed');
  $(selector+' table tbody tr:first').css('font-weight', 'bold').css("color", "#1B668B");  


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

  //console.log(ConvertToCSV(data));

}

function remove_null_rows(selector) {
  var total_rows =  $(selector).handsontable('countRows');  

  for (var i = total_rows - 1; i >= 0; i--) {

    if ($(selector).handsontable("isEmptyRow",i)) {
      $(selector).handsontable("alter", "remove_row", i );  
    }
    
  }  

}

function remove_null_cols(selector) {
  var total_cols =  $(selector).handsontable('countCols');  

  for (var i = total_cols - 1; i >= 0; i--) {
    if ($(selector).handsontable("isEmptyCol",i)) {
      $(selector).handsontable("alter", "remove_col", i );  
    }
    
  }  

}


function generate_article_chart() {

  $(".wmd-input").hide();
  var converter = new Showdown.converter();
  var chart_types = { "Pie Chart" : "pie", "Election Donut Chart": "election-donut" , "Donut Chart": "donut", "Bar Chart": "bar", "Column Chart": "column", "Grouped Column Chart": "grouped-column" , "Line Chart": "line" }

  $.each(gon.cms_articles, function(index, data) {    

    var class_name = "#preview-"+data.id;

    var title = "";
    if (data.description.split( "![visualization]\(" )) {
      title = data.description.split( "![visualization]\(" );
      if (title.length > 1) {      
        title = title[1].split("\)")[0];
      }else {
        title = "";
      }    
    }


    if (title.length > 0) {

      $("<div>")
        .attr("id", title+"_Id_"+data.id)
        .css({
          "height": "200px",
          "width": "180px"
        })
      .appendTo(class_name)

      $.get("/generate/chart/"+title,function(vdata,status){

        if (vdata) {
          dw.visualize({
            type: chart_types[vdata.chart_type] + "-chart", 
            theme: 'default', 
            container: $('#'+title+"_Id_"+data.id),
            datasource:   dw.datasource.delimited({csv: vdata.mapped_output})        
          })          
        }

      });

    }

    if (title.length <= 0) {
      var image_checker = converter.makeHtml(data.description);
      $(class_name).html(image_checker);        
      var element_type = $(class_name+" img:first")

      if (element_type.length <= 0) {
        element_type = image_checker;
      }

      $(class_name).html(element_type);
    }

  });

}


function generate_article_star_chart() {

  $(".wmd-input").hide();
  var converter = new Showdown.converter();
  var chart_types = { "Pie Chart" : "pie", "Election Donut Chart": "election-donut" , "Donut Chart": "donut", "Bar Chart": "bar", "Column Chart": "column", "Grouped Column Chart": "grouped-column" , "Line Chart": "line" }

  var data = gon.star_article;    
  var class_name = "#star-article-preview";
  var title = "";

  if (data.description.split( "![visualization]\(" )) {
    title = data.description.split( "![visualization]\(" );
    if (title.length > 1) {      
      title = title[1].split("\)")[0];
    }else {
      title = "";
    }    
  }

  if (title.length > 0) {
    $("<div>")
      .attr("id", title+"_Id_"+data.id)
      .css({
        "height": "230px",
        "width": "848px"
      })
    .appendTo(class_name)

    $.get("/generate/chart/"+title,function(vdata,status){

      if (vdata) {
        dw.visualize({
          type: chart_types[vdata.chart_type] + "-chart", 
          theme: 'default', 
          container: $('#'+title+"_Id_"+data.id),
          datasource:   dw.datasource.delimited({csv: vdata.mapped_output})        
        })          
      }

    });

  }

  if (title.length <= 0) {
    var image_checker = converter.makeHtml(data.description);
    $(class_name).html(image_checker);        
    var element_type = $(class_name+" img:first")

    if (element_type.length <= 0) {
      element_type = image_checker;
    }

    $(class_name).html(element_type);
  }


}


function GenereteChartInMarkdown() {

  var chart_types = { "Pie Chart" : "pie", "Election Donut Chart": "election-donut" , "Donut Chart": "donut", "Bar Chart": "bar", "Column Chart": "column", "Grouped Column Chart": "grouped-column" , "Line Chart": "line" }

  $(".pykih-viz").each(function(index) {      

    console.log($(this).parent("div").attr("class"))
    var title = $(this).attr("data-slug-id");   
    var that  = $(this);   
    var width = $(this).parent("div").attr("class");

    $(this).addClass("col-sm-12");
    $(this).css("height","250px");

    var div_id = $("#"+title).attr("id");
    $.get("/generate/chart/"+title,function(vdata,status){

      if (vdata) {
        dw.visualize({
          type: chart_types[vdata.chart_type] + "-chart", 
          theme: 'default', 
          container: that,
          datasource:   dw.datasource.delimited({csv: vdata.mapped_output})        
        })          
      }

    });
      
  }); 

}

function insertTextAtTextareaCursor(ID,text) {    
    var txtarea = $("#"+ID).next('textarea')[0];
    var scrollPos = txtarea.scrollTop;
    var strPos = 0;
    var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ? 
    "ff" : (document.selection ? "ie" : false ) );
    if (br == "ie") { 
        txtarea.focus();
        var range = document.selection.createRange();
        range.moveStart ('character', -txtarea.value.length);
        strPos = range.text.length;
    }
    else if (br == "ff") strPos = txtarea.selectionStart;
    
    var front = (txtarea.value).substring(0,strPos); 
    var back = (txtarea.value).substring(strPos,txtarea.value.length); 
    txtarea.value=front+text+back;
    strPos = strPos + text.length;
    if (br == "ie") { 
        txtarea.focus();
        var range = document.selection.createRange();
        range.moveStart ('character', -txtarea.value.length);
        range.moveStart ('character', strPos);
        range.moveEnd ('character', 0);
        range.select();
    }
    else if (br == "ff") {
        txtarea.selectionStart = strPos;
        txtarea.selectionEnd = strPos;
        txtarea.focus();
    }
    txtarea.scrollTop = scrollPos;
}

function get_html_template(layout_type,style) {

  var algorithm = parseInt(layout_type.split("x")[1]);
  var html_tag  = "<div class='row'>";

  var class_name = "col-sm-12";
  if (algorithm >= 2) {
    class_name = "col-sm-"+(12/algorithm);
  }
  console.log(algorithm > 1,algorithm < 1, algorithm)
  
  for (var i=1; i <= algorithm; i++) {     
    html_tag = html_tag + "<div class='"+class_name+"'></div>";
  }

  return html_tag = html_tag + "</div>";
}