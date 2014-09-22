PykCharts.maps.oneLayer = function (options) {
    var that = this;
    var theme = new PykCharts.Configuration.Theme({});
    this.execute = function () {
        that = PykCharts.maps.processInputs(that, options);
        //$(that.selector).css("height",that.height);
        d3.json(options.data, function (data) {
            that.fulldata = data;
            that.data = _.where(data, {timestamp:_.last(options.years)});
            that.compare_data = that.data;
            that.k
                .totalColors(that.colors_total)
                .colorType(that.colors_type)
                .loading(that.loading)
                .tooltip();

            d3.json("data/" + that.mapCode + "-topo.json", function (data) {
                that.map_data = data;
                d3.json("data/colorPalette.json", function (data) {
                    that.color_palette_data = data;
                    $(that.selector).html("");
                    that.oneLayer = new PykCharts.maps.mapFunctions(options,that,"oneLayer");
                    that.oneLayer.render();
                });
            });
            that.extent_size = d3.extent(that.data, function (d) { return parseInt(d.size, 10); });
            that.difference = that.extent_size[1] - that.extent_size[0];
        })
    };
};

PykCharts.maps.timelineMap = function (options) {
    var that = this;
    var theme = new PykCharts.Configuration.Theme({});
    this.execute = function () {
        that = PykCharts.maps.processInputs(that, options);
        //$(that.selector).css("height",that.height);
        d3.json(options.data, function (data) {
            that.fulldata = data;
            that.timeline_data = _.where(data, {timestamp:_.last(options.years)});
            that.compare_data = that.data;
            var x_extent = d3.extent(data, function (d) { return d.timestamp; });
            that.data = _.where(data, {timestamp: x_extent[0]});

            // that.margin = {top:10, right:30, bottom:10, left:30};

            that.redeced_width = that.width - (that.margin_left * 2) - that.margin_right;
            that.redeced_height = that.height - that.margin_top - that.margin_bottom;

            that.k
                .totalColors(that.colors_total)
                .colorType(that.colors_type)
                .loading(that.loading)
                .tooltip(that.tooltip_enable);

            d3.json("data/" + that.mapCode + "-topo.json", function (data) {
                that.map_data = data;
                d3.json("data/colorPalette.json", function (data) {
                    that.color_palette_data = data;


                    var x_extent = d3.extent(that.timeline_data, function (d) { return d.timestamp; })
                    that.data = _.where(that.timeline_data, {timestamp: x_extent[0]});

                    that.data.sort(function (a,b) {
                        return a.timestamp - b.timestamp;
                    });
                    $(that.selector).html("");
                    var timeline = new PykCharts.maps.mapFunctions(options,that,"timeline");
                    timeline.render();
                });
            });

            that.extent_size = d3.extent(that.data, function (d) { return parseInt(d.size, 10); });
            that.difference = that.extent_size[1] - that.extent_size[0];
        });
    };
};

PykCharts.maps.mapFunctions = function (options,chartObject,type) {
    var that = chartObject;

    this.render = function () {

        that.border = new PykCharts.Configuration.border(that);
        // console.log(that.border.color());
        that.k.title()
            .subtitle();

        //    var that = this;
        that.current_palette = _.where(that.color_palette_data, {name:that.colors_palette, number:that.colors_total})[0];
        that.optionalFeatures()
            .legendsContainer(that.legends_enable)
            .legends(that.legends_enable)
            .svgContainer()
            .createMap()
            .label(that.label_enable)
            .enableClick(that.enableClick);

        that.k
            .createFooter()
            .lastUpdatedAt()
            .credits()
            .dataSource()
            .liveData(that);


        if(type === "timeline") {
            that.renderTimeline();
        }
    };

    that.refresh = function () {
        if(type === "oneLayer") {
            that.data = chartObject.filtered_data;
            that.refresh_data = chartObject.filtered_data;
            var compare = that.k.checkChangeInData(that.refresh_data,that.compare_data);
            that.compare_data = compare[0];
            var data_changed = compare[1];
            if(data_changed) {
                that.k.lastUpdatedAt("liveData");
            }
            that.extent_size = d3.extent(that.data, function (d) { return parseInt(d.size, 10); });
            that.difference = that.extent_size[1] - that.extent_size[0];
            that.optionalFeatures()
                .legends(that.legends_enable)
                .createMap();
                // that.k.lastUpdatedAt("liveData");
        } else {
            that.timeline_data = chartObject.filtered_data;
            that.refresh_data = chartObject.filtered_data;
            var compare = that.k.checkChangeInData(that.refresh_data,that.compare_data);
            that.compare_data = compare[0];
            var data_changed = compare[1];
            if(data_changed) {
                that.k.lastUpdatedAt("liveData");
            }
            that.optionalFeatures()
            .legends(that.legends_enable)
            .createMap();
            var x_extent = d3.extent(data, function (d) { return d.timestamp; });
            that.data = _.where(data, {timestamp: x_extent[0]});
        }
    };

    that.optionalFeatures = function () {
        var config = {
            legends: function (el) {
                if (PykCharts.boolean(el)) {
                    that.renderLegend();
                };
                return this;
            },
            legendsContainer : function (el) {
                if (PykCharts.boolean(el) && that.colors_type === "saturation") {
                    that.legendsContainer = d3.select(that.selector)
                        .append("svg")
                        .attr("id", "legend-container")
                        .attr("width", that.width)
                        .attr("height", 50);
                }
                return this;
            },
            label: function (el) {
                if (PykCharts.boolean(el)) {
                    that.renderLabel();
                };
                return this;
            },
            svgContainer : function () {
                that.svgContainer = d3.select(that.selector)
                    .append("svg")
                    .attr("width", that.width)
                    .attr("height", that.height)
                    .attr("class",'PykCharts-map')
                    .attr("style", "border:1px solid lightgrey")
                    .style("border-radius", "5px");

                that.map_cont = that.svgContainer.append("g")
                    .attr("id", "map_group");

                var defs = that.map_cont.append('defs');
                var filter = defs.append('filter')
                    .attr('id', 'dropshadow');

                filter.append('feGaussianBlur')
                    .attr('in', 'SourceAlpha')
                    .attr('stdDeviation', 1)
                    .attr('result', 'blur');

                filter.append('feOffset')
                    .attr('in', 'blur')
                    .attr('dx', 1)
                    .attr('dy', 1)
                    .attr('result', 'offsetBlur');

                var feMerge = filter.append('feMerge');

                feMerge.append('feMergeNode')
                    .attr('in", "offsetBlur');

                feMerge.append('feMergeNode')
                    .attr('in', 'SourceGraphic');
                return this;
            },
            createMap : function () {
                var scale = 150
                , offset = [that.width / 2, that.height / 2]
                , i;
                $(options.selector).css("background-color",that.bg);

                that.group = that.map_cont.selectAll(".map_group")
                    .data(topojson.feature(that.map_data, that.map_data.objects).features)

                that.group.enter()
                    .append("g")
                    .attr("class","map_group")
                    .append("path");

                if (that.mapCode==="world") {
                    var center = [0,0];
                } else {
                    var center = d3.geo.centroid(topojson.feature(that.map_data, that.map_data.objects));
                }
                var projection = d3.geo.mercator().center(center).scale(scale).translate(offset);

                that.path = d3.geo.path().projection(projection);

                var bounds = that.path.bounds(topojson.feature(that.map_data, that.map_data.objects)),
                    hscale = scale * (that.width) / (bounds[1][0] - bounds[0][0]),
                    vscale = scale * (that.height) / (bounds[1][1] - bounds[0][1]),
                    scale = (hscale < vscale) ? hscale : vscale,
                    offset = [that.width - (bounds[0][0] + bounds[1][0]) / 2, that.height - (bounds[0][1] + bounds[1][1]) / 2];

                projection = d3.geo.mercator().center(center)
                   .scale((that.defaultZoomLevel / 100) * scale).translate(offset);
                that.path = that.path.projection(projection);
                var ttp = d3.select("#pyk-tooltip");

                that.chart_data = that.group.select("path")
                    .attr("d", that.path)
                    .attr("class", "area")
                    .attr("iso2", function (d) {
                        return d.properties.iso_a2;
                    })
                    .attr("state_name", function (d) {
                        return d.properties.NAME_1;
                    })
                    //.attr("prev-fill",that.renderPreColor)
                    .attr("fill", that.renderColor)
                    .attr("prev_fill", function (d) {
                        return d3.select(this).attr("fill");
                    })
                    .attr("opacity", that.renderOpacity)
                    .style("stroke", that.border.color())
                    .style("stroke-width", that.border.width() + "px")
                    .style("stroke-dasharray", that.border.style())
                    .on("mouseover", function (d) {
                        if (PykCharts.boolean(that.tooltip_enable)) {
                            ttp.style("visibility", "visible");
                            ttp.html((_.where(that.data, {iso2: d.properties.iso_a2})[0]).tooltip);
                            if (that.tooltip_mode === "moving") {
                                ttp.style("top", function () {

                                        return (d3.event.pageY - 20 ) + "px";
                                    })
                                    .style("left", function () {

                                        return (d3.event.pageX + 20 ) + "px";

                                    });
                            } else if (that.tooltip_mode === "fixed") {
                                ttp.style("top", (that.tooltip_positionTop) + "px")
                                    .style("left", (that.tooltip_positionLeft) + "px");
                            }
                        }
                        that.bodColor(d);
                    })
                    .on("mouseout", function (d) {
                        if (PykCharts.boolean(that.tooltip_enable)) {
                            ttp.style("visibility", "hidden");
                        }
                        that.bodUncolor(d);
                    });
                that.group.exit()
                    .remove();
                return this;
            },
            enableClick: function (ec) {
                if (PykCharts.boolean(ec)) {
                    that.chart_data.on("click", that.clicked);
                    // that.onhover = "color_saturation";
                    that.onhover1 = that.onhover;
                };
                return this;
            },
            axisContainer : function (ae) {
                if(PykCharts.boolean(ae)){
                    that.gxaxis = that.svgContainer.append("g")
                        .attr("id","xaxis")
                        .attr("class", "x axis")
                        .attr("transform", "translate("+(that.margin_left*2)+"," + that.redeced_height + ")");
                }
                return this;
            }
        }
        return config;
    };


    that.renderColor = function (d, i) {
        if (!PykCharts.boolean(d)) {
            return false;
        }
        var col_shade,
            obj = _.where(that.data, {iso2: d.properties.iso_a2});
        if (obj.length > 0) {
            if (that.colors_type === "colors") {
                if (obj.length > 0 && obj[0].color !== "") {
                    return obj[0].color;
                }
                return that.colors_defaultColor;
            }
            if (that.colors_type === "saturation") {

                if ((that.highlightArea === "yes") && obj[0].highlight == "true") {
                    return obj[0].highlight_color;
                } else {
                    if (that.colors_palette !== "") {
                        col_shade = obj[0].size;
                        for (i = 0; i < that.current_palette.colors.length; i++) {
                            if (col_shade >= that.extent_size[0] + i * (that.difference / that.current_palette.colors.length) && col_shade <= that.extent_size[0] + (i + 1) * (that.difference / that.current_palette.colors.length)) {
                                return that.current_palette.colors[i];
                            }
                        }

                    }
                    return that.colors_defaultColor;
                }
            }
            return that.colors_defaultColor;
        }
        return that.colors_defaultColor;
    };

    that.renderOpacity = function (d) {

        if (that.colors_palette === "" && that.colors_type === "saturation") {
            that.oneninth = +(d3.format(".2f")(that.difference / 10));
            that.opacity = (that.extent_size[0] + (_.where(that.data, {iso2: d.properties.iso_a2})[0]).size + that.oneninth) / that.difference;
            return that.opacity;
        }
        return 1;
    };

    that.renderLegend = function () {
        // var that = this,
            var k,
            onetenth;
        if (that.colors_type === "saturation") {

            if(that.legends_display === "vertical" ) {
                var j = 0, i = 0;
                if(that.colors_palette === "") {
                    that.legendsContainer.attr("height", (9 * 30)+20);
                }
                else {
                    that.legendsContainer.attr("height", (that.current_palette.number * 30)+20);
                }
                text_parameter1 = "x";
                text_parameter2 = "y";
                rect_parameter1 = "width";
                rect_parameter2 = "height";
                rect_parameter3 = "x";
                rect_parameter4 = "y";
                rect_parameter1value = 13;
                rect_parameter2value = 13;
                text_parameter1value = function (d,i) { return that.width - (that.width/12) + 18; };
                rect_parameter3value = function (d,i) { return that.width - (that.width/12); };
                var rect_parameter4value = function (d) {j++; return j * 24 + 12;};
                var text_parameter2value = function (d) {i++; return i * 24 + 23;};

            } else if(that.legends_display === "horizontal") {
                var j = 0, i = 0;
                if(that.colors_palette === "") {

                    j = 9, i = 9;
                }
                else {
                    j = that.current_palette.number, i = that.current_palette.number;
                    that.legendsContainer.attr("height", (that.current_palette.number * 30)+20);
                }
                that.legendsContainer.attr("height", 50);
                text_parameter1 = "x";
                text_parameter2 = "y";
                rect_parameter1 = "width";
                rect_parameter2 = "height";
                rect_parameter3 = "x";
                rect_parameter4 = "y";
                var text_parameter1value = function () { i--; return that.width - (i*60 + 40);};
                text_parameter2value = 30;
                rect_parameter1value = 13;
                rect_parameter2value = 13;
                var rect_parameter3value = function () {j--; return that.width - (j*60 + 60); };
                rect_parameter4value = 18;

            };
            if (that.colors_palette === "") {
                var leg_data = [1,2,3,4,5,6,7,8,9];
                onetenth = d3.format(".1f")(that.extent_size[1] / 9);
                that.leg = function (d,i) { return "<" + d3.round(onetenth * (i+1)); };
                var legend = that.legendsContainer.selectAll(".rect")
                    .data(leg_data)
                legend.enter()
                    .append("rect")

                legend.attr("class","rect")
                    .attr("x", rect_parameter3value)
                    .attr("y", rect_parameter4value)
                    .attr("width", rect_parameter1value)
                    .attr("height", rect_parameter2value)
                    .attr("fill", that.colors_defaultColor)
                    .attr("opacity", function(d,i) { return (i+1)/9; });

                legend.exit()
                    .remove();
                that.legends_text = that.legendsContainer.selectAll(".text")
                    .data(leg_data);

                that.legends_text.enter()
                    .append("text")

                that.legends_text.attr("class","text")
                    .attr("x", text_parameter1value)
                    .attr("y", text_parameter2value)
                    .style("font-size", 10)
                    .style("font", "Arial")
                    .text(that.leg);
                that.legends_text.exit()
                    .remove();
            } else {
                that.leg = function (d,i) { return  "<" + d3.round(that.extent_size[0] + (i+1) * (that.difference / that.current_palette.number)); };
                var legend = that.legendsContainer.selectAll(".rect")
                    .data(that.current_palette.colors);

                legend.enter()
                    .append("rect")

                legend.attr("class","rect")
                    .attr("x",rect_parameter3value)
                    .attr("y", rect_parameter4value)
                    .attr("width", rect_parameter1value)
                    .attr("height", rect_parameter2value)
                    .attr("fill", function (d) { return d; });

                legend.exit()
                    .remove();

                that.legends_text = that.legendsContainer.selectAll(".text")
                    .data(that.current_palette.colors);

                that.legends_text.enter()
                    .append("text");

                that.legends_text.attr("class","text")
                    .attr("x", text_parameter1value)
                    .attr("y",text_parameter2value)
                    .style("font-size", 10)
                    .style("font", "Arial")
                    .text(that.leg);

                that.legends_text.exit()
                    .remove();
            }
            // $("#legend-container").after("</br>");
        } else {
            $("#legend-container").remove();
        }
    };

    that.renderLabel = function () {
        that.group.append("text")
            .attr("x", function (d) { return that.path.centroid(d)[0]; })
            .attr("y", function (d) { return that.path.centroid(d)[1]; })
            .attr("text-anchor", "middle")
            .attr("font-size", "10")
            .attr("pointer-events", "none")
            .text(function (d) { return d.properties.NAME_1; });
    };

    that.bodColor = function (d) {
        // console.log(that.onhover1);
        var obj = _.where(that.data, {iso2: d.properties.iso_a2});
        if(that.onhover1 !== "none") {
            if (that.onhover1 === "highlight_border") {
                d3.select("path[state_name='" + d.properties.NAME_1 + "']")
                    .style("stroke", that.border.color())
                    .style("stroke-width", parseInt(that.border.width()) + 1.5 + "px")
                    .style("stroke-dasharray", that.border.style());
            } else if (that.onhover1 === "shadow") {
                d3.select("path[state_name='" + d.properties.NAME_1 + "']")
                    .attr('filter', 'url(#dropshadow)')
                    .attr("opacity", function () {
                        if (that.colors_palette === "" && that.colors_type === "saturation") {
                            that.oneninth_dim = +(d3.format(".2f")(that.difference / 10));
                            that.opacity_dim = (that.extent_size[0] + (obj[0]).size + that.oneninth_dim) / that.difference;
                            return that.opacity_dim/2;
                        }
                        return 0.5;
                    });
            } else if (that.onhover1 === "color_saturation") {
                d3.select("path[state_name='" + d.properties.NAME_1 + "']")
                    .attr("opacity", function () {
                        if (that.colors_palette=== "" && that.colors_type === "saturation") {
                            that.oneninth_dim = +(d3.format(".2f")(that.difference / 10));
                            that.opacity_dim = (that.extent_size[0] + (obj[0]).size + that.oneninth_dim) / that.difference;
                            return that.opacity_dim/2;
                        }
                        return 0.5;
                    });
            }
        } else {
            that.bodUncolor(d);
        }
    };
    that.bodUncolor = function (d) {
        d3.select("path[state_name='" + d.properties.NAME_1 + "']")
            .style("stroke", that.border.color())
            .style("stroke-width", that.border.width())
            .style("stroke-dasharray", that.border.style())
            .attr('filter', null)
            .attr("opacity", function () {
                if (that.colors_palette === "" && that.colors_type === "saturation") {
                    that.oneninth_high = +(d3.format(".2f")(that.difference / 10));
                    that.opacity_high = (that.extent_size[0] + (_.where(that.data, {iso2: d.properties.iso_a2})[0]).size + that.oneninth_high) / that.difference;
                    return that.opacity_high;
                }
                return 1;
            });
    };

    this.clicked = function (d) {
        var obj = {};
        obj.container = d3.event.target.ownerSVGElement.parentNode.id;
        obj.area = d.properties;
        obj.data = _.where(that.data, {iso2: d.properties.iso_a2})[0];
        try {
            customFunction(obj);
        } catch (ignore) {
            /*console.log(e);*/
        }
    };

    that.renderTimeline = function () {
        var x_extent
        , x_range
        , unique = []
        , duration
        , interval = interval1 = 1;

        that.optionalFeatures()
            .axisContainer(true);

        x_extent = d3.extent(that.timeline_data, function(d) { return d.timestamp; });
        x_range = [0 ,that.redeced_width];
        that.xScale = that.k.scaleIdentification("linear",x_extent,x_range);

        that.k.xAxis(that.svgContainer,that.gxaxis,that.xScale);

        _.each(that.timeline_data, function (d) {
            if (unique.indexOf(d.timestamp) === -1) {
                unique.push(d.timestamp);
            }

        })
        unique.sort(function (a,b) {
          return a - b;
        });

        var bbox = d3.select(that.selector+" .axis").node().getBBox()
        , timeline_status;

        var startTimeline = function () {
            if (timeline_status==="playing") {
                play.attr("xlink:href","https://s3-ap-southeast-1.amazonaws.com/ap-southeast-1.datahub.pykih/assets/images/play.gif");
                clearInterval(that.play_interval);
                timeline_status = "paused";
            } else {
                timeline_status = "playing";
                play.attr("xlink:href","https://s3-ap-southeast-1.amazonaws.com/ap-southeast-1.datahub.pykih/assets/images/pause.gif");
                that.play_interval = setInterval(function () {

                    marker
                        // .transition()
                        // .duration(that.timeline.duration/2)
                        .attr("x",  (that.margin_left*2) + that.xScale(unique[interval]) - 7);

                    that.data = _.where(that.timeline_data, {timestamp:unique[interval]});
                    that.data.sort(function (a,b) {
                        return a.timestamp - b.timestamp;
                    });
                    _.each(that.data, function (d) {
                        d3.select("path[iso2='"+d.iso2+"']")
                            // .transition()
                            // .duration(that.timeline.duration/4)
                            .attr("fill", that.renderColor);
                    });

                    interval++;

                    if (interval===unique.length) {
                        clearInterval(that.play_interval);
                    };
                }, that.timeline_duration);

                var time_lag = setTimeout(function () {
                    var undo_heatmap = setInterval(function () {
                        interval1++;

                        if (interval1 === interval) {
                            clearInterval(undo_heatmap);
                            clearTimeout(time_lag)
                        }

                        if (interval1===unique.length) {
                            clearInterval(undo_heatmap);
                            play.attr("xlink:href","https://s3-ap-southeast-1.amazonaws.com/ap-southeast-1.datahub.pykih/assets/images/play.gif");
                            marker.attr("x",  (that.margin_left*2) + that.xScale(unique[0]) - 7);
                            interval = interval1 = 1;
                            timeline_status = "";
                        };
                    }, that.timeline_duration);
                },that.timeline_duration);
            }
        }

        var play = that.svgContainer.append("image")
            .attr("xlink:href","https://s3-ap-southeast-1.amazonaws.com/ap-southeast-1.datahub.pykih/assets/images/play.gif")
            .attr("x", that.margin_left / 2)
            .attr("y", that.redeced_height - that.margin_top - (bbox.height/2))
            .attr("width","24px")
            .attr("height", "21px")
            .style("cursor", "pointer")
            .on("click", startTimeline)

        var marker = that.svgContainer.append("image")
            .attr("xlink:href","https://s3-ap-southeast-1.amazonaws.com/ap-southeast-1.datahub.pykih/assets/images/marker.png")
            .attr("x", (that.margin_left*2) + that.xScale(unique[0]) - 7)
            .attr("y", that.redeced_height)
            .attr("width","14px")
            .attr("height", "12px")

        // duration = unique.length * 1000;

    }
};
