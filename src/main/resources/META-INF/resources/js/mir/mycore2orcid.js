(function(){
	const orcidStatusURL  = webApplicationBaseURL + "rsc/orcid/status/";
	const orcidPublishURL = webApplicationBaseURL + "rsc/orcid/publish/";
	const translateURL = webApplicationBaseURL + "rsc/locale/translate/";

	const orcidIcon = "<img alt='ORCID iD' src='" + webApplicationBaseURL + "images/orcid_icon.svg' class='orcid-icon' />";

	let orcidTextStatusIsInProfileTrue  = "orcid.publication.inProfile.true";
	let orcidTextStatusIsInProfileFalse = "orcid.publication.inProfile.false";

	let orcidTextPublishUpdate = "orcid.publication.action.update";
	let orcidTextPublishCreate = "orcid.publication.action.create";
	let orcidTextPublishConfirm = "orcid.publication.action.confirmation";
	const keyPrefix = "orcid.publication*";

	let docReady=false;
	let langReady=false;

	jQuery.ajax(translateURL + currentLang +"/" + keyPrefix).done(function(data){
		orcidTextStatusIsInProfileTrue = data[orcidTextStatusIsInProfileTrue];
		orcidTextStatusIsInProfileFalse = data[orcidTextStatusIsInProfileFalse];
		orcidTextPublishUpdate = data[orcidTextPublishUpdate];
		orcidTextPublishCreate = data[orcidTextPublishCreate];
		orcidTextPublishConfirm = data[orcidTextPublishConfirm];
	}).always(function () {
		langReady=true;
		tryInit();
	});

	function tryInit(){
		if(langReady&&docReady){
			jQuery('div.orcid-status').each(function() {
				getORCIDPublicationStatus(this);
			});
			jQuery('div.orcid-publish').each(function() {
				showORCIDPublishButton(this);
			});
		}
	}

	jQuery(document).ready(function() {
		docReady=true;
		tryInit();
	});

	function getORCIDPublicationStatus(div) {
		var id = jQuery(div).data('id');
		jQuery.get(orcidStatusURL + id, function(status) {
			console.log(status);
			setORCIDPublicationStatus(div, status);
		});
	}

	function setORCIDPublicationStatus(div, status) {
		jQuery(div).empty();
		if (status.user.isORCIDUser && status.isUsersPublication) {
			var html = "<span class='orcid-info' title='"
				+ (status.isInORCIDProfile ? orcidTextStatusIsInProfileTrue : orcidTextStatusIsInProfileFalse)	+ "'>";
			html += orcidIcon;
			html += "<span class='fa fa-thumbs-" + (status.isInORCIDProfile ? "up" : "down")
					+ " orcid-in-profile-" + status.isInORCIDProfile + "' aria-hidden='true' />";
			html += "</span>";
			jQuery(div).html(html);
		}
	}

	function showORCIDPublishButton(div) {
		var id = jQuery(div).data('id');
		jQuery.get(orcidStatusURL + id, function(status) {
			console.log(status);
			updateORCIDPublishButton(div, status);
		});
	}

	function updateORCIDPublishButton(div, status) {
		var id = jQuery(div).data('id');
		jQuery(div).empty();
		if (status.user.isORCIDUser && status.user.weAreTrustedParty && status.isUsersPublication) {
			var html = "<button class='orcid-button'>"
					+ (status.isInORCIDProfile ? orcidTextPublishUpdate	: orcidTextPublishCreate) + "</button>";
			jQuery(div).html(html);
			jQuery(div).find('.orcid-button').click( function() {
						div = this;
						jQuery.get(orcidPublishURL + id, function(newStatus) {
							alert(orcidTextPublishConfirm);
							jQuery("div.orcid-status[data-id='" + id + "']").each(
									function() {
										setORCIDPublicationStatus(this, newStatus);
									});
							jQuery("div.orcid-publish[data-id='" + id + "']").each(
									function() {
										updateORCIDPublishButton(this, newStatus);
									});
						});
					});
		}
	}
})();
