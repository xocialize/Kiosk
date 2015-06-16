var PerfectScrollbars = {
  initScrollbars: function () {
    $('.menu-layer').perfectScrollbar({
      suppressScrollX: true
    })

    $('.search-layer').perfectScrollbar({
      suppressScrollX: true
    })

    $('#messages .message-list').perfectScrollbar({
      suppressScrollX: true
    })

    $('.messages').perfectScrollbar({
      suppressScrollX: true
    })

    $('#notifications').perfectScrollbar({
      suppressScrollX: true
    })

    $('#settings').perfectScrollbar({
      suppressScrollX: true
    })
  },

  init: function () {
    this.initScrollbars()
  }
}


