import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toast"];

  connect() {
    this.toastTargets.forEach((toastElement) => this._initializeToast(toastElement));
  }

  _initializeToast(toastElement) {
    const delay = this._delayFromDataset(toastElement.dataset.delay);
    const options = { autohide: true, delay };

    const toast = bootstrap.Toast.getOrCreateInstance(toastElement, options);

    toastElement.addEventListener("hidden.bs.toast", () => toastElement.remove());
    toast.show();
  }

  _delayFromDataset(value) {
    const parsed = Number.parseInt(value, 10);

    return Number.isNaN(parsed) ? 5000 : parsed;
  }
}
