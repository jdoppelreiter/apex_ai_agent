$(document).ready(function() {

  $('#apexCBMDummySelection')
    .attr('aria-hidden', 'true')
    .attr('aria-label', 'Dummy selection');

  // Set the tab-index to the main navigation active entry
  setTimeout(function() {
        const $activeMenu = $('.t-Header-nav-list .a-Menu--current');
        if ($activeMenu.length > 0) {
            $activeMenu.attr('tabindex', '0');
        }
    }, 200);

});
