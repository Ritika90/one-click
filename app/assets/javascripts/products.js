$(document).ready(function () {
	$(document).on("change", ".add_to_store", function() {
		var _this = $(this);
		var product_id = _this.data().productId;
		var product_type = _this.data().type;
		$(".collection_id").val(_this.val());
		$(".product_id").val(product_id);
		$(".product_type").val(product_type);
		$('.single_product').addClass("single_product_"+product_id);

		if(_this.val() != ""){
			$(".confirm_popup").attr("style", "display: flex !important");
		}
	});

	$(document).on("click", ".confirm", function() {
		var p_id = $(".product_id").val();
		$('.single_product_'+p_id).submit();
		$(".confirm_popup").attr("style", "display: none !important");
	});

	$(document).on("click", ".discard, .Polaris-Modal-CloseButton", function() {
		$(".confirm_popup, .confirm_popup_fb, .confirm_popup_klaviyo").attr("style", "display: none !important");
		$("#delete_product_popup").attr("style", "display: none !important");
	});

	$(document).on("click", ".remove_product", function() {
		var _this = $(this);
		var product_id = _this.data().id;
		$(".delete_product_id").val(product_id);
		$('.single_product_delete').addClass("single_product_delete_"+product_id);
		$("#delete_product_popup").attr("style", "display: flex !important");
	});

	$(document).on("click", ".confirm_delete", function() {
		var p_id = $(".delete_product_id").val();
		$('.single_product_delete_'+p_id).submit();
		$("#delete_product_popup").attr("style", "display: none !important");
	});

	$(document).on("click", "#myBtn", function() {
		var dots = document.getElementById("dots");
		var moreText = document.getElementById("more");
		var btnText = document.getElementById("myBtn");

		if (dots.style.display === "none") {
			dots.style.display = "inline";
			btnText.innerHTML = "Read more";
			moreText.style.display = "none";
		} else {
			dots.style.display = "none";
			btnText.innerHTML = "Read less";
			moreText.style.display = "inline";
		}
	});

	$(document).on("click", ".spin", function() {
		$(".Polaris-Spinner").show();
		$(".app-content").addClass("overlay");
		$("html, body").animate({ scrollTop: 0 }, "slow");
	});

	$(document).on("click", ".store_add", function() {
		var _this = $(this);
		var product_id = _this.data("id")
		$(".store_add_"+product_id).addClass("d-none");
		$(".select_collect_"+product_id).removeClass("d-none");
	});

	$('#carouselExample').on('slide.bs.carousel', function (e) {
	    var $e = $(e.relatedTarget);
	    
	    var idx = $e.index();
	    console.log("IDX :  " + idx);
	    
	    var itemsPerSlide = 8;
	    var totalItems = $('.carousel-item').length;
	    
	    if (idx >= totalItems-(itemsPerSlide-1)) {
	        var it = itemsPerSlide - (totalItems - idx);
	        for (var i=0; i<it; i++) {
	            // append slides to end
	            if (e.direction=="left") {
	                $('.carousel-item').eq(i).appendTo('.carousel-inner');
	            }
	            else {
	                $('.carousel-item').eq(0).appendTo('.carousel-inner');
	            }
	        }
	    }
	});

	
	$(document).on("click", ".create_fb_add", function() {
		var _this = $(this);
		var product_id = _this.data().id;
		var product_type = _this.data().type;

		$('.fb_ad_form').addClass("fb_ad_form"+product_id);

		$(".product_id").val(product_id);
		$(".product_type").val(product_type);
		$(".confirm_popup_fb").attr("style", "display: flex !important");
	});


	$(document).on("click", ".confirm_fb", function() {
		var p_id = $(".product_id").val();
		$(".confirm_popup_fb").attr("style", "display: none !important");
		$(".confirm_fb_progress").attr("style", "display: flex !important");
		$('.fb_ad_form'+p_id).submit();
	});


	$(document).on("click", ".product_settings", function() {
		var _this = $(this);
		var product_id = _this.data().id;

		$('.fb_settings').addClass("fb_settings"+product_id);

		$(".confirm_popup_fb_settings").attr("style", "display: flex !important");
	});


	$(document).on("click", ".confirm_fb_settings", function() {
		var p_id = $(".product_id").val();
		$('.fb_settings'+p_id).submit();
		$(".confirm_popup_fb_settings").attr("style", "display: none !important");
	});

	$(document).on('change', '.daily_adset_spend select', function () {
		var daily_adset_spend = $(this).val();
		$('.daily_ad.Polaris-Select__SelectedOption').text('$'+daily_adset_spend);
	});

	$(document).on('change', '.number_of_adsets select', function () {
		var number_of_adsets = $(this).val();
		$('.number_of_ad.Polaris-Select__SelectedOption').text(number_of_adsets);
	});

	$(document).on('change', '#check_currency', function () {	
		var check = $("#check_currency").is(':checked');

		if (check == true){
			$('.currency_multiple_display').css('display', 'block');
		}
		else {
			$('.currency_multiple_display').css('display', 'none');
		}
	});

	$(document).on('change', '#fb_user_ad_account_id', function () {	
		window.location.href = '/settings?ad_acct='+$(this).val()
	});
	
});
