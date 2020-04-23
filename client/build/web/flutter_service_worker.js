'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "404.html": "0a27a4163254fc8fce870c8cc3a3f94f",
"assets/AssetManifest.json": "fd934c9c800e76553404f95f7e22050e",
"assets/assets/twitter-custom-logo.png": "14bf209caa968dfdb8a1c90b6707c966",
"assets/assets/twitter-logo.jpg": "bd3cc8ccfbfeee4c409740bd681770ee",
"assets/assets/twitter-moments.jpg": "750f93e3b2074fe7dcac39bd93884518",
"assets/assets/twitter.png": "26641c55c086348141249e56cdc606af",
"assets/FontManifest.json": "ad85fc85e8e8bc657ed5a323213d68a7",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/LICENSE": "f6e38776619299221a59274ef3b591fd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/packages/eva_icons_flutter/lib/fonts/evaicons.ttf": "b600c99b39c9837f405131463e91f61a",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"index.html": "434566624ae83b7d0add438f674bca92",
"/": "434566624ae83b7d0add438f674bca92",
"main.dart.js": "8b2d3b726e6730cf18563ea35ca93204",
"manifest.json": "f1829e609a87abd1495d68eda28bb5c9"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
