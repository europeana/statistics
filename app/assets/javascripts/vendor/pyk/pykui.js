$(document).ready(function () {
	
    // scroll to top
    $("#scroll-topper").hide();
    $("#scroll-topper").click(function () {
        $("html, body").animate({
            scrollTop: 0
        }, 600);
    });

    // remove flashed after a while
    var removeFlashes = setTimeout(function () {
        $(".alert-success").fadeOut();
        $(".alert-info").fadeOut();
        $(".alert-warning").fadeOut();
    }, 3000);

});