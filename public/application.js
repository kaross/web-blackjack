$(document).ready(function(){
  slide_card();
  hit();
  stay();
  dealer_turn();
});

function hit(){
  $(document).on("click", "form#hit_btn button", function() {
    $.ajax({
      type: 'POST',
      url: '/hit'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });

    return false;
  })
};

function stay(){
  $(document).on("click", "form#stay_btn button", function() {
    $.ajax({
      type: 'POST',
      url: '/stay'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });

    return false;
  })
};

function dealer_turn(){
  $(document).on("click", "form#dealer_turn button", function() {
    $.ajax({
      type: 'POST',
      url: '/dealer_turn'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });

    return false;
  })
};
