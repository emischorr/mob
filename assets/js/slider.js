import $ from "jquery"

$('input[type=range]').on("input", function() {
  var preview = $(this).siblings('output').children('.size-preview')
  preview.show();
  preview.children('.range_value').text(this.value +" Clients/s" );
}).trigger("change");

$('input[type=range]').on("mouseup", function() {
  $(this).siblings('output').children('.size-preview').hide();
});
