
var PieMapper = function(options){
    this.init = function(d){
        this.map = {};
        this.data = options.DATA;
        this.getType();
        this.fillVarList();
    }

    // Final Mapping Data
    this.mappingData = function(){
        // TODO: Add some validations here to check if the mapping truly is complete
        if(Object.keys(this.map).length !== 2){
            alert("Mapping incomplete!");
            return false;
        }
        window.open(options.URL + "?data=" + JSON.stringify(this.map), "_self");
        // This is what needs to be posted
    }

    // List Makers
    this.fillVarList = function(){
        var k = this.column_names;
        var t = this.column_types;
        for(var i in k){
            var html = k[i] + " (" + t[i] + ")";
            var div = $("<div>")
                .html(html)
                .addClass("btn btn-primary drop-option")
                .css("z-index", 1000)
                .attr("data-droptype", t[i])
                .attr("data-colname", k[i]);

            $("#user-variables").append(div);
        };

        this.initDragDrop();
    };

    this.initDragDrop = function(){
        var that = this;

        $("#user-variables div").draggable({
            revert: function(d){
                if(!d) return true;
                var param = $(d).attr("id").split("-")[0];
                var local_param = $(this).attr("data-colname");
                if(that.map[local_param] === undefined) return true;
                if($(d).attr("data-full") === param) return true;
            },
            snap: ".takes-drop",
            snapMode: "inner"
        });

        $(".takes-drop").each(function(e, i){
            var droptype = $(this).attr("data-droptype");
            $(this).droppable({
                accept: "div[data-droptype='" + droptype + "']",
                activeClass: "active-drop",
                hoverClass: "hover-drop",
                tolerance: "fit",
                drop: function(e, u){
                    var param = $(this).attr("map_identifier");
                    var local_param = $(u.draggable).attr("data-colname");
                    if(that.map[local_param] === undefined) that.map[local_param] = param;
                    if(that.map[local_param] === undefined) $(this).attr("data-full", param)
                }
            });
        });
    }



    // Get headings and their types and save it in an array
    // Use if for both the table and the variable list
    this.getType = function(){
        var columns = this.data[0];
        this.column_names = [];
        this.column_types = [];

        for(var i in columns){
            this.column_names.push(columns[i].split(":")[0]);
            this.column_types.push(columns[i].split(":")[1]);
        }
    };

    this._isValue = function(v){
        for(var i in this.map){
            var k = this.map[i];
            if(k === v) return true;
        }
        return false;
    }
};
