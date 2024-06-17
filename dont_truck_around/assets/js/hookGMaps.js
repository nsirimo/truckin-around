import { Loader } from "@googlemaps/js-api-loader";
export default {
  mounted() {
    const hook = this;
    elt = hook.el;
    hook.map = null;
    const loader = new Loader({
      apiKey: "",
      version: "weekly",
    });
    hook.targets = [];
    hook.handleEvent("update_markers", (payload) => {
      hook.targets = payload.data;
      if (hook.map) {
        hook.updateMarkers();
      }
    });

    loader.importLibrary("maps").then(({ Map }) => {
      hook.map = new Map(elt, {
        center: { lat: 37.7749, lng: -122.4194 },
        zoom: 12,
        zoomControl: true,
        mapTypeControl: false,
        scaleControl: false,
        streetViewControl: false,
        rotateControl: false,
        fullscreenControl: true,
        styles: [
          {
            featureType: "all",
            stylers: [{ saturation: -100 }],
          },
          {
            featureType: "water",
            stylers: [
              {
                saturation: 0,
                color: "#79b0cb",
              },
            ],
          },
        ],
      });

      hook.updateMarkers = function() {
        const targets = JSON.parse(hook.el.dataset.targets);
        targets.forEach(({ lat, lng }) => {
          const marker = new google.maps.Marker({
            position: { lat: parseFloat(lat), lng: parseFloat(lng) },
            map: hook.map,
            label: {
              text: "X",
              fontSize: "0.8rem",
              color: "red",
            },
          });
        });
      };

      hook.updateMarkers();
    });
  },
};
