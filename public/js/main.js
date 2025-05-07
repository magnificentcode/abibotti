// ✅ main.js corrigé pour Railway (plus de localhost)

function setCurrentQuestion(questionText) {
  document.getElementById("current-question").value = questionText;
}

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

    const text = await res.text();

    let data;
    try {
      data = JSON.parse(text);
    } catch (e) {
      console.error("❌ Format JSON invalide reçu de GPT :", text);
      alert("GPT ei palauttanut kunnollista JSONia.");
      return;
    }
    console.log("📥 Reçu de GPT JSON :", JSON.stringify(data, null, 2));

    // Déplacement du bloc après la réception de la réponse GPT
    let rawQuestion = data.question;
    if (typeof rawQuestion === "object") {
      rawQuestion = JSON.stringify(rawQuestion, null, 2);
    }

    if (res.status === 401) {
      alert("🚫 Accès non autorisé. Clé API invalide ou manquante.");
      return;
    }

    if (data.error) {
      box.innerHTML = `<p>⚠️ ${data.error}</p>`;
    } else {
      box.innerHTML = `
        <h3>YO (${data.difficulty || "??"})</h3>
        <p><strong>Kysymys :</strong><br>${rawQuestion.replace(/\n/g, "<br>")}</p>
      `;
      // Appel juste après le bloc box.innerHTML
      setCurrentQuestion(rawQuestion);
      box.style.display = "block";
      contentArea.classList.add("show");
    }
  } catch (err) {
    alert("❌ Erreur lors de la requête.");
    console.error(err);
  } finally {
    loader.style.display = "none";
  }
}

document.getElementById("generate-backend-question")
  .addEventListener("click", fetchQuestionFromBackend);

// ✅ Submit answer
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

  feedback.innerHTML = "<p>⏳ Clara lukee vastauksesi ja laatii palautetta...</p>";

  try {
    const res = await fetch("/correction", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ question, reponse: contenuReponse }),
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

document.getElementById("submit-answer")
  .addEventListener("click", envoyerReponsePourCorrection);
