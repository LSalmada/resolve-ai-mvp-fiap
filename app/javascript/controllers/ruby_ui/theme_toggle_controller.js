import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ruby-ui--theme-toggle"
// pressed = dark mode
export default class extends Controller {
  connect() {
    this.applyTheme(this.currentTheme());
  }

  apply(event) {
    const theme = event.detail?.pressed ? "dark" : "light";
    localStorage.theme = theme;
    this.applyTheme(theme);
  }

  currentTheme() {
    if (localStorage.theme === "dark") return "dark";
    if (localStorage.theme === "light") return "light";
    return "dark";
  }

  applyTheme(theme) {
    const html = document.documentElement;
    if (theme === "dark") {
      html.classList.add("dark");
      html.classList.remove("light");
    } else {
      html.classList.add("light");
      html.classList.remove("dark");
    }

    this.element.setAttribute(
      "data-ruby-ui--toggle-pressed-value",
      theme === "dark" ? "true" : "false",
    );
  }
}
