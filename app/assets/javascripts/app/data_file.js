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

        if (custom_chart.indexOf(vdata.chart_type) >= 0) {
          GenerateCustomChart(vdata.chart_type,'#'+title+"_Id_"+data.id, vdata.mapped_output);
        }else{  
          if (vdata) {
            dw.visualize({
              type: chart_types[vdata.chart_type] + "-chart", 
              theme: 'default', 
              container: $('#'+title+"_Id_"+data.id),
              datasource:   dw.datasource.delimited({csv: vdata.mapped_output})        
            })          
          }
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

function GenereteChartInMarkdown() {

  var chart_types = { "Pie Chart" : "pie", "Election Donut Chart": "election-donut" , "Donut Chart": "donut", "Bar Chart": "bar", "Column Chart": "column", "Grouped Column Chart": "grouped-column" , "Line Chart": "line" }

  $(".pykih-viz").each(function(index) {      

    var title = $(this).attr("data-slug-id");   
    var that  = $(this);   
    var width = $(this).parent("div").attr("class");

    var div_id = $("#"+title).attr("id");
    var custom_chart = ["Bubble Chart"];
    $.get("/generate/chart/"+title,function(vdata,status){      

      console.log("#"+title);
      if (custom_chart.indexOf(vdata.chart_type) >= 0) {
        GenerateCustomChart(vdata.chart_type,"#"+title, vdata.mapped_output);
      }else {
        if (vdata) {
          $(that).addClass("col-sm-12");
          $(that).css("height","250px");
          dw.visualize({
            type: chart_types[vdata.chart_type] + "-chart", 
            theme: 'default', 
            container: that,
            datasource:   dw.datasource.delimited({csv: vdata.mapped_output})        
          })          
        }
      }
    });      
  }); 
}

function get_html_template(layout_type,style) {

  var algorithm = parseInt(layout_type.split("x")[1]);
  var html_tag  = "<div class='row'>";

  var class_name = "col-sm-12";
  if (algorithm >= 2) {
    class_name = "col-sm-"+(12/algorithm);
  }
  
  for (var i=1; i <= algorithm; i++) {     
    html_tag = html_tag + "<div class='"+class_name+"'></div>";
  }

  return html_tag = html_tag + "</div>";
}

function randomString() {
  var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
  var string_length = 5;
  var randomstring = '';
  for (var i=0; i<string_length; i++) {
    var rnum = Math.floor(Math.random() * chars.length);
    randomstring += chars.substring(rnum,rnum+1);
  }
  return randomstring;
}

function GenereteDataWrapperChart(options) {

  var chart_types = { "Pie Chart" : "pie", "Election Donut Chart": "election-donut" , "Donut Chart": "donut", "Bar Chart": "bar", "Column Chart": "column", "Grouped Column Chart": "grouped-column" , "Line Chart": "line" }

  var title = options.title;   
  $("#"+options.id).addClass("col-sm-12");
  $("#"+options.id).css("height","250px");
  var custom_chart = ["Bubble Chart"];
  $.get("/generate/chart/"+title,function(vdata,status){

    if (vdata) {      
      if (custom_chart.indexOf(vdata.chart_type) >= 0) {
        GenerateCustomChart(vdata.chart_type,'#'+title+"_Id_"+data.id, vdata.mapped_output);
      }else{
        dw.visualize({
          type: chart_types[vdata.chart_type] + "-chart", 
          theme: 'default', 
          container: options.selector,
          datasource:   dw.datasource.delimited({csv: vdata.mapped_output})        
        })          

      }
  

    }

  });      
}

function GenerateCustomChart(chart_type,selector,data) {
  if (chart_type == "Bubble Chart") {
    GenerateCustomBubbleChart(selector,data);
  }else if(chart_type == "Compare Line Chart") {
    GenerateCustomLineChart(selector,data);
  }
}

function formaToCustomLineData(data) {
  var output = [];
  for (var i = 0; i <= data.length - 1; i++) {
    if (i > 0) {
      output.push(data[i]);
    }     
  }
  return output;
}

function GenerateCustomLineChart(selector,data) {  
  data = d3.csv.parseRows(data);
  data = formaToCustomLineData(data);
  data = setDataByFilter(data);
  updateLineChartWithAxis(selector,data);  
}

function setDataByFilter(data) {  
  var compare_to_pos = $("#compare-to").val();  
  var filtered_data = [getDataFromFilter(data[compare_to_pos])];
  var compare_with_pos = $("#compare-with").val();  
  var time_frame = $("#time-frame").val();
  if (compare_with_pos > 0) {
    filtered_data.push(getDataFromFilter(data[compare_with_pos]));
  }

  var time_frames = ["Monthly","Quaterly","Yearly","All"];
  var new_data_set = [];
  for (var i = 0; i <= filtered_data.length - 1; i++) {
    var qdata = filtered_data[i];
    for (var j = 1; j <= time_frame ; j++) {
      var format = {"y":parseInt(qdata[j]),"x":time_frames[j-1],
                    "group": qdata[0]}
      new_data_set.push(format);
    };
    
  };

  return new_data_set;
}

function getDataFromFilter(data) {
  var filtered_data = [];
  var time_frame = $("#time-frame").val();
  for (var i = 0; i <= time_frame; i++) {
    filtered_data.push(data[i]);
  };
  return filtered_data;
}

function GenerateCustomBubbleChart(selector,data) {
    
  var diameter = 500  ,
      format = d3.format(",d"),
      color = d3.scale.category20c();

  var bubble = d3.layout.pack()
      .sort(null)
      .size([diameter, diameter])
      .padding(1.5);

  var svg = d3.select(selector).append("svg")
      .attr("width", diameter)
      .attr("height", diameter)
      .attr("class", "bubble");

  var data = d3.csv.parseRows(data);

  var node = svg.selectAll(".node")
                .data(bubble.nodes(classes(data))
                .filter(function(d) { return !d.children; }))
                .enter().append("g")
                .attr("class", "node")
                .attr("transform", function(d) {return "translate(" + d.x + "," + d.y + ")"; });
  
    node.append("title")
        .text(function(d) { return d.className + ": " + format(d.value); });

    node.append("circle")
        .attr("r", function(d) { return d.r; })
        .style("fill", function(d) { return color(d.packageName); });

    node.append("text")
        .attr("dy", ".3em")
        .style("text-anchor", "middle")
        .text(function(d) {return d.className.substring(0, d.r / 3); });


  // Returns a flattened hierarchy containing all leaf nodes under the root.
  function classes(root) {
    var classes = [];

    function recurse(name, nodes) {      
      nodes.forEach(function(node,index) {
        if (index > 0) { 
          classes.push({packageName: node[0], className: node[0], value: node[1]});
        } 
      });      
      // return false;
      // if (node.children) node.children.forEach(function(child) { recurse(node.name, child); });
      // else classes.push({packageName: name, className: node.name, value: node.size});
    }

    recurse(null, root);
    return {children: classes};
  }

  d3.select(self.frameElement).style("height", diameter + "px");

}

// This Jquery extend function for textarea to add text or data @ cursor postion
$.fn.insertAtCaret = function(text) {
  return this.each(function() {
    if (document.selection && this.tagName == 'TEXTAREA') {
        //IE textarea support
        this.focus();
        sel = document.selection.createRange();
        sel.text = text;
        this.focus();
    } else if (this.selectionStart || this.selectionStart == '0') {
        //MOZILLA/NETSCAPE support
        startPos = this.selectionStart;
        endPos = this.selectionEnd;
        scrollTop = this.scrollTop;
        this.value = this.value.substring(0, startPos) + text + this.value.substring(endPos, this.value.length);
        this.focus();
        this.selectionStart = startPos + text.length;
        this.selectionEnd = startPos + text.length;
        this.scrollTop = scrollTop;
    } else {
        // IE input[type=text] and other browsers
        this.value += text;
        this.focus();
        this.value = this.value;    // forces cursor to end
    }
  });
};

$(document).ready(function() {
  $("#compare-to").change(function() {
    
    if (validateCompareToWith()) {
    
    }


  });

  $("#compare-with").change(function() {
    
    if (validateCompareToWith()) {

    }

  });

});

function validateCompareToWith() {
  var compareTo   = $("#compare-to").val();
  var compareWith = $("#compare-with").val();
  if (compareTo === compareWith) {
    alert("Compare To & With Value Cannot be Same");
    return false;
  }else {
    return true;
  }

}

function updateLineChartWithAxis(selector,data) {

  var m = [80, 80, 80, 80]; 
  var w = 1200 - m[1] - m[3]; 
  var h = 500 - m[0] - m[2]; 
      
  var line = d3.svg.line().interpolate("linear")
              .x(function(d) {return x(d.x);})
              .y(function(d) {return y(d.y);
              });

  var x = d3.scale.ordinal().rangeRoundBands([0, w], .95);
  var y = d3.scale.linear().range([h, 0]);
  var xAxis = d3.svg.axis().scale(x).orient("bottom");
  var yAxis = d3.svg.axis().scale(y).orient("left");

  var graph = d3.select(selector).append("svg:svg")
    .attr("width", w + m[1] + m[3])
    .attr("height", h + m[0] + m[2])
    .append("svg:g")
    .attr("transform", "translate(" + m[3] + "," + m[0] + ")");
  
  x.domain(data.map(function(d) {return d.x;}));
  y.domain([d3.min(data, function(d) {return d.y;}),
            d3.max(data, function(d) {return d.y;})]);

  graph.append("svg:g")
       .attr("class", "x axis")
       .attr("transform", "translate(0," + h + ")")
       .call(xAxis);

  var yAxisLeft = d3.svg.axis()
          .scale(y)
          .ticks(10)
          .orient("left")
          .tickSize(-w)
          .tickSubdivide(true);

  graph.append("svg:g")
          .attr("class", "y axis")
          .attr("transform", "translate(-25,0)")
          .call(yAxisLeft);

  var groups = [];
  var which_color = d3.scale.category10();
  var colors = [];
        
  data.forEach(function(group) {
    if (groups.indexOf(group.group) < 0) {
      groups.push(group.group);
      colors.push(which_color(group.group));
    }
  });

        generate_chart(data);
        function generate_chart(data) {
          var class_name = "";
          
          groups.forEach(function(group) {

            var line_data = [];
            var g_line_data = [];
            var color = "yellow";
            class_name = group;
            data.forEach(function(d) {
              if (group.indexOf(d.group) >= 0) {
                color = d.color;               
                line_data.push({x: d.x, y: d.y, group: d.group});
              } else {
                g_line_data.push({x: d.x, y: d.y, group: d.group});
              }
            });


            graph.append("svg:path")
                    .attr("d", line(line_data))
                    .attr("stroke", color)
                    .attr("stroke-width", 3)
                    .style("fill",color)
                    .style("opacity", 1) 
                    .attr("stroke-width", 1.5)
                    .attr("class", "line point-line line-" + class_name);

            graph.selectAll("circles")
                    .data(line_data)
                    .enter()
                    .append("circle")
                    .attr("class", "dot line-" + class_name)
                    .attr("cx", function(d) {
                      return x(d.x);
                    })
                    .attr("cy", function(d) {
                      return y(d.y);
                    })
                    .attr("fill", color)
                    .attr("r", 3.5)
                    .attr("stroke", color)
                    .attr("stroke-width", 0);


            
          });
          
        }



}
