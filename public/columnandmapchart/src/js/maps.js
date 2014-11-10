PykCharts.maps = {};

PykCharts.maps.mouseEvent = function (options) {
    var highlight_selected = {
        highlight: function (selectedclass, that) {
            var t = d3.select(that);
            d3.selectAll(selectedclass)
                .attr("opacity",.5)
            t.attr("opacity",1);
            return this;
        },
        highlightHide : function (selectedclass) {
            d3.selectAll(selectedclass)
                .attr("opacity",1);
            return this;
        }
    }
    return highlight_selected;
}

PykCharts.maps.processInputs = function (chartObject, options) {

    var theme = new PykCharts.Configuration.Theme({})
        , stylesheet = theme.stylesheet
        , functionality = theme.functionality
        , mapsTheme = theme.mapsTheme
        , optional = options.optional;

    chartObject.selector = options.selector ? options.selector : stylesheet.selector;
    chartObject.width = options.chart_width && _.isNumber(parseInt(options.chart_width,10)) ? options.chart_width : mapsTheme.chart_width;
    chartObject.height = options.chart_height && _.isNumber(parseInt(options.chart_height,10)) ? options.chart_height : mapsTheme.chart_height;
    chartObject.mapCode = options.mapCode ? options.mapCode : mapsTheme.mapCode;
    chartObject.mapCode = options.mapCode ? options.mapCode : mapsTheme.mapCode;
    chartObject.enableClick = options.enableClick ? options.enableClick : mapsTheme.enableClick;
    chartObject.bg = options.colors_backgroundColor ? options.colors_backgroundColor : stylesheet.backgroundColor;

    chartObject.timeline_duration = options.timeline_duration ? options.timeline_duration :mapsTheme.timeline_duration;
    chartObject.margin_left = options.timeline_margin_left ? options.timeline_margin_left : mapsTheme.timeline_margin_left;
    chartObject.margin_right = options.timeline_margin_right ? options.timeline_margin_right : mapsTheme.timeline_margin_right;
    chartObject.margin_top = options.timeline_margin_top ? options.timeline_margin_top : mapsTheme.timeline_margin_top;
    chartObject.margin_bottom = options.timeline_margin_bottom ? options.timeline_margin_bottom : mapsTheme.timeline_margin_bottom;

    chartObject.tooltip_enable = options.tooltip_enable ? options.tooltip_enable : mapsTheme.tooltip_enable;
    chartObject.tooltip_mode = options.tooltip_mode ? options.tooltip_mode : mapsTheme.tooltip_mode;
    chartObject.tooltip_positionTop = options.tooltip_positionTop ? options.tooltip_positionTop : mapsTheme.tooltip_positionTop;
    chartObject.tooltip_positionLeft = options.tooltip_positionLeft ? options.tooltip_positionLeft : mapsTheme.tooltip_positionLeft;
    chartObject.tooltipTopCorrection = d3.select(chartObject.selector).style("top");
    chartObject.tooltipLeftCorrection = d3.select(chartObject.selector).style("left");

    chartObject.colors_defaultColor = options.colors_defaultColor ? options.colors_defaultColor : mapsTheme.colors_defaultColor;
    chartObject.colors_total = options.colors_total && _.isNumber(parseInt(options.colors_total,10))? parseInt(options.colors_total,10) : mapsTheme.colors_total;
    chartObject.colors_type = options.colors_type ? options.colors_type : mapsTheme.colors_type;
    chartObject.colors_palette = options.colors_palette ? options.colors_palette : mapsTheme.colors_palette;

    chartObject.axis_onHoverHighlightenable = PykCharts.boolean(options.axis_x_enable) && options.axis_onHoverHighlightenable ? options.axis_onHoverHighlightenable : mapsTheme.axis_onHoverHighlightenable;
    chartObject.axis_x_enable = options.axis_x_enable ? options.axis_x_enable : mapsTheme.axis_x_enable;
    chartObject.axis_x_value_position = PykCharts.boolean(options.axis_x_enable) && options.axis_x_value_position ? options.axis_x_value_position : mapsTheme.axis_x_value_position;
    chartObject.axis_x_axisColor = PykCharts.boolean(options.axis_x_enable) && options.axis_x_axisColor ? options.axis_x_axisColor : mapsTheme.axis_x_axisColor;
    chartObject.axis_x_labelColor = PykCharts.boolean(options.axis_x_enable) && options.axis_x_labelColor ? options.axis_x_labelColor : mapsTheme.axis_x_labelColor;
    chartObject.axis_x_no_of_axis_value = PykCharts.boolean(options.axis_x_enable) && options.axis_x_no_of_axis_value ? options.axis_x_no_of_axis_value : mapsTheme.axis_x_no_of_axis_value;
    chartObject.axis_x_pointer_padding = PykCharts.boolean(options.axis_x_enable) && options.axis_x_pointer_padding ? options.axis_x_pointer_padding : mapsTheme.axis_x_pointer_padding;
    chartObject.axis_x_pointer_size = "axis_x_pointer_size" in options && PykCharts.boolean(options.axis_x_enable) ? options.axis_x_pointer_size : mapsTheme.axis_x_pointer_size;
    chartObject.axis_x_value_format = PykCharts.boolean(options.axis_x_enable) && options.axis_x_value_format ? options.axis_x_value_format : mapsTheme.axis_x_value_format;
    chartObject.axis_x_pointer_values = PykCharts.boolean(options.axis_x_enable) && options.axis_x_pointer_values ? options.axis_x_pointer_values : mapsTheme.axis_x_pointer_values;
    chartObject.axis_x_outer_pointer_size = "axis_x_outer_pointer_size" in options && PykCharts.boolean(options.axis_x_enable) ? options.axis_x_outer_pointer_size : mapsTheme.axis_x_outer_pointer_size;

    chartObject.label_enable = options.label_enable ? options.label_enable : mapsTheme.label_enable;
    chartObject.legends_enable = options.legends_enable ? options.legends_enable : mapsTheme.legends_enable;
    chartObject.legends_display = options.legends_display ? options.legends_display : mapsTheme.legends_display;

    chartObject.borderBetweenChartElements_width = "borderBetweenChartElements_width" in options ? options.borderBetweenChartElements_width : stylesheet.borderBetweenChartElements_width;
    chartObject.borderBetweenChartElements_color = options.borderBetweenChartElements_color ? options.borderBetweenChartElements_color : stylesheet.borderBetweenChartElements_color;
    chartObject.borderBetweenChartElements_style = options.borderBetweenChartElements_style ? options.borderBetweenChartElements_style : stylesheet.borderBetweenChartElements_style;
    switch(chartObject.borderBetweenChartElements_style) {
        case "dotted" : chartObject.borderBetweenChartElements_style = "1,3";
                        break;
        case "dashed" : chartObject.borderBetweenChartElements_style = "5,5";
                       break;
        default : chartObject.borderBetweenChartElements_style = "0";
                  break;
    }
    chartObject.onhover = options.onhover ? options.onhover : mapsTheme.onhover;
    chartObject.defaultZoomLevel = options.defaultZoomLevel ? options.defaultZoomLevel : 80;
    chartObject.loading = options.loading_animationGifUrl ? options.loading_animationGifUrl: stylesheet.loading_animationGifUrl;
    chartObject.highlightArea = options.highlightArea ? options.highlightArea : mapsTheme.highlightArea;

    if (options &&  PykCharts.boolean (options.title_text)) {
        chartObject.title_size = "size" in options ? options.title_size : stylesheet.title_size;
        chartObject.title_color = options.title_color ? options.title_color : stylesheet.title_color;
        chartObject.title_weight = options.title_weight ? options.title_weight : stylesheet.title_weight;
        chartObject.title_family = options.title_family ? optional.title_family : stylesheet.title_family;
    } else {
        chartObject.title_size = stylesheet.title_size;
        chartObject.title_color = stylesheet.title_color;
        chartObject.title_weight = stylesheet.title_weight;
        chartObject.title_family = stylesheet.title_family;
    }

    if (options && PykCharts.boolean(options.subtitle_text)) {
        chartObject.subtitle_size = "subtitle_size" in options ? options.subtitle_size : stylesheet.subtitle_size;
        chartObject.subtitle_color = options.subtitle_color ? options.subtitle_color : stylesheet.subtitle_color;
        chartObject.subtitle_weight = options.subtitle_weight ? options.subtitle_weight : stylesheet.subtitle_weight;
        chartObject.subtitle_family = options.subtitle_family ? options.subtitle_family : stylesheet.subtitle_family;
    } else {
        chartObject.subtitle_size = stylesheet.subtitle_size;
        chartObject.subtitle_color = stylesheet.subtitle_color;
        chartObject.subtitle_weight = stylesheet.subtitle_weight;
        chartObject.subtitle_family = stylesheet.subtitle_family;
    }

    chartObject.realTimeCharts_refreshFrequency = options.realTimeCharts_refreshFrequency ? options.realTimeCharts_refreshFrequency : functionality.realTimeCharts_refreshFrequency;
    chartObject.realTimeCharts_enableLastUpdatedAt = options.realTimeCharts_enableLastUpdatedAt ? options.realTimeCharts_enableLastUpdatedAt : functionality.realTimeCharts_enableLastUpdatedAt;
    chartObject.transition_duration = options.transition_duration ? options.transition_duration : functionality.transition_duration;

    chartObject.creditMySite_name = options.creditMySite_name ? options.creditMySite_name : stylesheet.creditMySite_name;
    chartObject.creditMySite_url = options.creditMySite_url ? options.creditMySite_url : stylesheet.creditMySite_url;
    chartObject.dataSource = options.dataSource ? options.dataSource : "no";
    chartObject.units = options.units ? options.units : false;

    chartObject.k = new PykCharts.Configuration(chartObject);
    return chartObject;

};
