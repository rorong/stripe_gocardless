$(document).ready(function(){
  $('#stripe-map-form').submit(function(event) {
    var $form = $(this);
    $form.find(':submit').prop('disabled', true)
    $form.find(':submit').css('background', '#dddddd')
    event.preventDefault();

    Stripe.card.createToken($form, stripeResponseHandler)
    // Prevent the form from submitting with the default action
    return false;
  });

});

var submit_count=0
function stripeResponseHandler(status, response) {
  var $form = $('#stripe-map-form');
  if (response.error) {
    // Show the errors on the form
    $form.find('.payment-errors').addClass('error')
    $form.find('.payment-errors').text(response.error.message);
    $form.find(':submit').prop('disabled', false)
    $form.find(':submit').css('background', '')
  } else {
    // response contains id and card, which contains additional card details
    var token = response.id;
    $form.find(':submit').prop('disabled', true)
    $form.find(':submit').css('background', '#dddddd')
    // Insert the token into the form so it gets submitted to the server
    $form.append($('<input type="hidden" name="stripeToken" />').val(token));
    // and submit
    $form.find('.payment-errors').removeClass('error')

    if (submit_count==0){
      $.ajax({
        method: "POST",
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
        url: "/create_subscription",
        data: $form.serialize(),
        success: function (data, status) {
        },
        error: function (status, err) {
          console.log("error", err)
          window.location.href='/home'
        }
      });
      submit_count=submit_count+1;
    }

  }
};

function isNumberKey(evt){
  var charCode = (evt.which) ? evt.which : event.keyCode
  if(charCode > 31 && (charCode < 48 || charCode > 57)){
    return false
  }
  else{
    return true
  }
};
