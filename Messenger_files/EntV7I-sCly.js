if (self.CavalryLogger) { CavalryLogger.start_js(["mhkyE"]); }

__d("MessengerUserControlsButtonReact.bs",["ix","fbt","Image.bs","LinkReact.bs","MercuryIDs","ReasonReact.bs","AsyncRequest","MessengerDialogs.bs","MercuryDispatcher","MessengerMenuReact.bs","MercuryThreadActions","MessengerParticipants.bs","MessengerMuteDialogReact.bs","MessengerPopoverMenuReact.bs"],(function(a,b,c,d,e,f,g,h){"use strict";__p&&__p();var i=h._("Mute Notifications"),j=h._("Unmute Notifications"),k=h._("Turn Off Messages"),l=h._("Turn On Messages"),m=g("464335"),n=g("464334"),o=b("ReasonReact.bs").statelessComponent("MessengerUserControlsButton");function a(a,c,d){new(b("AsyncRequest"))(a.getURI(c)).setMethod("POST").setData(c).setHandler(d).send();return 0}function p(a,c,d){c=b("MessengerParticipants.bs").getNow(c);if(c==null)return 0;else{c=Object.assign({},c);b("MercuryDispatcher").getForFBID(d).handleUpdate(Object.assign({},{participants:[Object.assign(c,{is_messenger_blocked:a})],preprocessed:!0}));return 0}}function c(a,c,d,e,f,g,h){__p&&__p();var q=function(){if(d){b("MercuryThreadActions").getForFBID(g).unblockOnMessengerDotCom(f);return p(!1,b("MercuryIDs").getParticipantIDFromUserID(e),g)}else{b("MercuryThreadActions").getForFBID(g).blockOnMessengerDotCom(f);return p(!0,b("MercuryIDs").getParticipantIDFromUserID(e),g)}},r=function(a){b("MercuryThreadActions").getForFBID(g).updateMuteSetting(f,a);return 0},s=function(){if(c){b("MercuryThreadActions").getForFBID(g).unmute(f);return 0}else return b("MessengerDialogs.bs").showDialog(function(){return b("ReasonReact.bs").element(void 0,void 0,b("MessengerMuteDialogReact.bs").make(r,[]))})};return[o[0],o[1],o[2],o[3],o[4],o[5],o[6],o[7],function(){var e=c?j:i;e=b("ReasonReact.bs").element(void 0,void 0,b("MessengerMenuReact.bs").MenuItem[0](void 0,e,s,void 0,[]));var f=d?l:k;f=b("ReasonReact.bs").element(void 0,void 0,b("MessengerMenuReact.bs").MenuItem[0](void 0,f,q,void 0,[]));e=b("ReasonReact.bs").element(void 0,void 0,b("MessengerMenuReact.bs").Menu[0]([e,f]));f=d?n:m;return b("ReasonReact.bs").element(void 0,void 0,b("MessengerPopoverMenuReact.bs").make(a,void 0,void 0,e,void 0,void 0,[b("ReasonReact.bs").element(void 0,void 0,b("LinkReact.bs").make(void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,void 0,[b("ReasonReact.bs").element(void 0,void 0,b("Image.bs").make(void 0,void 0,void 0,void 0,f,32,void 0,40,void 0,[]))]))]))},o[9],o[10],o[11],o[12]]}f.mute=i;f.unmute=j;f.block=k;f.unblock=l;f.unblocked_button_image_path=m;f.blocked_button_image_path=n;f.component=o;f.sendSubscriptionAction=a;f.changeBlockedStatus=p;f.make=c}),null);
__d("BootloadableMessengerUserControlsButtonReact.bs",["MessengerUserControlsButtonReact.bs"],(function(a,b,c,d,e,f){"use strict";a=[b("MessengerUserControlsButtonReact.bs").mute,b("MessengerUserControlsButtonReact.bs").unmute,b("MessengerUserControlsButtonReact.bs").block,b("MessengerUserControlsButtonReact.bs").unblock,b("MessengerUserControlsButtonReact.bs").unblocked_button_image_path,b("MessengerUserControlsButtonReact.bs").blocked_button_image_path,b("MessengerUserControlsButtonReact.bs").component,b("MessengerUserControlsButtonReact.bs").sendSubscriptionAction,b("MessengerUserControlsButtonReact.bs").changeBlockedStatus,b("MessengerUserControlsButtonReact.bs").make];f.bootloadable=a}),null);