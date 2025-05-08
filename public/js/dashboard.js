document.addEventListener("DOMContentLoaded", () => {
    const token = localStorage.getItem("token");
  
    if (!token) {
      window.location.href = "/login.html";
      return;
    }
  
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      const userEmail = payload.email || "käyttäjä";
      const welcomeText = document.querySelector(".welcome-text");
      if (welcomeText) {
        welcomeText.textContent = `Tervetuloa, ${userEmail}!`;
      }
    } catch (e) {
      console.error("Tokenin purku epäonnistui", e);
    }
  
    const logoutBtn = document.querySelector("a[onclick='logout()']");
    if (logoutBtn) {
      logoutBtn.addEventListener("click", (e) => {
        e.preventDefault();
        localStorage.removeItem("token");
        window.location.href = "/login.html";
      });
    }
  });