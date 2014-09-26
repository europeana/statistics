PykCharts.filter = function (years,k,l) {
    var filter = function () {
      d3.selectAll(".menu").classed("active",false);
      d3.select(this).classed("active",true);
      
      var val = parseInt($(this).html(),10);
      k.filtered_data = _.where(k.fulldata,{timestamp:val})
      k.refresh(k.filtered_data,k.fulldata);

      l.filtered_data = _.where(l.fulldata,{timestamp:val})
      l.refresh(l.filtered_data, l.fulldata);


    }

    var menu = "<ul>";

    _.each(years, function (d) {
      menu += "<strong><li class='menu'>" + d + "</li></strong>";
    });

    menu += "</ul>";

    $("#menu").html(menu);

    $(".menu").click(filter);
}
