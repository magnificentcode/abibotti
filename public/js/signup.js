document.getElementById('signup-form').addEventListener('submit', async function (e) {
    e.preventDefault();
  
    const form = e.target;
    const data = {
      fullname: form.fullname.value,
      email: form.email.value,
      password: form.password.value,
      'confirm-password': form['confirm-password'].value
    };
  
    const res = await fetch('/signup', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
  
    const result = await res.json();
    const errorDiv = document.getElementById('signup-error');
  
    if (!res.ok) {
      errorDiv.style.display = 'block';
      errorDiv.textContent = result.message || 'Virhe tapahtui.';
    } else {
      localStorage.setItem('token', result.token);
      window.location.href = '/dashboard.html';
    }
  });   