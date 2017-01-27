const attemptSubscribe = (registration) => {
  console.log(registration);
  if (Notification.permission !== 'granted') {
    // denied :(
  } else if (Notification.permission === 'blocked') {
    // can't reprompt
  } else {
    // show a prompt I guess
  }

  const key = process.env.VAPID_PUBLIC_KEY_BYTES;

  registration.pushManager.subscribe({
    applicationServerKey: new Uint8Array(key),
    userVisibleOnly: true,
  })
    .then(subscription => {
      fetch('/notifications/register', { method: 'POST', body: JSON.stringify(subscription) }).catch(err => {
        console.error('error persisting notification details:', err);
      });
    }).catch(e => { console.error(e) });
};

if ('serviceWorker' in navigator) {
  navigator.serviceWorker
    .register('/notifications/NotifierServiceWorker.bundle.js', { scope: '/notifications/' })
    .then(reg => {
      console.log('register: ', reg)

      console.log(navigator.serviceWorker)
      navigator.serviceWorker.ready.then(registration => {
        console.log('ready:', registration);
        document.querySelector('#app').innerHTML = 'Installed successfully!';
        attemptSubscribe(registration)
      }).catch(error => { console.log('error in readiness:', error) });
    })
    .catch(error => {
      document.querySelector('#app').innerHTML = `Installation Error: ${error}`;
    });
} else {
  document.querySelector('#app').innerHTML = 'ServiceWorker not supported!';
}
