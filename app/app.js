fetch('notes.json').then(res => res.json()).then(data => {
  const container = document.getElementById('notes');
  Object.entries(data).forEach(([date, note]) => {
    const el = document.createElement('p');
    el.textContent = `${date}: ${note}`;
    container.appendChild(el);
  });
});
