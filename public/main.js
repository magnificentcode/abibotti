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
      const res = await fetch("http://abibotti.online/gpt", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ subject, topic })
      });
  
      const data = await res.json();
      loader.style.display = "none";
  
      if (data.error) {
        box.innerHTML = `<p>⚠️ ${data.error}</p>`;
      } else {
        box.innerHTML = `
          <h3>YO (${data.difficulty || "??"})</h3>
          <p><strong>Kysymys :</strong> ${data.question}</p>
        `;
        box.style.display = "block";
        contentArea.classList.add("show");
        setCurrentQuestion(data.question); // ✅ stocke dans l'input caché
      }
    } catch (err) {
      loader.style.display = "none";
      alert("❌ Une erreur est survenue lors de la récupération de la question.");
      console.error(err);
    }
  }
  
  document.getElementById("generate-backend-question").addEventListener("click", fetchQuestionFromBackend);
  
  // 🎯 Éditeur équations
  const equationPopup = document.getElementById("equation-popup");
  const equationInput = document.getElementById("equation-input");
  const equationPreview = document.getElementById("equation-preview");
  const insertBtn = document.getElementById("insert-equation");
  const answerEditor = document.getElementById("answer-editor");
  const equationList = document.getElementById("equation-list");
  
  document.addEventListener("keydown", (e) => {
    if (e.ctrlKey && e.key.toLowerCase() === 'e') {
      e.preventDefault();
      equationPopup.style.display = 'block';
      equationInput.focus();
    }
  });
  
  equationInput.addEventListener("input", () => {
    equationPreview.innerHTML = `\\(${equationInput.value}\\)`;
    MathJax.typesetPromise([equationPreview]);
  });
  
  function insertEquation(tex) {
    if (!tex) return;
  
    const span = document.createElement("span");
    span.className = "equation";
    span.innerText = `\\(${tex}\\)`;
  
    const sel = window.getSelection();
    if (sel.rangeCount > 0) {
      const range = sel.getRangeAt(0);
      range.deleteContents();
      range.insertNode(span);
      range.collapse(false);
      sel.removeAllRanges();
      sel.addRange(range);
      MathJax.typesetPromise([span]);
    }
  
    const listItem = document.createElement("span");
    listItem.className = "equation";
    listItem.innerText = `\\(${tex}\\)`;
    listItem.title = "Cliquez pour supprimer";
    listItem.addEventListener("click", () => listItem.remove());
    equationList.appendChild(listItem);
    MathJax.typesetPromise([listItem]);
  
    equationPopup.style.display = 'none';
    equationInput.value = '';
    equationPreview.innerHTML = '';
  }
  
  insertBtn.addEventListener("click", () => {
    const tex = equationInput.value.trim();
    insertEquation(tex);
  
    const block = document.createElement("div");
    block.className = "equation-block";
    block.setAttribute("data-latex", tex);
    block.innerText = `\\(${tex}\\)`;
    answerEditor.appendChild(block);
    MathJax.typesetPromise([block]);
  });
  
  window.addEventListener('click', (e) => {
    if (e.target === equationPopup) {
      equationPopup.style.display = 'none';
    }
  });
  
  answerEditor.addEventListener("click", (e) => {
    const target = e.target;
    if (target.classList.contains("equation-block")) {
      const latex = target.getAttribute("data-latex");
      equationInput.value = latex;
      equationPreview.innerHTML = `\\(${latex}\\)`;
      MathJax.typesetPromise([equationPreview]);
      equationPopup.style.display = 'block';
  
      insertBtn.onclick = () => {
        const newLatex = equationInput.value.trim();
        if (!newLatex) return;
        target.innerText = `\\(${newLatex}\\)`;
        target.setAttribute("data-latex", newLatex);
        MathJax.typesetPromise([target]);
        equationPopup.style.display = 'none';
        equationInput.value = '';
        equationPreview.innerHTML = '';
      };
    }
  });
  
  // 💾 Sauvegarde automatique
  setInterval(() => {
    const content = answerEditor.innerHTML;
    localStorage.setItem("abibotti_answer", content);
    MathJax.typesetPromise();
  }, 5000);
  
  window.addEventListener("DOMContentLoaded", () => {
    const saved = localStorage.getItem("abibotti_answer");
    if (saved) {
      answerEditor.innerHTML = saved;
    }
  });
  
  // 📤 Envoi pour correction avec la question
  async function envoyerReponsePourCorrection() {
    const contenuReponse = answerEditor.innerHTML;
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
    function getCleanedAnswerHTML() {
        const editor = document.getElementById("answer-editor");
        const clone = editor.cloneNode(true);
      
        // Convertit toutes les balises .equation en LaTeX brut
        clone.querySelectorAll('.equation, .equation-block').forEach(span => {
          const latex = span.innerText || span.textContent || '';
          const textNode = document.createTextNode(latex);
          span.replaceWith(textNode);
        });
      
        // Retourne le texte brut (sans balises)
        return clone.textContent.trim();
      }
      
  
    try {
      const res = await fetch("http://abibotti.online/correction", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          question: question,
          reponse: contenuReponse
        })
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
  