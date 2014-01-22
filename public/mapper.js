
var PieMapper = function(options){

    this.init = function(d){
        if(options.MAP=="NA"){
            this.map = {};
        }else{
            this.map = options.MAP;
        }
        this.data = options.DATA;
        this.getType();
        this.fillVarList();
        if(options.MAP!="NA") this.loadMap();
    }

    this.loadMap = function(){
        
        for(var i in options.MAP){
            var m = options.MAP[i];
            var drop = $("#" + m + "-drop");
            var drag = $("[data-colname='" + i + "']");
            drop.addClass("dropped");
            drag.offset(drop.offset());
        }
    }

    // Final Mapping Data
    this.mappingData = function(){
        // TODO: Add some validations here to check if the mapping truly is complete
        
        var mandatory_field = ""
        $(".mand-error").remove();
        $("[data-map-type=M]").each(function(){
            console.log("not droppped class found", $(this).hasClass("dropped"))
            if (!$(this).hasClass("dropped")) {

                mandatory_field = $(this).parent().find("h5").text();
                $(this).append("<span class='label label-danger mand-error'>"
                                +mandatory_field+" required!</span>");

            }

        });

        if (mandatory_field.length > 0) {
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
                .addClass("bootstrap-btn btn-primary drop-option")
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
            revert: true,
            snap: ".takes-drop",
            snapMode: "inner",
            start: function(evt, ui){
                startPos = ui.helper.position();
            }            

        });

        $(".takes-drop").each(function(e, i){
            
            var droptype = $(this).attr("data-droptype");            

            var accept_valid = ".ui-draggable";
            if (droptype == "number") {
                accept_valid = "div[data-droptype='" + droptype + "']";
            }

            $(this).droppable({                
                accept: accept_valid  ,
                activeClass: "active-drop",
                hoverClass: "hover-drop",
                tolerance: "fit",

                drop: function(e, u){
                    
                    if ($(this).hasClass("dropped")) {
                        return false;                    
                    }

                    u.draggable.draggable('option', 'revert', function(){return false});

                    $( this ).addClass( "dropped" )
                    var param = $(this).attr("map_identifier");                    
                    var local_param = $(u.draggable).attr("data-colname");
                    if(that.map[local_param] === undefined) that.map[local_param] = param;
                    if(that.map[local_param] === undefined) $(this).attr("data-full", param)
                },
                out: function(event, u){
                    u.position.top = startPos.top;
                    u.position.left = startPos.left;                 
                    if ($(this).hasClass("dropped")) {
                        $(this).removeClass("dropped")
                    }

                    

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
