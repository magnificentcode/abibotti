// 🌐 Base dynamique (pour Railway ou localhost)
const BASE_URL = window.location.origin;

// Stocke la question actuelle dans l'input caché
function setCurrentQuestion(questionText) {
  document.getElementById("current-question").value = questionText;
}

// 🔄 Récupère une question depuis le backend
async function fetchQuestionFromBackend() {
  const subject = document.getElementById("matiere").value;
  const topic = document.getElementById("subject").value;
  const loader = document.getElementById("loader");
  const box = document.getElementById("question-box");
  const contentArea = document.getElementById("content-area");

  if (!subject || !topic) {
    alert("Valitse ensin oppiaine ja vuosi.");
    return;
  }

  loader.style.display = "block";
  box.style.display = "none";
  contentArea.classList.remove("show");

  try {
    const res = await fetch("/gpt", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ subject, topic }),
    });

    const rawText = await res.text();
    let data;

    try {
      data = JSON.parse(rawText);
    } catch (err) {
      box.innerHTML = `<p>❌ Réponse invalide du serveur.</p><pre>${rawText}</pre>`;
      return;
    }

    if (!res.ok || data.error) {
      box.innerHTML = `<p>❌ ${data.error || 'Erreur serveur inconnue'}</p>`;
      return;
    }

    box.innerHTML = `
      <h3>YO (${data.difficulty || "??"})</h3>
      <p><strong>Kysymys :</strong> ${data.question}</p>
    `;
    box.style.display = "block";
    contentArea.classList.add("show");
    setCurrentQuestion(data.question);

  } catch (err) {
    box.innerHTML = `<p>❌ Erreur de connexion au serveur</p>`;
    console.error("Erreur JS:", err);
  } finally {
    loader.style.display = "none";
  }
}