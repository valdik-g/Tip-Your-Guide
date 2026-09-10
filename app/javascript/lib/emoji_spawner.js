/**
 * Class for creating and managing floating emoji particles.
 */
export default class EmojiSpawner {
  /**
   * @param {HTMLElement} containerElement - DOM element within which emojis will appear.
   */
  constructor(containerElement) {
    if (!containerElement) {
      throw new Error("EmojiSpawner requires a container element.");
    }
    this.container = containerElement;
    this.particleClassName = 'emoji-particle'; // Can be made configurable
  }

  /**
   * Creates and animates one or more emoji particles.
   * @param {string} emojiCharacter - Emoji character to display.
   * @param {number} [count=1] - Number of particles to create.
   */
  spawn(emojiCharacter, count = 1) {
    for (let i = 0; i < count; i++) {
      const element = document.createElement('span');
      element.textContent = emojiCharacter;
      element.classList.add(this.particleClassName);

      // Random horizontal position
      const randomLeft = Math.random() * 80 + 10; // from 10% to 90%
      element.style.left = `${randomLeft}%`;

      // Random animation delay
      const randomDelay = Math.random() * 0.5; // up to 0.5 sec
      element.style.animationDelay = `${randomDelay}s`;

      // Random size - from 16px to 64px
      const randomSize = Math.random() * 48 + 16;
      element.style.fontSize = `${randomSize}px`;

      // Remove element after animation completes
      element.addEventListener('animationend', () => {
        element.remove();
      }, { once: true });

      this.container.appendChild(element);
    }
  }
}