document.addEventListener("DOMContentLoaded", () => {
  const token = localStorage.getItem("token");

  if (!token) {
    window.location.href = "/login.html";
    return;
  }

  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    console.log("✅ Käyttäjä kirjautunut:", payload.email);
  } catch (e) {
    console.error("❌ Virheellinen token:", e);
    localStorage.removeItem("token");
    window.location.href = "/login.html";
  }

  const mathField = document.getElementById("math-editor");
  const editor = document.getElementById("answer-editor");

  // Crtl + E pour basculer sur le champ MathLive
  document.addEventListener("keydown", (e) => {
    if (e.ctrlKey && e.key.toLowerCase() === "e") {
      e.preventDefault();
      mathField.focus();
    }
  });

  // Enter dans MathLive pour injecter le LaTeX rendu
  mathField.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      e.preventDefault();
      const latex = mathField.getValue();
      if (latex.trim()) {
        const span = document.createElement("span");
        span.className = "equation";
        span.textContent = `\\(${latex}\\)`;
        editor.appendChild(span);
        editor.appendChild(document.createTextNode(" "));
        MathJax.typesetPromise([editor]);
        mathField.setValue(""); // Efface le champ
        editor.focus(); // Revenir à l’éditeur texte
      }
    }
  });
});