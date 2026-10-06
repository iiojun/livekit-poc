import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "status"];

  async join(event) {
    event.preventDefault();
    try {
      const formData = new FormData(this.formTarget);
      const response = await fetch(
        this.formTarget.action,
        {
          method: "POST",
          headers: {
            "X-CSRF-Token": document.querySelector(
                'meta[name="csrf-token"]'
              ).content
          },
          body: new URLSearchParams(formData)
        }
      );

      if (!response.ok) {
        const text = await response.text();
        throw new Error(`Token request failed: ${response.status} ${text}`);
      }

      const data = await response.json();
      window.joinLiveKit({ token: data.token, serverUrl: data.url });

    } catch (error) {
      console.error(error);
    }
  }
}
