(() => {
  const removeTargets = () => {
    document.getElementById('_id_mobile_ad')?.remove();
    document.getElementById('_entry_level_guide')?.remove();
    document.querySelector('.component_filter')?.remove();
  };

  const addCustomButtons = () => {
    document
      .querySelectorAll('.origin.is-audible')
      .forEach(origin => {

        if (origin.querySelector('.my-custom-button')) {
          return;
        }

        const originalButton = origin.querySelector(
          'button._btn_add_wordbook_example'
        );

        if (!originalButton) {
          return;
        }

        const customButton = document.createElement('button');
        customButton.className = 'my-custom-button';
        origin.style.position = 'relative';

        customButton.style.position = 'absolute';
        customButton.style.right = '0';
        customButton.style.top =
          `${originalButton.offsetTop + originalButton.offsetHeight + 24}px`;
        customButton.style.zIndex = '999';

        customButton.style.width = '20px';
        customButton.style.height = '20px';
        customButton.style.borderRadius = '50%';
        customButton.style.border = '1px solid #d3d7e0';
        customButton.style.background = '#e8ebf2';
        customButton.style.padding = '0';
        customButton.style.display = 'flex';
        customButton.style.alignItems = 'center';
        customButton.style.justifyContent = 'center';
        customButton.style.cursor = 'pointer';

        customButton.innerHTML = '🔊';
        customButton.style.fontSize = '12px';

        customButton.addEventListener('click', () => {
          const sentence =
            origin.querySelector('.text')?.innerText ?? '';

          console.log(sentence);

          window.webkit?.messageHandlers?.exampleButton?.postMessage({
            text: sentence
          });
        });

        origin.appendChild(customButton);
      });
  };

  removeTargets();

  const observer = new MutationObserver(() => {
    removeTargets();
    addCustomButtons();
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true
  });
})();
