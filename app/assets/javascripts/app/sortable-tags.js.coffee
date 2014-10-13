jQuery ->
  $('#sort-tags').sortable
    axis: 'y'
    handle: '.handle'
    update: (event, ui) ->
      neworder = new Array()
      $(this).children().each ->
        id = $(this).attr("id")
        neworder.push(id)
      $.ajax
        url: "/sort/tags"
        type: "POST"
        data: { sort: neworder }
