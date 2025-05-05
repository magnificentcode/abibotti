document.getElementById('login-form').addEventListener('submit', async function (e) {
    e.preventDefault();
  
    const form = e.target;
    const data = {
      email: form.email.value,
      password: form.password.value,
    };
  
    const res = await fetch('/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
  
    const result = await res.json();
    const errorDiv = document.getElementById('login-error');
  
    if (!res.ok) {
      errorDiv.style.display = 'block';
      errorDiv.textContent = result.message || 'Virhe tapahtui.';
    } else {
      localStorage.setItem('token', result.token);
      window.location.href = '/dashboard.html';
    }
  });