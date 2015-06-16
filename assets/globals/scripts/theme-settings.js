$(document).ready(function () {
  $('#theme-color').change(function () {
    Layout.settings.themeClass = $(this).val()

    Layout.handleThemeColor()
    Pleasure.handleToastrSettings(false, 'toast-top-left', false, 'info', true, '', 'Check navigation, search, user layers.')
  })

  $('#rtl-support').change(function () {
    if( $(this).prop('checked')) {
      Layout.settings.rtl = true
    } else {
      Layout.settings.rtl = false
    }
    Layout.handleRtlLayout()
  })

  $('#improve-performance').change(function () {
    if( $(this).prop('checked')) {
      Layout.settings.improvePerformance = true
    } else {
      Layout.settings.improvePerformance = false
    }
  })

})


