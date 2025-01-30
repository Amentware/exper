'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter.js": "76f08d47ff9f5715220992f993002504",
"main.dart.js": "00935bc8f38bc110d0ccb1f60169d3d7",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/timezone/data/latest_all.tzf": "df0e82dd729bbaca78b2aa3fd4efd50d",
"assets/packages/rflutter_alert/assets/images/2.0x/close.png": "abaa692ee4fa94f76ad099a7a437bd4f",
"assets/packages/rflutter_alert/assets/images/2.0x/icon_warning.png": "e4606e6910d7c48132912eb818e3a55f",
"assets/packages/rflutter_alert/assets/images/2.0x/icon_error.png": "2da9704815c606109493d8af19999a65",
"assets/packages/rflutter_alert/assets/images/2.0x/icon_success.png": "7d6abdd1b85e78df76b2837996749a43",
"assets/packages/rflutter_alert/assets/images/2.0x/icon_info.png": "612ea65413e042e3df408a8548cefe71",
"assets/packages/rflutter_alert/assets/images/close.png": "13c168d8841fcaba94ee91e8adc3617f",
"assets/packages/rflutter_alert/assets/images/icon_warning.png": "ccfc1396d29de3ac730da38a8ab20098",
"assets/packages/rflutter_alert/assets/images/icon_error.png": "f2b71a724964b51ac26239413e73f787",
"assets/packages/rflutter_alert/assets/images/3.0x/close.png": "98d2de9ca72dc92b1c9a2835a7464a8c",
"assets/packages/rflutter_alert/assets/images/3.0x/icon_warning.png": "e5f369189faa13e7586459afbe4ffab9",
"assets/packages/rflutter_alert/assets/images/3.0x/icon_error.png": "15ca57e31f94cadd75d8e2b2098239bd",
"assets/packages/rflutter_alert/assets/images/3.0x/icon_success.png": "1c04416085cc343b99d1544a723c7e62",
"assets/packages/rflutter_alert/assets/images/3.0x/icon_info.png": "e68e8527c1eb78949351a6582469fe55",
"assets/packages/rflutter_alert/assets/images/icon_success.png": "8bb472ce3c765f567aa3f28915c1a8f4",
"assets/packages/rflutter_alert/assets/images/icon_info.png": "3f71f68cae4d420cecbf996f37b0763c",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/fonts/MaterialIcons-Regular.otf": "ba38bcec01b9cae86b56a128a0a0ecc5",
"assets/assets/images/pngs/anemia0.png": "a935c994b4efec515dd2d49875cac4d2",
"assets/assets/images/pngs/high%2520risk.png": "a85198d07d4da2dbc5e49df10a835231",
"assets/assets/images/pngs/Frame%252013.png": "246e63a5b8f507853fa386bf035e9e42",
"assets/assets/images/pngs/Frame%252012.png": "7a916f7597b2487fa50aab4dbe520674",
"assets/assets/images/pngs/anemia1.png": "73536b6de3b438d3a9282222bcde7921",
"assets/assets/images/pngs/gdm1.png": "9f8af0b24bfc607462fc56a9f79fe3a3",
"assets/assets/images/pngs/mid%2520risk.png": "3e82c1e12a55ba505087e21f8f8a4b00",
"assets/assets/images/pngs/low%2520risk.png": "9ba39764cbdf631e8d0d143fe3170c79",
"assets/assets/images/pngs/gdm0.png": "7a42443430f342fb4a11dde50ee49702",
"assets/assets/images/pngs/anemia.png": "6c283e74cee004b0130426421b511e30",
"assets/assets/images/babypic/pregnancy-week-6.jpg": "f692a8980d3e3cec87cd5cc6794919a2",
"assets/assets/images/babypic/pregnancy-week-7.jpg": "e140d600ae3c04b19b90ae2630b52541",
"assets/assets/images/babypic/pregnancy-week-10.jpg": "64c97e396dc9b16d0f5995a819c9c41e",
"assets/assets/images/babypic/pregnancy-week-32.jpg": "c2a0aabd6d54fa9f44708c653cddb63a",
"assets/assets/images/babypic/pregnancy-week-13.jpg": "9b2e872ea5406a1616eebc7b4ea12797",
"assets/assets/images/babypic/pregnancy-week-1.jpg": "70a5f15b26548ccd8a958c665634768b",
"assets/assets/images/babypic/pregnancy-week-41.jpg": "f64896c60595554e24db729020c2060e",
"assets/assets/images/babypic/pregnancy-week-39.jpg": "a37e4e10463e81613760040cb34854e4",
"assets/assets/images/babypic/pregnancy-week-30.jpg": "f4f26e62d24bcf13b7f5491e7a3cf943",
"assets/assets/images/babypic/pregnancy-week-12.jpg": "c4eaaf2d494bee9f44163fd71c8f3aa5",
"assets/assets/images/babypic/pregnancy-week-16.jpg": "ea628b220078f12f3af393f3b5273bc5",
"assets/assets/images/babypic/pregnancy-week-28.jpg": "91de176d06bc4eee92aeda1de0352eee",
"assets/assets/images/babypic/pregnancy-week-37.jpg": "8120abcf3997b100bfa92fc3ba74bdbd",
"assets/assets/images/babypic/pregnancy-week-25.jpg": "5e4e2c07429499ec65e7f7e3c67e02af",
"assets/assets/images/babypic/pregnancy-week-15.jpg": "4c3826ea2105eb8199585c1df39ebe8e",
"assets/assets/images/babypic/pregnancy-week-31.jpg": "a623e16540e7b0887e66c9e44d79cf26",
"assets/assets/images/babypic/pregnancy-week-40.jpg": "867c933c784b45f8128680647307e85b",
"assets/assets/images/babypic/pregnancy-week-3.jpg": "1e536d8c1f667b8a733c6d2a363cef90",
"assets/assets/images/babypic/pregnancy-week-4.jpg": "26d719fc2e4f6cf2bdbd2f79d33ca862",
"assets/assets/images/babypic/pregnancy-week-33.jpg": "505d16cd9c36702c1fe0fa0f26d8100a",
"assets/assets/images/babypic/pregnancy-week-22.jpg": "9dfcc4bf249ded5f77755bd851fb8bff",
"assets/assets/images/babypic/pregnancy-week-11.jpg": "21e12fbd15a4bab093b40c6b336fa3b2",
"assets/assets/images/babypic/pregnancy-week-20.jpg": "44035d570929c9b94a8a64961a2b919d",
"assets/assets/images/babypic/pregnancy-week-2.jpg": "70a5f15b26548ccd8a958c665634768b",
"assets/assets/images/babypic/pregnancy-week-38.jpg": "cbdf228ce97abac53535845de525078f",
"assets/assets/images/babypic/pregnancy-week-18.jpg": "f72b9f136ecdb0860874d13cb21e79e9",
"assets/assets/images/babypic/pregnancy-week-26.jpg": "741d99557b4dc710c670fe448905aa95",
"assets/assets/images/babypic/pregnancy-week-23.jpg": "3582c3f547ba0eee4b966d32fc6ab870",
"assets/assets/images/babypic/pregnancy-week-9.jpg": "1427881e839b227271096a053aeb15b4",
"assets/assets/images/babypic/pregnancy-week-19.jpg": "bb89591dc5412fa8e6c60af6d28fe144",
"assets/assets/images/babypic/pregnancy-week-27.jpg": "a302076ca304ec8e62368b1ddca3c9ca",
"assets/assets/images/babypic/pregnancy-week-5.jpg": "f612968f363a9f8f59bc74916c501c3a",
"assets/assets/images/babypic/pregnancy-week-35.jpg": "a7dba6b70d926d9b15c74f0e0059c657",
"assets/assets/images/babypic/pregnancy-week-34.jpg": "efa38e94baa2fa8ef51d8c2af846b336",
"assets/assets/images/babypic/pregnancy-week-42.jpg": "f64896c60595554e24db729020c2060e",
"assets/assets/images/babypic/pregnancy-week-24.jpg": "fd0fa9e9fae5a037e8856a9e0c1cafe5",
"assets/assets/images/babypic/pregnancy-week-17.jpg": "162f5c1c795e07fdcdb891e58bd44eb6",
"assets/assets/images/babypic/pregnancy-week-36.jpg": "0c7f6ac10ced2bd339e62f1d21bbedcd",
"assets/assets/images/babypic/pregnancy-week-8.jpg": "7cc66372f43a6e443b20964ed27e8be5",
"assets/assets/images/babypic/pregnancy-week-21.jpg": "82b0acd58ff0cdfd003ebcd6940d067c",
"assets/assets/images/babypic/pregnancy-week-29.jpg": "b1082d22eaa11135d56b1053deefacb4",
"assets/assets/images/babypic/pregnancy-week-14.jpg": "ee3b0301dcaa669e1fc0c7e1120dc6e5",
"assets/assets/images/ced84a67302c60bd1abaaf9314064433.jpg": "67e79cffa9a5bb751ad8d4084a13ee33",
"assets/assets/images/backgrounds/Android%2520Large%2520-%25203.png": "94d9473701a2202a156a5321cd346340",
"assets/assets/images/backgrounds/Android%2520Large%2520-%252016.png": "d11f8af9cbbed8312420947d8f80e1fd",
"assets/assets/images/backgrounds/Android%2520Large%2520-%252015.png": "6e0bd3854b8fae79947127fc85ac8945",
"assets/assets/images/backgrounds/Android%2520Large%2520-%252013.png": "92021d66fc0ceb0ea4caa4dca83636ed",
"assets/assets/images/backgrounds/Android%2520Large%2520-%25204.png": "3f857b95913f8aac413adc867eafed00",
"assets/assets/images/backgrounds/Android%2520Large%2520-%252018.png": "a46f1b171b39c12c69f20b17d1fb4d21",
"assets/assets/images/backgrounds/Android%2520Large%2520-%25201.png": "e7f76132a0bc79e06c193808a80ca5a4",
"assets/assets/images/backgrounds/Android%2520Large%2520-%252017.png": "9aec65d0c80a93b76eb3046cdc64199f",
"assets/assets/images/backgrounds/Android%2520Large%2520-%25202.png": "6f9464ee4f0796a9f2befd99a94e9a08",
"assets/assets/images/backgrounds/Android%2520Large%2520-%252014.png": "c8c4e11a217ddc3f17535a6562655652",
"assets/assets/images/embryo.png": "04b1188605b2ac8f35118ef65ff67e72",
"assets/assets/images/Android%2520Large%2520-%252012.png": "9751b44b1af01512731a6bb30e06f795",
"assets/assets/images/126472.png": "79742556af337599cffa66603c1d1099",
"assets/assets/images/user.jpg": "0f8e789e159dcc08df61455201923173",
"assets/AssetManifest.json": "7bf1bb25e7462e22bf5dd72a7f86cc4e",
"assets/NOTICES": "4e62e0831ef24b4222253131c13c71c3",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin.json": "24bb6009037b92a86e0c71359b4131c7",
"assets/AssetManifest.bin": "a9a79857b51afd6ac5fde5dab96a6aa9",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"manifest.json": "8318a4fe45e4b51aaf33134ce518ac20",
"flutter_bootstrap.js": "341608ce0372de3d765f552cab0536e7",
"index.html": "2626596af3fc684a29b7f8dd5b6f6e0a",
"/": "2626596af3fc684a29b7f8dd5b6f6e0a",
"version.json": "0554659db73ee0c4e28c827e976d2b44",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"canvaskit/skwasm.wasm": "c528f7ba97a317e25e547ea47c8a66d8",
"canvaskit/canvaskit.wasm": "2e9895626fe95683569ed951214f1eb8",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/chromium/canvaskit.wasm": "86233631b867ce8f74c2020077650d11",
"canvaskit/chromium/canvaskit.js": "73343b0c5d471d1114d7f02e06c1fdb2",
"canvaskit/chromium/canvaskit.js.symbols": "85275e659470daa080e014ffe17a1a59",
"canvaskit/skwasm_st.js.symbols": "a564f5dfbd90292f0f45611470170fe1",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/canvaskit.js": "de27f912e40a372c22a069c1c7244d9b",
"canvaskit/skwasm.js.symbols": "c7cf698f802bc5e9e8e791f762ebdfe9",
"canvaskit/canvaskit.js.symbols": "ff204c6b77c9e5969d85d9bfbaa0c843",
"canvaskit/skwasm_st.wasm": "3179a61ea4768a679dbbe30750d75214"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
