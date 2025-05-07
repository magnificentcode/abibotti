document.getElementById('signup-form').addEventListener('submit', async function (e) {
    e.preventDefault();
  
    const form = e.target;
    const submitButton = form.querySelector("button[type=submit]");
        submitButton.disabled = true;
        submitButton.textContent = "Rekisteröidään...";
    const data = {
      fullname: form.fullname.value,
      email: form.email.value,
      password: form.password.value,
      'confirm-password': form['confirm-password'].value
    };
  
    const res = await fetch('https://abibotti-production.up.railway.app/signup', {
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
      submitButton.disabled = false;
      submitButton.textContent = "Rekisteröidy";
      window.location.href = '/dashboard.html';
    }
  });   