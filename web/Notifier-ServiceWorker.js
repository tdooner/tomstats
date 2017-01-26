self.addEventListener('push', event => {
  event.waitUntil(self.registration.showNotification('message received', {
    body: 'body here',
  }));
});
