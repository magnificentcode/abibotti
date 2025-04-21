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

  if (!subject || !topic) {
    alert("Valitse ensin oppiaine ja vuosi.");
    return;
  }

  const loader = document.getElementById("loader");
  const box = document.getElementById("question-box");
  const contentArea = document.getElementById("content-area");

  loader.style.display = "block";
  box.style.display = "none";
  contentArea.classList.remove("show");

  try {
    const res = await fetch(`${BASE_URL}/gpt`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ subject, topic })
    });

    const text = await res.text();
    try {
      const data = JSON.parse(text);
      if (res.status === 401) {
        alert("🚫 Accès non autorisé. Clé API invalide ou manquante.");
        return;
      }

      if (data.error) {
        box.innerHTML = `<p>⚠️ ${data.error}</p>`;
      } else {
        box.innerHTML = `
          <h3>YO (${data.difficulty || "??"})</h3>
          <p><strong>Kysymys :</strong> ${data.question}</p>
        `;
        box.style.display = "block";
        contentArea.classList.add("show");
        setCurrentQuestion(data.question);
      }
    } catch (jsonErr) {
      console.error("Erreur JSON parsing:", jsonErr);
      alert("❌ La réponse reçue n’est pas un JSON valide.");
    }
  } catch (err) {
    alert("❌ Une erreur est survenue lors de la récupération de la question.");
    console.error(err);
  }
}

document.getElementById("generate-backend-question").addEventListener("click", fetchQuestionFromBackend);

// 📤 Envoi pour correction avec la question
async function envoyerReponsePourCorrection() {
  const contenuReponse = document.getElementById("answer-editor").innerHTML;
  const question = document.getElementById("current-question").value;
  const feedback = document.getElementById("feedback-area");

  if (!contenuReponse.trim()) {
    feedback.innerHTML = "<p>⚠️ Écris une réponse avant de l’envoyer.</p>";
    return;
  }

  if (!question.trim()) {
    feedback.innerHTML = "<p>❗ Générez d'abord une question.</p>";
    return;
  }

  feedback.innerHTML = "<p>⏳ Analyse en cours...</p>";

  try {
    const res = await fetch(`${BASE_URL}/correction`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ question, reponse: contenuReponse })
    });

    const data = await res.json();

    if (data.error) {
      feedback.innerHTML = `<p>❌ Erreur : ${data.error}</p>`;
    } else {
      feedback.innerHTML = `
        <div class="correction-result">
          <p><strong>Arvosana :</strong> ${data.note || "?"}</p>
          <p><strong>Korjaus :</strong> ${data.correction}</p>
          <p><strong>Palaute :</strong> ${data.feedback}</p>
        </div>
      `;
    }
  } catch (err) {
    feedback.innerHTML = `<p>❌ Une erreur est survenue.</p>`;
    console.error(err);
  }
}

document.getElementById("submit-answer").addEventListener("click", envoyerReponsePourCorrection);
