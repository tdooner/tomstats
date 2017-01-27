self.addEventListener('push', event => {
  event.waitUntil(self.registration.showNotification('TomStats Message', {
    body: event.data.text(),
  }));
});
